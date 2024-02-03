//
//  Simulation.swift
//
//
//  Created by Joe Rupertus on 11/7/23.
//

import Foundation
import SwiftUI
import RealityKit

final public class Simulation: ObservableObject {
    
    // MARK: - Setup
    
    @Published public private(set) var isLoaded: Bool = false
    
    public init(from fileName: String) {
        Task {
            // Decode the tree from the file
            guard let file = Bundle.main.path(forResource: fileName, ofType: "json"),
                  let json = try? String(contentsOfFile: file),
                  let data = json.data(using: .utf8),
                  let root = try? JSONDecoder().decode(SystemNode.self, from: data)
            else { return }
            
            // Create the node references
            await MainActor.run {
                self.root = root
                self.focus = root
                self.system = root
            }
            print("Finished decoding nodes")
            
            // Load the ephemerides
            await root.loadEphemerides()
            print("Finished loading ephemerides")
            
            // Set the scaling size
            await MainActor.run {
                let distance = root.children.filter({ $0.rank == .primary }).map(\.position.magnitude).max() ?? 1
                self.size = 2.5 * distance
            }
            
            // Generate the scene
            if let scene = await Entity.generateScene() {
                await rootEntity.addChild(scene)
            }
            
            // Load the entities
            for node in root.tree {
                let entity = await SimulationEntity(node: node, size: size)
                entities.append(entity)
                await MainActor.run {
                    rootEntity.addChild(entity)
                }
                
            }
            print("Finished creating entities")
            
            // Decode photos
            let photos = await Photo.decode(from: "\(fileName)-photos")
            for object in root.tree.compactMap({ $0 as? ObjectNode }) {
                let matchingPhotos = photos.filter({ $0.id == object.id })
                object.properties?.photos = matchingPhotos
            }
            
            // Complete
            await MainActor.run {
                self.run()
                self.isLoaded = true
            }
        }
        
        BodyComponent.registerComponent()
        OrbitComponent.registerComponent()
        PointComponent.registerComponent()
        
        rootEntity.simulation = self
        SimulationComponent.registerComponent()
        SimulationSystem.registerSystem()
    }
    
    
    // MARK: - Structure
    
    internal var rootEntity = SimulationRootEntity()
    internal var entities: [SimulationEntity] = []
    
    @Published private var root: SystemNode?
    @Published private var focus: Node?
    @Published private var system: SystemNode?
    @Published private var object: ObjectNode?
    
    public var selectedSystem: SystemNode? {
        return system
    }
    public var selectedObject: ObjectNode? {
        return object
    }
    
    internal func isSelected(_ node: Node?) -> Bool {
        return node?.object == object
    }
    internal func isSystem(_ node: Node?) -> Bool {
        return node == system
    }
    internal func isFocus(_ node: Node?) -> Bool {
        return node == focus
    }
    
    public var hasSelection: Bool {
        return object != nil
    }
    public var noSelection: Bool {
        return object == nil
    }
    
    internal var inTransition: Bool = false
    internal var inMajorTransition: Bool = false
    
    public func trailVisible(_ node: Node) -> Bool {
        return !inMajorTransition && showOrbits && !(node == focus && scale * node.size * 10 > size)
    }
    public func labelVisible(_ node: Node) -> Bool {
        return !inTransition && showLabels && node.parent == system && scale * (node.globalPosition - offset).magnitude < 10 * size
        && (node.system == system || 2 * scale * node.position.magnitude > 100 * pixelSize) && scale * node.size * 100 < size
    }
    

    // MARK: - Positioning
    
    @Published private(set) var size: Double = 1E+7
    
    // Offset
    @Published private(set) var offsetAmount: Double = 1.0
    internal var offset: Vector {
        (focus?.parent?.globalPosition ?? .zero) + (focus?.position ?? .zero) * offsetAmount
    }
    
    // Scale
    @Published private var steadyScale: CGFloat = 1.0
    @Published private var gestureScale: CGFloat = 1.0
    internal var scale: CGFloat {
        steadyScale * gestureScale
    }
    
    // Rotation
    @Published private var steadyRotation: Angle = .zero
    @Published private var gestureRotation: Angle = .zero
    internal var rotation: Angle {
        steadyRotation + gestureRotation
    }
    
    // Pitch
    @Published private var steadyPitch: Angle = .zero
    @Published private var gesturePitch: Angle = .zero
    internal var pitch: Angle {
        steadyPitch + gesturePitch
    }
    
    // Thickness
    @Published private(set) var entityThickness: Float = 0.005
    @Published private(set) var screenThickness: CGFloat = 0.005
    private var pixelSize: CGFloat = 100
    internal func setBounds(_ size: CGSize) {
        pixelSize = self.size / min(size.width, size.height)
        if arMode {
            self.entityThickness = 0.002
            self.screenThickness = 0.002 * 4 * size.height
        } else {
            self.entityThickness = 6.0 / Float(2 * min(size.width, size.height))
            self.screenThickness = 6.0
        }
    }
    
    
    // MARK: - Settings
    
    @Published public var time: Date = .now
    @Published public var timeRatio: Double = 1.0 { didSet { isRealTime = false } }
    @Published public var timeStep: Double = 0.1
    public var isRealTime: Bool = true
    public var maxTimeRatio: Double = 1E+5
    
    public var arMode: Bool = false
    public var showOrbits: Bool = true
    public var showLabels: Bool = true
    
    public var selectEnabled: Bool = true
    public var zoomEnabled: Bool = true
    public var rotateEnabled: Bool = true
    
    
    // MARK: - Motion
    
    private func run() {
        Timer.scheduledTimer(withTimeInterval: timeStep, repeats: true) { _ in
            let dt = self.timeStep * self.timeRatio
            self.time.addTimeInterval(dt)
            self.root?.advance(by: dt)
            self.synchronize()
        }
    }
    
    private func synchronize() {
        guard isRealTime else { return }
        
        while -time.timeIntervalSinceNow > 3600 {
            self.time.addTimeInterval(60)
            self.root?.advance(by: 60)
        }
        while -time.timeIntervalSinceNow > 1 {
            self.time.addTimeInterval(1)
            self.root?.advance(by: 1)
        }
        while time < .now {
            self.time.addTimeInterval(timeStep)
            self.root?.advance(by: timeStep)
        }
    }
    
    
    // MARK: - Inputs
    
    // Clock Buttons
    
    public func increaseSpeed() {
        switch timeRatio {
        case 1: timeRatio = 100
        case -100: timeRatio = 1
        case ...(-100): timeRatio /= 10
        case (100)...: timeRatio *= 10
        default: timeRatio = 1
        }
        if abs(timeRatio) >= maxTimeRatio {
            timeRatio = maxTimeRatio
        }
    }
    
    public func decreaseSpeed() {
        switch timeRatio {
        case 1: timeRatio = -100
        case 100: timeRatio = 1
        case ...(-100): timeRatio *= 10
        case (100)...: timeRatio /= 10
        default: timeRatio = 1
        }
        if abs(timeRatio) >= maxTimeRatio {
            timeRatio = -maxTimeRatio
        }
    }
    
    // Select Buttons
    
    public func selectObject(_ node: Node?) {
        // Reset object
        guard let node, selectEnabled else {
            setObject(nil)
            return
        }
        // Select object in orbit
        if object != node.object {
            setObject(node.object)
        }
        // Tap target
        else if let object = node.object {
            zoomToSurface(node: object)
        }
    }
    
    public func selectSystem(_ node: Node?) {
        guard let node, selectEnabled else { return }
        zoomToSystem(node: node)
    }
    
    // Input Buttons
    
    public func selectSurface() {
        guard let object else { return }
        zoomToSurface(node: object)
    }
    public func selectOrbit() {
        guard let object else { return }
        zoomToOrbit(node: object)
    }
    public func selectSystem() {
        guard let system = object?.system else { return }
        zoomToSystem(node: system)
    }
    public func leaveSystem() {
        guard let object = system?.object else { return }
        zoomToOrbit(node: object)
    }
    
    // Input Configurations
    
    public var hasOrbit: Bool {
        return object != root?.object
    }
    public var hasSystem: Bool {
        return object?.system != nil
    }
    public var stateOrbit: Bool {
        return system != object?.system && !stateSurface
    }
    public var stateSystem: Bool {
        return system == object?.system && !stateSurface
    }
    public var stateSurface: Bool {
        return scale * (object?.totalSize ?? 0) >= (!hasSystem ? 0.05 : 0.25) * size
    }
    
    
    // MARK: - Gestures
    
    // Scale
    
    internal func updateScaleGesture(to value: CGFloat) {
        guard zoomEnabled else { return }
        
        self.gestureScale = value
        
        if let focus, 1.1 * scale * focus.size > size {
            self.gestureScale *= size / (1.1 * scale * focus.size)
        }
        continuousUpdate()
    }
    internal func completeScaleGesture(to value: CGFloat) {
        guard zoomEnabled else { return }
        
        self.steadyScale *= value
        self.gestureScale = 1.0
        
        if let focus, 1.1 * scale * focus.size > size {
            self.steadyScale *= size / (1.1 * scale * focus.size)
        }
        continuousUpdate()
    }
    
    // Orientation
    
    private let translationAngleFactor: CGFloat = .pi / 400
    
    internal func updateRotationGesture(with translation: CGFloat) {
        guard rotateEnabled else { return }
        
        self.gestureRotation = .radians(-translation * translationAngleFactor)
        
        continuousUpdate()
    }
    internal func completeRotationGesture(with translation: CGFloat) {
        guard rotateEnabled else { return }
        
        self.steadyRotation += .radians(-translation * translationAngleFactor)
        self.gestureRotation = .zero
        
        continuousUpdate()
    }
    internal func resetRotation() {
        self.steadyRotation = .zero
    }
    
    internal func updatePitchGesture(with translation: CGFloat) {
        guard rotateEnabled else { return }
        
        self.gesturePitch = .radians(translation * translationAngleFactor)
        
        if steadyPitch + gesturePitch > .zero {
            gesturePitch = -steadyPitch
        }
        if steadyPitch + gesturePitch < -.radians(.pi) {
            gesturePitch = -steadyPitch - .radians(.pi)
        }
        continuousUpdate()
    }
    internal func completePitchGesture(with translation: CGFloat) {
        guard rotateEnabled else { return }
        
        self.steadyPitch += .radians(translation * translationAngleFactor)
        self.gesturePitch = .zero
        
        if steadyPitch > .zero {
            steadyPitch = .zero
        }
        if steadyPitch < -.radians(.pi) {
            steadyPitch = -.radians(.pi)
        }
        continuousUpdate()
    }
    internal func resetPitch() {
        self.steadyPitch = .zero
    }

    
    // MARK: - Navigation Methods`
    
    // Change the focus node
    private func setFocus(_ node: Node?) {
        self.focus = node
    }
    
    // Change the system node
    private func setSystem(_ system: SystemNode?) {
        self.system = system
        if let system, let object, !system.children.map(\.object).contains(object) {
            setObject(nil)
        }
    }
    
    // Change the object node
    private func setObject(_ object: ObjectNode?) {
        self.object = object
        if let object, object == system?.object, let focus, focus != system, focus != object {
            zoomToOrbit(node: focus)
        }
        else if let object, object != focus?.object {
            zoomToOrbit(node: object)
        }
        else if let focus, 0...0.1 ~= offsetAmount {
            zoomToOrbit(node: focus)
        }
    }
    
    // Zoom to a node's surface
    private func zoomToSurface(node: Node) {
        print("zooming to surface of \(node.name)")
        let node = node.object ?? node
        transition(focus: node, size: 2.5 * node.totalSize)
    }
    
    // Zoom to a node's orbital path
    private func zoomToOrbit(node: Node) {
        print("zooming to orbit of \(node.name)")
        let node = node.system ?? node
        transition(focus: node.parent, size: 2.5 * (node.position.magnitude + node.totalSize))
    }
    
    // Zoom to a node's local system
    private func zoomToSystem(node: Node) {
        print("zooming to system of \(node.name)")
        let node = node.object ?? node
        let distance = node.system?.scaleDistance ?? .infinity
        transition(focus: node.parent, size: min(130 * node.size, 2.5 * distance))
    }
    
    
    // MARK: Navigation Logic
    
    // Transition animation
    // Move to a new offset, scale, and focus node
    private func transition(focus: Node?, size: CGFloat) {
        let scale = self.size / size
        guard let focus, scale.isFinite, !inTransition else { return }
        let system = focus.system
        let offset = focus.globalPosition
        let animationTime: Double = 0.5
        
        // Transition conditions
        self.inTransition = true
        DispatchQueue.main.asyncAfter(deadline: .now() + animationTime) {
            self.inTransition = false
        }
        if abs(log10(steadyScale/scale)) > 3 || system != self.system || (focus != self.focus && focus.system != self.focus && self.focus?.system != focus && abs(log10(steadyScale/scale)) > 1) {
            self.inMajorTransition = true
            DispatchQueue.main.asyncAfter(deadline: .now() + animationTime) {
                self.inMajorTransition = false
            }
        }
        
        // Set the focus and system nodes
        setFocus(focus)
        if let system {
            setSystem(system)
        }
        
        // Set the scale and offset
        self.offsetAmount = 1.0
        self.steadyScale = scale
        
        // Transition the entities
        rootEntity.transition(scale: scale, offset: offset, duration: animationTime)
    }
    
    // Navigation changes when gestures occur
    // Controls the focus position, current reference and selected system
    private func continuousUpdate() {
        guard let focus else { return }
        let scaleFactor: CGFloat = 1.2
        self.offsetAmount = 1.0
        
        // Set the offset amount: the percentage which the focus is offset toward the child node
        // e.g. with the Sun as the reference node but Earth selected, offsetAmount = 0.5 would place the central focus halfway between the Earth & Sun
        let totalSize = scale * (focus.position.magnitude + ((object ?? focus.object)?.size ?? .zero) * 2)
        let zoomScale = scaleFactor * totalSize / size
        switch zoomScale {
        case ...0.5:
            offsetAmount *= 0
        case ...1:
            offsetAmount *= zoomScale*2 - 1
        default:
            offsetAmount *= 1.0
        }
        
        // Focus to the child node if zoomed in enough (offset is beginning)
        if let object = object ?? focus.object, let focus = focus as? SystemNode, let childNode = focus.children.first(where: { $0.object == object }) {
            if scaleFactor * scale * (childNode.position).magnitude + scale * object.size * 2 > 0.5 * size {
                setFocus(childNode)
                continuousUpdate()
            }
        }
        // Focus to the parent node if zoomed out enough (offset is ending)
        if let parentNode = focus.parent, zoomScale < 0.5 {
            setFocus(parentNode)
            continuousUpdate()
        }

        // Select the child system if zoomed in enough (the reference node/child system is a system that comprises more than 5% of the screen)
        if focus != system, let childSystem = focus as? SystemNode, let distance = childSystem.scaleDistance, scale * distance > 0.05 * size {
            setSystem(childSystem)
        }
        // Select the parent system if zoomed out enough (the reference node/child system is a system that comprises less than 5% of the screen)
        if let parentSystem = system?.parent, let distance = system?.scaleDistance, scale * distance < 0.05 * size {
            setSystem(parentSystem)
        }
    }
}


