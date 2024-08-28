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
    var target = TargetSelector()
    
    private static let query = EntityQuery(where: .has(SimulationComponent.self))
    
    #if os(iOS) || os(macOS)
    private var viewType: ViewType {
        .bounded
    }
    #elseif os(visionOS)
    private var viewType: ViewType {
        .full
    }
    #endif
    
    enum ViewType {
        // BOUNDED: simulation is scaled based on a fixed box
        case bounded
        // FULL: simulation is scaled to its true size
        case full
    }
    
    #if os(iOS) || os(macOS)
    var arView: ARView?
    var cameraPosition: SIMD3<Float> {
        arView?.cameraTransform.translation ?? .zero
    }
    #elseif os(visionOS)
    private let arKitSession = ARKitSession()
    private let worldTrackingProvider = WorldTrackingProvider()
    var cameraPosition: SIMD3<Float> {
        guard let pose = worldTrackingProvider.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) else { return .zero }
        let cameraTransform = Transform(matrix: pose.originFromAnchorTransform)
        return cameraTransform.translation
    }
    #endif
    
    private(set) var entityThickness: Float = 0.005
    private(set) var pixelSize: CGFloat = 100
    
    private(set) var animationTime: Double = 0.5
    
    required init() {
        super.init()
        self.name = "root"
        
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
        pixelSize = simulation.size / min(size.width, size.height)
        
        switch viewType {
        case .bounded:
            self.entityThickness = 4.0 / Float(2 * min(size.width, size.height))
        case .full:
            self.entityThickness = 0.003
        }
    }
    
    // Perform an animated transition
    func transition(scale inputScale: CGFloat, offset inputOffset: Vector) {
        guard let simulation else { return }
        let (scale, _, offset) = adjustParameters(scale: inputScale, orientation: simulation.orientation, offset: inputOffset, size: simulation.size)
        
        // Transition all models
        scene?.performQuery(Self.query).forEach { entity in
            guard let configuration = entity.component(SimulationComponent.self) else { return }
            
            let position = configuration.position(scale: scale, offset: offset)
            let transform = Transform(scale: entity.scale, rotation: entity.orientation, translation: position)
            entity.move(to: transform, relativeTo: entity.parent, duration: animationTime, timingFunction: .easeInOut)
            
            let isEnabled = simulation.selectedSystem == configuration.node.parent || simulation.selectedSystem?.parent == configuration.node.parent
            let isSelected = simulation.isSelected(configuration.node)
            let pointVisible = simulation.pointVisible(configuration.node)
            let trailVisibile = simulation.trailVisible(configuration.node)
            let labelVisible = simulation.labelVisible(configuration.node)
            
            // Update the selection
            if isSelected, !configuration.isSelected {
                configuration.entity.select(scale: simulation.scale, thickness: entityThickness, cameraPosition: cameraPosition)
            }
            else if !isSelected, configuration.isSelected {
                configuration.entity.deselect()
            }
            
            // Update the components
            if let point = entity.component(PointComponent.self) {
                point.update(isEnabled: isEnabled, isVisible: pointVisible, thickness: entityThickness, cameraPosition: cameraPosition, duration: animationTime)
            }
            if let body = entity.component(BodyComponent.self) {
                body.update(scale: scale, duration: animationTime)
            }
            if let orbit = entity.component(OrbitComponent.self) {
                orbit.update(isEnabled: isEnabled, isVisible: trailVisibile, isSelected: isSelected, noSelection: simulation.noSelection, scale: scale, thickness: entityThickness, cameraPosition: cameraPosition, duration: animationTime)
            }
            if let label = entity.component(LabelComponent.self) {
                label.update(isEnabled: isEnabled, isVisible: labelVisible, thickness: entityThickness, cameraPosition: cameraPosition, duration: animationTime)
            }
            
            if isSelected {
                setTarget(entity)
            }
        }
    }
    
    // Transform the positioning parameters based on the view type
    func adjustParameters(scale initialScale: Double, orientation initialOrientation: simd_quatf, offset initialOffset: Vector, size: CGFloat) -> (Double, simd_quatf, Vector) {
        var scale: Double
        var orientation: simd_quatf
        var offset: Vector
        
        switch viewType {
        case .bounded:
            scale = initialScale
            orientation = initialOrientation
            offset = initialOffset
        case .full:
            scale = size
            orientation = initialOrientation
            offset = initialOffset - [0,0.65,-0.2] * size/initialScale
        }
        
        return (scale, orientation, offset)
    }
    
    // Attach the target to an entity
    func setTarget(_ entity: Entity) {
        if entity != target.parent {
            target.removeFromParent()
            entity.addChild(target)
        }
    }
}


