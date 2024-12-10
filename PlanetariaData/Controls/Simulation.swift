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
    
    @Published var root: SystemNode?
    @Published var focus: Node?
    @Published var system: SystemNode?
    @Published var object: ObjectNode?
    
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
    
    // Clock
    
    @Published public var time: Date = .now
    
    @Published public var frameRatio: Double = 1.0 { didSet { isRealTime = false } }
    public internal(set) var isRealTime: Bool = true
    
    @Published public internal(set) var isPaused: Bool = false
    
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
    
    // Camera State
    
    private(set) var size: Double = 1 // (will be set dynamically during setup)
    
    @Published var offsetAmount: Double = 1.0
    @Published var offset: Vector3 = .zero
    
    @Published var steadyScale: Double = 1.0
    @Published var gestureScale: Double = 1.0
    var scale: Double {
        steadyScale * gestureScale
    }
    
    @Published var steadyRotation: Angle = .zero
    @Published var gestureRotation: Angle = .zero
    var rotation: Angle {
        steadyRotation + gestureRotation
    }
    
    @Published var steadyPitch: Angle = .zero
    @Published var gesturePitch: Angle = .zero
    var pitch: Angle {
        steadyPitch + gesturePitch
    }
    
    @Published var steadyRoll: Angle = .zero
    @Published var gestureRoll: Angle = .zero
    var roll: Angle {
        steadyRoll + gestureRoll
    }
    
    var orientation: simd_quatf {
        simd_quatf(angle: Float(pitch.radians), axis: [1,0,0]) * simd_quatf(angle: Float(-rotation.radians), axis: [0,1,0])
    }
    
    let zoomObjectCoefficient: Double = 2.4
    let zoomOrbitCoefficient: Double = 2.5
    
    var transition: Transition?
    var animationTime: Double {
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
    @MainActor public init(from fileName: String, viewType: ViewType, updateType: UpdateType) {
        self.fileName = fileName
        self.viewType = viewType
        self.updateType = updateType
        
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
    func advance() {
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
    func setTimestamp(_ timestamp: Date) {
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
    func updateTransformations() {
        if let transition {
            transition.nextFrame()
            
            self.steadyScale = transition.scale
            self.steadyRotation = transition.rotation
            self.steadyPitch = transition.pitch
            self.offset = transition.offset
            
            if transition.isComplete {
                self.transition = nil
                updateAfterGesture()
            }
        } else {
            self.offset = focus?.globalPositionAtFraction(offsetAmount) ?? .zero
        }
    }

    // MARK: - Other
    
    // Access a node with a given name
    public func getNode(_ string: String) -> Node? {
        guard !string.isEmpty else { return nil }
        return allNodes.filter({ $0.name == string }).first
    }
    
    // Query objects whose name matches a string
    public func queryObjects(_ string: String) -> [ObjectNode] {
        guard !string.isEmpty else { return [] }
        let query = string.lowercased()
        return allObjects.filter({ $0.name.lowercased().starts(with: query) })
            .sorted(by: { $0.category < $1.category })
            .sorted(by: { $0.rank > $1.rank })
    }
    
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
}


