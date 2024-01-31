//
//  SimulationSystem.swift
//
//
//  Created by Joe Rupertus on 1/13/24.
//

import RealityKit

class SimulationSystem: System {
    
    private var root: SimulationRootEntity?
    private var simulation: Simulation?
    
    private static let query = EntityQuery(where: .has(SimulationComponent.self))
    
    required init(scene: Scene) { }
    
    func update(context: SceneUpdateContext) {
        guard let simulation else {
            if let root = context.scene.findEntity(named: "root") as? SimulationRootEntity {
                self.root = root
                self.simulation = root.simulation
            }
            return
        }
        
        // Update orientation
        root?.rotate(rotation: simulation.rotation, pitch: simulation.pitch)
        
        // Update models
        context.scene.performQuery(Self.query).forEach { entity in
            guard let configuration = entity.component(SimulationComponent.self) else { return }
            entity.position = configuration.position(scale: simulation.scale, offset: simulation.offset)
            #if os(iOS)
            configuration.screenPosition = root?.arView?.project(entity.position(relativeTo: nil)) ?? .zero
            #endif
            
            let isEnabled = simulation.selectedSystem == configuration.node.parent
            let isSelected = simulation.isSelected(configuration.node)
            let orbitEnabled = isEnabled && (isSelected || configuration.node.rank == .primary)
            let trailVisibile = simulation.trailVisible(configuration.node)
            
            if let body = entity.component(BodyComponent.self) {
                body.update(isEnabled: isEnabled, scale: simulation.scale)
            }
            if let point = entity.component(PointComponent.self) {
                point.update(isEnabled: isEnabled, thickness: simulation.entityThickness)
            }
            if let orbit = entity.component(OrbitComponent.self) {
                orbit.update(isEnabled: orbitEnabled, isVisible: trailVisibile, scale: simulation.scale, thickness: simulation.entityThickness)
            }
        }
    }
}
