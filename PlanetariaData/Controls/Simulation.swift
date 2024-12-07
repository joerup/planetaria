//
//  Simulation.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 11/7/23.
//

import Foundation
import SwiftUI
import SwiftSPICE
import RealityKit

final public class Simulation: ObservableObject {
    
    public let fileName: String
    public let updateType: UpdateType
    @Published public var viewType: ViewType
    
    @Published public private(set) var status: Status = .uninitialized
    @Published public private(set) var isLoaded: Bool = false
    
    internal var rootEntity = SimulationRootEntity()
    
    // Node Structure
    
    @Published private var root: SystemNode?
    @Published private var focus: Node?
    @Published private var system: SystemNode?
    @Published private var object: ObjectNode?
    
    private var allNodes: [Node] = []
    private var allObjects: [ObjectNode] = []
    
    public var selectedSystem: SystemNode? {
        return system
    }
    public var selectedObject: ObjectNode? {
        return object
    }
    
    public var hasSelection: Bool {
        return object != nil
    }
    public var noSelection: Bool {
        return object == nil
    }
    
    public func isSelected(_ node: Node?) -> Bool {
        return node?.object == object
    }
    internal func isSystem(_ node: Node?) -> Bool {
        return node == system
    }
    internal func isFocus(_ node: Node?) -> Bool {
        return node == focus
    }
    internal func isInSystem(_ node: Node?) -> Bool {
        return node == system || node?.parent == system
    }
    internal func isInFocus(_ node: Node?) -> Bool {
        return node == focus || node?.parent == focus || node?.parent?.object == focus
    }
    
    // Timing
    
    @Published public var time: Date = .now
    
    @Published public var frameRatio: Double = 1.0 { didSet { isRealTime = false } }
    public private(set) var isRealTime: Bool = true
    
    @Published public private(set) var isPaused: Bool = false
    
    public private(set) var maxFrameRatio: Double = 1E+10
    internal let frameRate: Double = 60
    
    @Published public var minTime: Date = .year(2000)
    @Published public var maxTime: Date = .year(2050)
    
    // Settings
    
    public var showOrbits: Bool = true
    public var showLabels: Bool = true
    public var showFloodLights: Bool = false
    
    public var selectEnabled: Bool = true
    public var zoomEnabled: Bool = true
    public var rotateEnabled: Bool = true
    
    // Transformations
    
    private(set) var size: Double = 1 // (will be set dynamically during setup)
    
    @Published private(set) var offsetAmount: Double = 1.0
    @Published private(set) var offset: Vector3 = .zero
    
    @Published private var steadyScale: Double = 1.0
    @Published private var gestureScale: Double = 1.0
    internal var scale: Double {
        steadyScale * gestureScale
    }
    
    @Published private var steadyRotation: Angle = .zero
    @Published private var gestureRotation: Angle = .zero
    internal var rotation: Angle {
        steadyRotation + gestureRotation
    }
    
    @Published private var steadyPitch: Angle = .zero
    @Published private var gesturePitch: Angle = .zero
    internal var pitch: Angle {
        steadyPitch + gesturePitch
    }
    
    @Published private var steadyRoll: Angle = .zero
    @Published private var gestureRoll: Angle = .zero
    internal var roll: Angle {
        steadyRoll + gestureRoll
    }
    
    internal var orientation: simd_quatf {
        simd_quatf(angle: Float(pitch.radians), axis: [1,0,0]) * simd_quatf(angle: Float(-rotation.radians), axis: [0,1,0])
    }
    
    private let zoomObjectCoefficient: Double = 2.4
    private let zoomOrbitCoefficient: Double = 2.5
    
    private var transition: Transition?
    private var animationTime: Double {
        switch viewType {
        case .fixed:
            0.6
        case .augmented:
            0.8
        case .immersive:
            1.2
        }
    }
    
    
    // MARK: - Setup
    
    // Initialize the simulation
    @MainActor public init(from fileName: String, updateType: UpdateType) {
        self.fileName = fileName
        self.updateType = updateType
        
        #if os(iOS) || os(macOS)
        viewType = .fixed
        #elseif os(visionOS)
        viewType = .immersive
        #endif
        
        load()
        
        Entity.registerAll()
        rootEntity.simulation = self
    }
    
    // Load the simulation
    // (this is done by the initializer but may be done externally if it failed at first)
    @MainActor public func load() {
        status = .uninitialized
        isLoaded = false
        
        Task {
            do {
                try await loadData(fileName: fileName)
                status = .loaded
                isLoaded = true
            } catch let error as SimulationError {
                print(error.text)
                status = .error(error)
            } catch {
                print("An unknown error occurred: \(error)")
                status = .error(.unknown)
            }
        }
    }
    
    // Load data from node file and ephemeris, then create entities
    @MainActor private func loadData(fileName: String) async throws {
        
        // Decode the tree from the file
        status = .decodingNodes
        guard let file = Bundle.main.path(forResource: fileName, ofType: "json"),
              let json = try? String(contentsOfFile: file),
              let data = json.data(using: .utf8),
              let root = try? JSONDecoder().decode(SystemNode.self, from: data)
        else {
            throw SimulationError.nodeDecodingFailed
        }
        
        self.root = root
        self.focus = root
        self.system = root
        
        self.allNodes = root.tree
        self.allObjects = root.tree.compactMap({ $0 as? ObjectNode })
        
        // Load the ephemerides
        status = .loadingEphemerides
        switch updateType {
        case .spice:
            
            // Load the SPK kernel
            guard let kernel = Bundle.main.path(forResource: fileName, ofType: "bsp") else {
                throw SimulationError.ephemerisNotFound
            }
            do {
                try SPICE.loadKernel(kernel)
            } catch {
                throw SimulationError.ephemerisLoadingFailed
            }
            
            // Set each node's initial state from SPICE
            for node in allNodes {
                node.setStateFromSPICE(to: time)
            }
            
            // Set orbits for all nodes
            for node in allNodes {
                node.setOrbit()
            }
            
            // Set SPICE timesteps for all nodes
            for node in allNodes {
                if let orbit = node.orbit {
                    node.spiceStep = orbit.period * Node.spiceStepFraction
                }
            }
            
        case .integration:
            
            // Initial states are loaded already via decoder
            
            // Set orbits for all nodes
            for node in allNodes {
                node.setOrbit()
            }
            
            // Set integration timesteps for all nodes
            for node in allNodes {
                if let orbit = node.orbit {
                    node.integrationStep = orbit.period * Node.integrationStepFraction
                }
            }
            
            // Recursively set integration timesteps for the system tree
            root.setIntegrationStep()
        }
        
        // Set the rotational states
        for node in allNodes {
            node.rotation?.set(time: time)
        }
        
        // Set the size parameter
        // (this makes the default scale (1.0) represent the size of the root's primary system)
        size = zoomOrbitCoefficient * root.primaryScaleDistance
        
        // Load the entities for RealityKit
        status = .creatingEntities
        for node in allNodes {
            let _ = await SimulationEntity(node: node, size: size, root: rootEntity)
        }
    }
    
    
    // MARK: - Updates
    
    // Advance the system by the time interval
    internal func advance() {
        guard !isPaused else { isRealTime = false; return }
        var dt: Double
        
        // Advance to match real time
        if isRealTime {
            dt = -time.timeIntervalSinceNow
        }
        // Advance by a custom rate
        else {
            dt = frameRatio/frameRate
            
            if dt >= -time.timeIntervalSince(maxTime) {
                dt = -time.timeIntervalSince(maxTime)
                frameRatio = 0.0
            }
            if dt <= -time.timeIntervalSince(minTime) {
                dt = -time.timeIntervalSince(minTime)
                frameRatio = 0.0
            }
        }
        
        // Add the time interval
        self.time.addTimeInterval(dt)
        
        // Update positions and velocities
        switch updateType {
        case .spice:
            // Set states from SPICE
            // Only guarantee the update for nodes in the current system
            for node in allNodes {
                if let parent = node.parent, parent == system || parent == system?.parent || parent == transition?.originalFocus || parent == transition?.originalFocus?.parent {
                    node.setStateFromSPICE(by: dt, to: time, guaranteedUpdate: node == system || parent == system)
                }
            }
        case .integration:
            // Recursively integrate each node's state
            root?.integrate(by: dt)
        }
        
        // Update orbit and rotation states
        for node in allNodes {
            node.orbit?.update(node: node)
            node.rotation?.update(timeStep: dt)
        }
    }
    
    // Set the system to a specific timestamp
    internal func setTimestamp(_ timestamp: Date) {
        guard let root, timestamp >= minTime, timestamp <= maxTime else { return }
        
        isPaused = false
        isRealTime = false
        
        // Advance states to the given timestamp
        let dt = timestamp.timeIntervalSince(time)
        time.addTimeInterval(dt)
        
        // Update positions and velocities
        switch updateType {
        case .spice:
            // Set each node's state from SPICE
            for node in allNodes {
                node.setStateFromSPICE(by: dt, to: time)
            }
        case .integration:
            // Recursively integrate each node's state
            root.integrate(by: dt)
        }
        
        // Update orbit and rotation states
        for node in allNodes {
            node.orbit?.update(node: node)
            node.rotation?.update(timeStep: dt)
        }
    }
    
    // Update the simulation transformations
    internal func updateTransformations() {
        if let transition {
            transition.nextFrame()
            
            self.steadyScale = transition.scale
            self.offset = transition.offset
            
            if transition.isComplete {
                self.transition = nil
                updateAfterGesture()
            }
        } else {
            self.offset = focus?.globalPositionAtFraction(offsetAmount) ?? .zero
        }
    }
    
    
    // MARK: - Reset
    
    // Reset the simulation
    public func resetState() {
        focus = root
        system = root
        
        setTimestamp(.now)
        frameRatio = 1
        isRealTime = true
        
        offset = .zero
        offsetAmount = 1.0
        steadyRotation = .zero
        gestureRotation = .zero
        steadyScale = 1.0
        gestureScale = 1.0
    }
    
    
    // MARK: - External Inputs
    
    // Clock Buttons
    
    public func pause() {
        isPaused.toggle()
    }
    
    public func increaseSpeed() {
        if isPaused {
            frameRatio = 1
            isPaused = false
        }
        switch frameRatio {
        case 0, 1: frameRatio = 100
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
        if isPaused {
            frameRatio = 1
            isPaused = false
        }
        switch frameRatio {
        case 0, 1: frameRatio = -100
        case 100: frameRatio = 1
        case ...(-100): frameRatio *= 10
        case (100)...: frameRatio /= 10
        default: frameRatio = 1
        }
        if abs(frameRatio) >= maxFrameRatio {
            frameRatio = -maxFrameRatio
        }
    }
    
    public func setTime(_ timestamp: Date) {
        guard timestamp >= minTime, timestamp <= maxTime else { return }
        setTimestamp(timestamp)
        frameRatio = 1
    }
    
    public func resetTime() {
        setTimestamp(.now)
        frameRatio = 1
        isRealTime = true
    }
    
    // Select Buttons
    
    public func selectObject(_ node: Node?) {
        guard transition == nil else { return }
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
    
    // Navigation Buttons
    
    public func selectSurface() {
        guard let object, transition == nil else { return }
        zoomToSurface(node: object)
    }
    public func selectOrbit() {
        guard let object, transition == nil else { return }
        zoomToOrbit(node: object)
    }
    public func selectSystem() {
        guard let system = object?.system, transition == nil else { return }
        zoomToSystem(node: system)
    }
    public func leaveSystem() {
        guard let object = system?.object, transition == nil else { return }
        zoomToOrbit(node: object)
    }
    
    // Navigation Configurations
    
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
    
    // Object Query
    
    public func queryObjects(_ string: String) -> [ObjectNode] {
        guard !string.isEmpty else { return [] }
        let query = string.lowercased()
        return allObjects.filter({ $0.name.lowercased().starts(with: query) })
            .sorted(by: { $0.category < $1.category })
            .sorted(by: { $0.rank > $1.rank })
    }
    
    
    // MARK: - External Gestures
    
    // Scale
    
    internal func updateScaleGesture(to value: CGFloat) {
        guard zoomEnabled else { return }
        
        self.gestureScale = value
        
        if let focus, 1.1 * scale * focus.size > size {
            self.gestureScale *= size / (1.1 * scale * focus.size)
        }
        updateAfterGesture()
    }
    internal func completeScaleGesture(to value: CGFloat) {
        guard zoomEnabled else { return }
        
        self.steadyScale *= value
        self.gestureScale = 1.0
        
        if let focus, 1.1 * scale * focus.size > size {
            self.steadyScale *= size / (1.1 * scale * focus.size)
        }
        updateAfterGesture()
    }
    
    // Orientation
    
    private var minPitchAngle: Angle {
        switch viewType {
        case .fixed:
            return -.radians(.pi)
        case .augmented:
            return .zero
        case .immersive:
            return -.radians(.pi/2)
        }
    }
    private var maxPitchAngle: Angle {
        switch viewType {
        case .fixed:
            return .zero
        case .augmented:
            return .zero
        case .immersive:
            return .radians(.pi/2)
        }
    }
    private var minRollAngle: Angle {
        switch viewType {
        case .fixed, .immersive:
            return -.radians(.pi/2)
        case .augmented:
            return .zero
        }
    }
    private var maxRollAngle: Angle {
        switch viewType {
        case .fixed, .immersive:
            return .radians(.pi/2)
        case .augmented:
            return .zero
        }
    }
    
    internal func updateRotationGesture(with angle: Angle) {
        guard rotateEnabled else { return }
        
        self.gestureRotation = angle
        
        updateAfterGesture()
    }
    internal func completeRotationGesture(with angle: Angle) {
        guard rotateEnabled else { return }
        
        self.steadyRotation += angle
        self.gestureRotation = .zero
        
        updateAfterGesture()
    }
    internal func resetRotation() {
        self.steadyRotation = .zero
    }
    
    internal func updatePitchGesture(with angle: Angle) {
        guard rotateEnabled else { return }
        
        self.gesturePitch = angle
        
        if steadyPitch + gesturePitch > maxPitchAngle {
            gesturePitch = -steadyPitch + maxPitchAngle
        }
        if steadyPitch + gesturePitch < minPitchAngle {
            gesturePitch = -steadyPitch + minPitchAngle
        }
        updateAfterGesture()
    }
    internal func completePitchGesture(with angle: Angle) {
        guard rotateEnabled else { return }
        
        self.steadyPitch += angle
        self.gesturePitch = .zero
        
        if steadyPitch > maxPitchAngle {
            steadyPitch = maxPitchAngle
        }
        if steadyPitch < minPitchAngle {
            steadyPitch = minPitchAngle
        }
        updateAfterGesture()
    }
    internal func resetPitch() {
        self.steadyPitch = .zero
    }
    
    internal func updateRollGesture(with angle: Angle) {
        guard rotateEnabled else { return }
        
        self.gestureRoll = angle
        
        if steadyRoll + gestureRoll > maxRollAngle {
            gestureRoll = -steadyRoll + maxRollAngle
        }
        if steadyRoll + gestureRoll < minRollAngle {
            gestureRoll = -steadyRoll + minRollAngle
        }
        updateAfterGesture()
    }
    internal func completeRollGesture(with angle: Angle) {
        guard rotateEnabled else { return }
        
        self.steadyRoll += angle
        self.gestureRoll = .zero
        
        if steadyRoll > maxRollAngle {
            steadyRoll = maxRollAngle
        }
        if steadyRoll < minRollAngle {
            steadyRoll = minRollAngle
        }
        updateAfterGesture()
    }
    internal func resetRoll() {
        self.steadyRoll = .zero
    }
    
    
    // MARK: - Private Transition Methods
    
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
        if let object {
            self.object = object
            if let focus, object != focus, object == object.system?.object, focus.parent == object.system {
                zoomToOrbit(node: focus)
            }
            else if let focus, object != focus, object == object.system?.object, focus.parent?.parent == object.system {
                zoomToOrbit(node: focus.parent ?? focus)
            }
            else if object != focus?.object {
                zoomToOrbit(node: object)
            }
        }
        else if let object = self.object {
            self.object = object.parent == root ? nil : object.hostNode == object.parent?.object ? object.hostNode : nil
            if object == focus?.object || focus != (object.system ?? object).parent {
                zoomToOrbit(node: object)
            }
        }
    }
    
    // Zoom to a node's surface
    private func zoomToSurface(node: Node) {
        print("zooming to surface of \(node.name)")
        let node = node.object ?? node
        transition(focus: node, size: zoomObjectCoefficient * (viewType == .immersive ? node.size : node.totalSize))
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
    
    
    // MARK: - Private Update Methods
    
    // Transition animation
    // Move to a new offset, scale, and focus node
    private func transition(focus: Node?, size: Double) {
        let scale = self.size / size
        guard let focus, scale.isFinite else { return }
        let system = focus.system
        
        let originalScale = self.scale
        let originalFocus = self.focus
        
        // Set the focus and system nodes
        setFocus(focus)
        if let system {
            setSystem(system)
        }
        
        // Transition the entities
        let frames = Int(animationTime * frameRate)
        self.transition = Transition(frames: frames, originalScale: originalScale, originalFocus: originalFocus, originalOffsetAmount: offsetAmount, targetScale: scale, targetFocus: focus)
        
        // Update the saved offset and scale
        self.offsetAmount = 1.0
    }
    
    // Navigation changes when gestures occur
    // Controls the focus position, current reference and selected system
    private func updateAfterGesture() {
        guard let focus else { return }
        
        let orbitWeight: Double = 1.2
        let objectWeight: Double = 4.0
        
        // Set the offset amount: the percentage which the focus is offset toward the child node
        // e.g. with the Sun as the reference node but Earth selected, offsetAmount = 0.5 would place the central focus halfway between the Earth & Sun
        let objectSize = (object ?? focus.object)?.size ?? .zero
        let totalSize = scale * max(orbitWeight * focus.position.magnitude, objectWeight * 2 * objectSize)
        let zoomScale = totalSize / size
        
        // Set the offset amount based on a nonlinear parameterization of the zoom scale
        let t = min(1, max(0, (zoomScale*2 - 1)))
        offsetAmount = 1 - pow(1 - t, 4)
        
        // Focus to the child node if zoomed in enough (offset is beginning)
        if let object = object ?? focus.object, let focus = focus as? SystemNode, let childNode = focus.children.first(where: { $0.object == object }) {
            if scale * max(orbitWeight * childNode.position.magnitude, objectWeight * 2 * object.size) > 0.5 * size {
                setFocus(childNode)
                updateAfterGesture()
            }
        }
        // Focus to the parent node if zoomed out enough (offset is ending)
        if let parentNode = focus.parent, zoomScale < 0.5 {
            setFocus(parentNode)
            updateAfterGesture()
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
    
    
    // MARK: - Types
    
    private class Transition: Hashable {
        
        private let id = UUID()
        private let totalFrames: Int
        private var completedFrames: Int = 0
        
        private(set) var originalScale: Double
        private(set) var originalFocus: Node?
        private(set) var originalOffsetAmount: Double
        private(set) var targetScale: Double
        private(set) var targetFocus: Node?
        
        var scale: Double = 1.0
        var offset: Vector3 = .zero
        
        var isComplete: Bool {
            completedFrames == totalFrames
        }
        
        init(frames: Int, originalScale: Double, originalFocus: Node?, originalOffsetAmount: Double = 1.0, targetScale: Double, targetFocus: Node?) {
            self.totalFrames = frames
            self.originalScale = originalScale
            self.originalFocus = originalFocus
            self.originalOffsetAmount = originalOffsetAmount
            self.targetScale = targetScale
            self.targetFocus = targetFocus
        }
        
        func nextFrame() {
            let t = Double(completedFrames) / Double(totalFrames)
            let k = t < 0.5 ? (4 * pow(t, 3)) : (1 - pow(-2 * t + 2, 3) / 2)
            
            scale = exp(log(originalScale) * (1 - k) + log(targetScale) * k)
            
            let r = targetScale / originalScale
            let w = r == 1 ? k : (pow(r, k) - 1) / (r - 1)
            
            let originalOffset = originalFocus?.globalPositionAtFraction(originalOffsetAmount) ?? .zero
            let targetOffset = targetFocus?.globalPosition ?? .zero
            
            offset = originalOffset * (originalScale / scale) * (1 - w) + targetOffset * (targetScale / scale) * w
            
            completedFrames += 1
        }
        
        static func == (lhs: Transition, rhs: Transition) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    public enum ViewType {
        
        // scaled based on a fixed box on a screen
        // gestures applied on any part of the screen
        // allows full rotation & pitch from -90 to 90
        // billboards point toward the screen plane
        // used for iOS/macOS by default
        case fixed
        
        // scaled based on a fixed box in AR
        // gestures applied on any part of the screen
        // allows full rotation but no pitch
        // billboards point toward the camera point
        // used for iOS in AR mode
        case augmented
        
        // scaled to its true size
        // center set to a sufficient far-away distance
        // allows full rotation and pitch
        // billboards point toward the camera point
        // used for visionOS
        case immersive
        
    }
    
    public enum UpdateType {
        
        // uses SPICE to access state
        // initial state input directly from SPICE
        case spice
        
        // uses numerical n-body integration to access state
        // initial state input from decoded json
        case integration
        
    }

    public enum Status {
        case uninitialized
        case decodingNodes
        case loadingEphemerides
        case creatingEntities
        case fetchingContent
        case loaded
        case error(SimulationError)
        
        public var text: String {
            switch self {
            case .uninitialized:
                "Starting"
            case .decodingNodes:
                "Loading object data"
            case .loadingEphemerides:
                "Loading orbit data"
            case .creatingEntities:
                "Creating models"
            case .fetchingContent:
                "Fetching additional content"
            case .loaded:
                "Loaded"
            case .error(_):
                "Error"
            }
        }
    }
    
    public enum SimulationError: Error {
        case nodeDecodingFailed
        case ephemerisNotFound
        case ephemerisLoadingFailed
        case unknown
        
        public var text: String {
            switch self {
            case .nodeDecodingFailed:
                "Error decoding nodes from file"
            case .ephemerisNotFound:
                "Error: ephemeris not found"
            case .ephemerisLoadingFailed:
                "Error loading ephemeris"
            case .unknown:
                "An unknown error occurred"
            }
        }
        
        public var detailText: String {
            "Please try again later. If the issue persists,"
        }
    }
}


