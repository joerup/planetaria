//
//  SimulationRootEntity.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 8/28/24.
//

import Foundation
import RealityKit
import SwiftUI
#if os(visionOS)
import ARKit
#endif

class SimulationRootEntity: Entity {
    
    var simulation: Simulation?
    
    // Scene entities
    let sceneBackground = SceneBackground()
    let cameraMarker = CameraMarker()
    
    // Debug mode
    let debugMode: Bool = false
    
    // Display parameters
    private(set) var entityThickness: Float = 0.005 // apparent thickness (in meters) of a uniformly-scaled entity
    private(set) var pixelSize: CGFloat = 100 // simulated size represented by one UI point
    
    // Platform-specific properties
    #if os(iOS) || os(macOS)
    var arView: ARView?
    var cameraState: (SIMD3<Float>, SIMD3<Float>) {
        let position = globalPosition(arView?.cameraTransform.translation ?? .zero)
        let direction = arView?.cameraTransform.rotation.act(globalDirection) ?? globalDirection
        return (position, direction)
    }
    #elseif os(visionOS)
    private let arKitSession = ARKitSession()
    private let worldTrackingProvider = WorldTrackingProvider()
    var cameraState: (SIMD3<Float>, SIMD3<Float>) {
        guard let pose = worldTrackingProvider.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) else { return (.zero, globalDirection) }
        let cameraTransform = Transform(matrix: pose.originFromAnchorTransform)
        let position = globalPosition(cameraTransform.translation)
        let direction = cameraTransform.rotation.act(globalDirection)
        return (position, direction)
    }
    #endif
    
    private var realisticLighting: Bool = true
    
    required init() {
        super.init()
        self.name = "root"
        addChild(sceneBackground)
        addChild(cameraMarker)
        
        #if os(visionOS)
        Task {
            do {
                try await arKitSession.run([worldTrackingProvider])
            } catch {
                print(error)
            }
        }
        #endif
    }
    
    // Set entity sizes based on view type and environment
    func setSizes(_ size: CGSize) {
        guard let simulation else { return }
        pixelSize = CGFloat(simulation.size) / min(size.width, size.height)
        
        switch simulation.viewType {
        case .fixed, .augmented:
            self.entityThickness = 4.0 / Float(size.height)
        case .immersive:
            self.entityThickness = 0.002
        }
    }
    
    // Update the lights
    func updateLights(isEnabled: Bool) {
        if realisticLighting == isEnabled { return }
        realisticLighting = isEnabled
        #if os(iOS) || os(macOS)
        arView?.environment.lighting.resource = isEnabled ? nil : try? EnvironmentResource.load(named: "light")
        #endif
    }
    
    // A marker to show where the camera currently is
    // For internal use only
    class CameraMarker: Entity {
        required init() {
            super.init()
            
            let thickness: Float = 0.05
            let sphere = MeshResource.generateSphere(radius: thickness)
            var material = UnlitMaterial(color: .gray)
            material.blending = .transparent(opacity: 0.5)
            
            components.set(ModelComponent(mesh: sphere, materials: [material]))
        }
        func update(cameraPosition: SIMD3<Float>, arMode: Bool, debugMode: Bool) {
            let position = arMode ? (cameraPosition - [0,0.5,0]) : (normalize(cameraPosition) * 0.7)
            self.position = position
            self.scale = SIMD3(repeating: debugMode && arMode ? 1.0 : 0.0)
            self.orientation = .identity
        }
    }
}

