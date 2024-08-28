//
//  Simulation.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 11/7/23.
//

import Foundation
import SwiftUI
import RealityKit

final public class Simulation: ObservableObject {
    
    // MARK: - Setup
    
    @Published public private(set) var status: Status
    @Published public private(set) var isLoaded: Bool
    
    public init(from fileName: String) {
        status = .uninitialized
        isLoaded = false
        
        Task {
            // Decode the tree from the file
            await MainActor.run {
                status = .decodingNodes
            }
            guard let file = Bundle.main.path(forResource: fileName, ofType: "json"),
                  let json = try? String(contentsOfFile: file),
                  let data = json.data(using: .utf8),
                  let root = try? JSONDecoder().decode(SystemNode.self, from: data)
            else {
                print("Error decoding nodes")
                return
            }
            
            // Create the node references
            await MainActor.run {
                self.title = fileName
                self.root = root
                self.focus = root
                self.system = root
            }
            print("Finished decoding nodes")
            
            // Load the ephemerides
            await MainActor.run {
                status = .loadingEphemerides
            }
            await loadEphemerides()
            print("Finished loading ephemerides")
            
            // Set the initial positioning parameters
            await MainActor.run {
                let distance = root.children.filter({ $0.rank == .primary }).map(\.position.magnitude).max() ?? 1
                size = 2.5 * distance
            }
            
            // Generate the scene
            await MainActor.run {
                status = .creatingEntities
            }
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
            await MainActor.run {
                status = .fetchingContent
            }
            let photos = await Photo.decode(from: "\(fileName)-photos")
            for object in root.tree.compactMap({ $0 as? ObjectNode }) {
                let matchingPhotos = photos.filter({ $0.id == object.id })
                object.properties?.photos = matchingPhotos
            }
            
            // Complete
            await MainActor.run {
                self.run()
                self.isLoaded = true
                status = .loaded
                print("Finished setup")
            }
        }
        
        Entity.registerAll()
        rootEntity.simulation = self
    }
    
    
    // MARK: - Structure
    
    public private(set) var title: String = ""
    
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
    
    public func pointVisible(_ node: Node) -> Bool {
        showLabels && !(system == node)
    }
    public func trailVisible(_ node: Node) -> Bool {
        /*!inMajorTransition && */showOrbits && !((node == focus || node.object == focus || node == focus?.parent) && (scale * 10 * node.size > size || scale * 10 * (node.system?.primaryScaleDistance ?? 0) > size))
    }
    public func labelVisible(_ node: Node) -> Bool {
        showLabels && (node.parent == system || node.parent == system?.parent) &&
        (isSelected(node) || node.rank >= .secondary) &&
        (node.system == system || 2 * scale * node.position.magnitude > 100 * rootEntity.pixelSize) &&
        (scale * node.size * 75 < size || (node != focus && node.system != focus)) &&
        node != system
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
    
    // Orientation
    internal var orientation: simd_quatf {
        simd_quatf(angle: Float(pitch.radians), axis: [1,0,0]) * simd_quatf(angle: Float(-rotation.radians), axis: [0,1,0])
    }
    
    
    // MARK: - Settings
    
    @Published public var time: Date = .now
    @Published public var frameRatio: Double = 1.0 { didSet { isRealTime = false } }
    @Published public var frameInterval: Double = 0.1
    public var isRealTime: Bool = true
    public var maxFrameRatio: Double = 1E+7
    
    public var arMode: Bool = false
    public var showOrbits: Bool = true
    public var showLabels: Bool = true
    
    public var selectEnabled: Bool = true
    public var zoomEnabled: Bool = true
    public var rotateEnabled: Bool = true
    
    
    // MARK: - Motion
    
    private func loadEphemerides() async {
        let urlStr = "https://script.google.com/macros/s/AKfycbwnEMsgrHDoboUKHZljiLycXQ-GOvHdehYHQANEftj41azbkNaeAJiIBwdORo7wUlwX/exec"
        guard let root, let url = URL(string: urlStr) else { return }
        
        var states: [Int : StateVector] = [:]
        
        // Make the API call
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let string = String(decoding: data, as: UTF8.self)
            let ephemerides = string.split(separator: "\n")
            guard ephemerides.count >= 2 else { return }
            
            // Set the timestamp
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MMM-dd-HH:mm:ss.SSSS"
            formatter.timeZone = .gmt
            if let timestamp = ephemerides[0].split(separator: ",").first, let time = formatter.date(from: String(timestamp)) {
                print("time: \(time)")
                await MainActor.run {
                    self.time = time
                }
            }
            
            for i in 1 ..< ephemerides.count {
                let ephemerisData = ephemerides[i].split(separator: ",")
                
                // Parse the ephemeris data
                guard ephemerisData.count >= 8,
                  let id = Int(ephemerisData[0]),
                  let x = Double(ephemerisData[2]),
                  let y = Double(ephemerisData[3]),
                  let z = Double(ephemerisData[4]),
                  let vx = Double(ephemerisData[5]),
                  let vy = Double(ephemerisData[6]),
                  let vz = Double(ephemerisData[7])
                else {
                    continue
                }
                
                // Hash the state vector
                let stateVector = StateVector(position: [x,y,z], velocity: [vx,vy,vz])
                states[id] = stateVector
            }
        } catch {
            print(error)
        }
        
        // Set the ephemeris for each node
        for node in root.tree {
            if let stateVector = states[node.id] {
                node.set(state: stateVector)
            }
        }
    }
    
    private func run() {
        Timer.scheduledTimer(withTimeInterval: frameInterval, repeats: true) { _ in
            let dt = self.frameInterval * self.frameRatio
            self.time.addTimeInterval(dt)
            self.root?.advanceSystem(by: dt)
            self.synchronize()
        }
    }
    
    private func synchronize() {
        guard isRealTime else { return }
        if time < .now {
            self.time.addTimeInterval(-time.timeIntervalSinceNow)
            self.root?.advanceSystem(by: -time.timeIntervalSinceNow)
        }
    }
    
    
    // MARK: - Inputs
    
    // Clock Buttons
    
    public func increaseSpeed() {
        switch frameRatio {
        case 1: frameRatio = 100
        case -100: frameRatio = 1
        case ...(-100): frameRatio /= 10
        case (100)...: frameRatio *= 10
        default: frameRatio = 1
        }
        if abs(frameRatio) >= maxFrameRatio {
            frameRatio = maxFrameRatio
        }
    }
    
    public func decreaseSpeed() {
        switch frameRatio {
        case 1: frameRatio = -100
        case 100: frameRatio = 1
        case ...(-100): frameRatio *= 10
        case (100)...: frameRatio /= 10
        default: frameRatio = 1
        }
        if abs(frameRatio) >= maxFrameRatio {
            frameRatio = -maxFrameRatio
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
    
    private let zoomObjectCoefficient: CGFloat = 2.4
    private let zoomOrbitCoefficient: CGFloat = 2.5
    
    // Zoom to a node's surface
    private func zoomToSurface(node: Node) {
        print("zooming to surface of \(node.name)")
        let node = node.object ?? node
        transition(focus: node, size: zoomObjectCoefficient * node.totalSize)
    }
    
    // Zoom to a node's orbital path
    private func zoomToOrbit(node: Node) {
        print("zooming to orbit of \(node.name)")
        let node = node.system ?? node
        let ratio = zoomOrbitCoefficient * scale * (node.position.magnitude + node.totalSize) / size
        let fraction = max(0.7, min(1.0, ratio))
        transition(focus: node.parent, size: zoomOrbitCoefficient / fraction * (node.position.magnitude + node.totalSize))
    }
    
    // Zoom to a node's local system
    private func zoomToSystem(node: Node) {
        print("zooming to system of \(node.name)")
        let node = node.object ?? node
        let distance = node.system?.primaryScaleDistance ?? .infinity
        transition(focus: node.parent, size: zoomOrbitCoefficient * distance)
    }
    
    
    // MARK: - Navigation Logic
    
    // Transition animation
    // Move to a new offset, scale, and focus node
    private func transition(focus: Node?, size: CGFloat) {
        let scale = self.size / size
        guard let focus, scale.isFinite, !inTransition else { return }
        let system = focus.system
        let offset = focus.globalPosition
        
        // Transition conditions
        self.inTransition = true
        DispatchQueue.main.asyncAfter(deadline: .now() + rootEntity.animationTime) {
            self.inTransition = false
        }
        if abs(log10(steadyScale/scale)) > 3 || system != self.system || (focus != self.focus && focus.system != self.focus && self.focus?.system != focus && abs(log10(steadyScale/scale)) > 1) {
            self.inMajorTransition = true
            DispatchQueue.main.asyncAfter(deadline: .now() + rootEntity.animationTime) {
                self.inMajorTransition = false
            }
        }
        
        // Set the focus and system nodes
        setFocus(focus)
        if let system {
            setSystem(system)
        }
        
        // Transition the entities
        rootEntity.transition(scale: scale, offset: offset)
        
        // Update the saved offset and scale
        self.offsetAmount = 1.0
        self.steadyScale = scale
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
        if focus != system, let childSystem = focus as? SystemNode, scale * childSystem.scaleDistance > 0.05 * size || scale * childSystem.primaryScaleDistance > 0.01 * size {
            setSystem(childSystem)
        }
        // Select the parent system if zoomed out enough (the reference node/child system is a system that comprises less than 5% of the screen)
        if let system, let parentSystem = system.parent, scale * system.scaleDistance < 0.05 * size && scale * system.primaryScaleDistance < 0.01 * size {
            setSystem(parentSystem)
        }
    }

    public enum Status {
        case uninitialized
        case decodingNodes
        case loadingEphemerides
        case creatingEntities
        case fetchingContent
        case loaded
    }
}


