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
            
            // Generate the background
//            if let background = await Entity.generateBackground() {
//                await rootEntity.addChild(background)
//            }
            
            // Load the entities
            for node in root.tree {
                let entity = await SimulationEntity(node: node, size: size)
                await MainActor.run { rootEntity.addChild(entity) }
            }
            print("Finished creating entities")
            
            await MainActor.run {
                self.isLoaded = true
                self.run()
            }
        }
        
        BodyComponent.registerComponent()
        LabelComponent.registerComponent()
        LightComponent.registerComponent()
        OrbitComponent.registerComponent()
        PointComponent.registerComponent()
        
        rootEntity.simulation = self
        SimulationComponent.registerComponent()
        SimulationSystem.registerSystem()
    }
    
    
    // MARK: - Structure
    
    internal var rootEntity = SimulationRootEntity()
    
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
    
    
    // MARK: - Settings
    
    @Published public var time: Date = .now
    @Published public var timeStep: Double = 0.01
    @Published public var timeRatio: Double = 1.0 { didSet { isRealTime = false } }
    public private(set) var isRealTime: Bool = true
    public var maxTimeRatio: Double = 1E+5
    
    public var arMode: Bool = false
    public var floodLighting: Bool = false
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
    
    // Select Button
    
    public func select(_ node: Node?) {
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

    
    // MARK: - Navigation Methods
    
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
        update(focus: node, size: 2.5 * node.totalSize)
    }
    
    // Zoom to a node's orbital path
    private func zoomToOrbit(node: Node) {
        print("zooming to orbit of \(node.name)")
        let node = node.system ?? node
        update(focus: node.parent, size: 2.5 * (node.position.magnitude + node.totalSize))
    }
    
    // Zoom to a node's local system
    private func zoomToSystem(node: Node) {
        print("zooming to system of \(node.name)")
        let node = node.object ?? node
        let distance = node.siblings.filter({ $0.rank == .primary }).map(\.position.magnitude).max() ?? .infinity
        update(focus: node.parent, size: min(130 * node.size, 2.5 * distance))
    }
    
    
    // MARK: Navigation Logic
    
    // Transition animation
    // Move to a new offset, scale, and focus node
    private func update(focus: Node?, size: CGFloat) {
        let scale = self.size / size
        guard let focus, scale.isFinite else { return }
        let system = focus.system
        let offset = focus.globalPosition
        
        // Set the focus and system nodes
        setFocus(focus)
        if let system {
            setSystem(system)
        }
        
        // Set the scale and offset
        self.offsetAmount = 1.0
        self.steadyScale = scale
        
        // Update the entities
        rootEntity.transition(scale: scale, offset: offset, duration: 0.5)
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



//public func showNode(_ node: Node, scale: CGFloat, offset: Vector) -> Bool {
//    guard node.isSet, node.parent == system /*|| node.matches(system)*/ else { return false }
//    let location = scale/self.scale * transform(node.globalPosition - (offset-self.offset))
//    return node.system == system || (location.isWithin(10*size) && applyScale(node.position.magnitude + node.size) * scale/self.scale * 500 > size)
//}
//public func showBody(_ node: Node, scale: CGFloat, offset: Vector) -> Bool {
//    let location = scale/self.scale * transform(node.globalPosition - (offset-self.offset))
//    return location.isWithin(10*size) && 3...max(4, size) ~= applyScale(node.size) * scale/self.scale
//}
//public func showOrbit(_ node: Node) -> Bool {
//    return !inTransition && node.orbit != nil && node.parent == system && node.system != system
//}
//
//public func trailVisibility(_ node: Node) -> CGFloat {
//    return !inTransition && applyScale(node.position.magnitude) < 2 * size && (applyScale(node.size) * 50 < size) ? 1 : 0
//}
//public func textVisibility(_ node: Node) -> CGFloat {
//    return !inTransition && node.parent == system && ((node.system == system || 2 * applyScale(node.position.magnitude) > max(0.1 * size, 50)) && (applyScale(node.size) * 10 < size)) ? 1 : 0
//}