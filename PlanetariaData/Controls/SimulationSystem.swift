//
//  SimulationSystem.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 1/13/24.
//

import Foundation
import RealityKit

class SimulationSystem: System {
    
    private var root: SimulationRootEntity?
    private var simulation: Simulation?
    
    private let query = EntityQuery(where: .has(SimulationComponent.self))
    private var entities: [Entity] = []
    
    required init(scene: Scene) { }
    
    // Updates the scene every frame
    func update(context: SceneUpdateContext) {
        guard let root, let simulation else {
            if let root = context.scene.findEntity(named: "root") as? SimulationRootEntity {
                self.root = root
                self.simulation = root.simulation
            }
            entities = context.scene.performQuery(query).map { $0 }
            return
        }
        
        // Run the simulation one step
        simulation.advance()
        
        // Update the simulation
        simulation.updateTransformations()
        
        // Get the initial parameters
        let initialScale = simulation.scale
        let initialOrientation = simulation.orientation
        let initialOffset = simulation.offset
        
        // Adjust the parameters
        let (scale, orientation, offset, center) = adjustParameters(scale: initialScale, orientation: initialOrientation, offset: initialOffset, size: simulation.size)
        
        // Get the camera state
        let (cameraPosition, cameraForward) = root.cameraState
        
        // Get the entity thickness
        let entityThickness = root.entityThickness
        
        // Update scene entities in the root
        root.sceneBackground.update(orientation: orientation)
        root.interactionArea.update(orientation: initialOrientation, cameraPosition: cameraPosition, centerPosition: center)
        root.attachmentPoint.update(orientation: initialOrientation, cameraPosition: cameraPosition, centerPosition: center)
        root.cameraMarker.update(cameraPosition: cameraPosition, arMode: simulation.viewType == .augmented || simulation.viewType == .immersive)
        if #available(iOS 18.0, macOS 15.0, visionOS 2.0, *) {
            root.updateLights(isEnabled: !simulation.showFloodLights)
        } else {
            root.updateLights(isEnabled: false)
        }
        
        // Update simulation entities
        for entity in entities {
            guard let configuration = entity.component(SimulationComponent.self) else { continue }
            let node = configuration.node
            
            // Calculate the new position
            var position = configuration.position(scale: scale, orientation: orientation, offset: offset, center: center)
            let constrainFactor = position.constrainFactor
            let scale = scale * Double(constrainFactor)
            position = position * constrainFactor
            entity.position = position
            
            // Update the selection
            let isSelected = simulation.isSelected(node)
            let noSelection = simulation.noSelection
            if isSelected, !configuration.isSelected {
                configuration.entity.select()
            }
            else if !isSelected, configuration.isSelected {
                configuration.entity.deselect()
            }
            
            // Calculate the billboard scale and orientation
            let billboardScale = entity.distanceScale(position: position, cameraPosition: cameraPosition, cameraForward: cameraForward) * entityThickness
            let billboardOrientation = entity.billboardOrientation(position: position, cameraPosition: cameraPosition, toPoint: simulation.viewType == .augmented || simulation.viewType == .immersive)
            
            // Calculate the opacity
            let opacityPrimary: Float =
                switch simulation.viewType {
                case .fixed: 0.25
                case .augmented: 0.8
                case .immersive: 0.15
                }
            let opacitySecondary: Float =
                switch simulation.viewType {
                case .fixed: 0.25
                case .augmented: 0.6
                case .immersive: 0.1
                }
            let opacityTertiary: Float =
                switch simulation.viewType {
                case .fixed: 0.15
                case .augmented: 0.4
                case .immersive: 0.05
                }
            let opacity: Float =
                if simulation.isSelected(node) {
                    1.0
                } else if (noSelection && simulation.isSystem(node.system)) {
                    node.rank == .primary ? 1.0 : opacitySecondary
                } else if (noSelection || (simulation.stateSystem && simulation.isSelected((node.system ?? node).hostNode))) && simulation.isInSystem(node.system ?? node) {
                    node.rank == .primary ? 1.0 : opacitySecondary
                } else if simulation.isSystem(node.system ?? node) {
                    opacityPrimary
                } else {
                    node.rank == .primary ? opacityPrimary : opacityTertiary
                }
            
            // Determine component visibility
            let minimumSize = 0.1 * billboardScale * Float(simulation.size)
            let targetSize = TargetComponent.radius * billboardScale * Float(simulation.size)

            let orbitSize = Float(scale * (node.system ?? node).position.magnitude)
            let physicalSize = Float(scale * node.size)
            let physicalObjectTotalSize = Float(scale * (node.object ?? node).totalSize)
            let isCentral = node.system != nil && node.system?.orbit == nil // edge case for Sun
            
            let isGoingVeryFast = abs(simulation.frameRatio) > 2 * ((node.system ?? node).orbit?.period ?? .infinity)
            
            let fadeFractionFactor: Float = simulation.viewType == .immersive ? 100 : 10
            let fadeFraction: Float = max(0.0, min(1.0, 1.0 - (physicalObjectTotalSize - targetSize) / (fadeFractionFactor * targetSize - targetSize)))
            
            let orbitAnchored: Bool = (initialOffset - node.globalPosition).magnitude / (initialOffset - (node.parent?.globalPosition ?? .zero)).magnitude < 0.01
            
            let bodyVisible = physicalSize >= minimumSize || (node.object?.luminosity ?? 0) > 0
            let pointVisible = physicalSize <= targetSize && (orbitSize >= 2 * targetSize || isSelected || isCentral) && node is ObjectNode
            let labelVisible = simulation.showLabels && physicalSize <= 1.5 * targetSize && (orbitSize >= 4 * targetSize || isSelected || isCentral) && node is ObjectNode && !isGoingVeryFast
            let trailVisible = simulation.showOrbits && orbitSize >= minimumSize
            let interactionVisible = pointVisible || bodyVisible
            var lightsVisible = false
            if #available(iOS 18.0, macOS 15.0, visionOS 2.0, *) {
                lightsVisible = !simulation.showFloodLights
            }
            
            // Update the components
            if let interaction = entity.component(InteractionComponent.self) {
                interaction.update(isEnabled: interactionVisible, scale: scale, thickness: entityThickness, modelPosition: position, cameraPosition: cameraPosition)
            }
            if let body = entity.component(BodyComponent.self) {
                body.update(isEnabled: bodyVisible, scale: scale, orientation: orientation, lightEnabled: lightsVisible)
            }
            if let point = entity.component(PointComponent.self) {
                point.update(isEnabled: pointVisible, scale: billboardScale, opacity: opacity)
            }
            if let target = entity.component(TargetComponent.self) {
                target.update(isEnabled: pointVisible, scale: billboardScale, orientation: billboardOrientation, opacity: opacity)
            }
            if let label = entity.component(LabelComponent.self) {
                label.update(isEnabled: labelVisible, scale: billboardScale, orientation: billboardOrientation, opacity: opacity)
            }
            if #available(iOS 18.0, macOS 15.0, visionOS 2.0, *) {
                if let orbit = entity.component(OrbitComponent.self) {
                    orbit.update(isEnabled: trailVisible, scale: scale, orientation: orientation, opacity: opacity * (isGoingVeryFast ? 0.4 : 1), fadeFraction: fadeFraction, anchored: orbitAnchored)
                }
            } else {
                if let orbit = entity.component(OrbitComponentLegacy.self) {
                    orbit.update(isEnabled: trailVisible, isVisible: trailVisible, isSelected: isSelected, noSelection: noSelection, scale: scale, orientation: orientation, thickness: entityThickness, modelPosition: position, cameraPosition: cameraPosition)
                }
            }
        }
    }
    
    // Transform the positioning parameters based on the view type
    private func adjustParameters(scale initialScale: Double, orientation initialOrientation: simd_quatf, offset initialOffset: Vector3, size: Double) -> (Double, simd_quatf, Vector3, SIMD3<Float>) {
        guard let simulation else { return (initialScale, initialOrientation, initialOffset, .zero) }
        
        var scale: Double
        var orientation: simd_quatf
        var offset: Vector3 // rotated
        var center: SIMD3<Float> // not rotated
        
        switch simulation.viewType {
        case .fixed, .augmented:
            scale = initialScale
            orientation = initialOrientation
            offset = initialOffset
            center = .zero
        case .immersive:
            scale = size
            orientation = .identity
            offset = initialOffset
            center = initialOrientation.act([0,0.45,-0.9] * Float(size / initialScale))
        }
        
        return (scale, orientation, offset, center)
    }
}
