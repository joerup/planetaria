//
//  SimulationSystem.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 1/13/24.
//

import RealityKit

class SimulationSystem: System {
    
    private var root: SimulationRootEntity?
    private var simulation: Simulation?
    
    private static let query = EntityQuery(where: .has(SimulationComponent.self))
    private var entities: [Entity] = []
    
    required init(scene: Scene) { }
    
    func update(context: SceneUpdateContext) {
        guard let simulation, let root else {
            if let root = context.scene.findEntity(named: "root") as? SimulationRootEntity {
                self.root = root
                self.simulation = root.simulation
            }
            entities = context.scene.performQuery(Self.query).map{$0}
            return
        }
        
        // Update root
        root.orientation = simulation.orientation
        root.target.update(isEnabled: simulation.hasSelection, thickness: simulation.entityThickness, cameraPosition: root.cameraPosition)
        
        // Update models
        entities.forEach { entity in
            guard let configuration = entity.component(SimulationComponent.self) else { return }
            entity.position = configuration.position(scale: simulation.scale, offset: simulation.offset)
            
            // Calculate visibility
            let isEnabled = simulation.selectedSystem == configuration.node.parent || simulation.selectedSystem?.parent == configuration.node.parent
            let isSelected = simulation.isSelected(configuration.node)
            let orbitEnabled = isEnabled && (isSelected || configuration.node.rank == .primary)
            let pointVisible = simulation.pointVisible(configuration.node)
            let trailVisibile = simulation.trailVisible(configuration.node)
            let labelVisible = simulation.labelVisible(configuration.node)
            
            // Update the selection
            if isSelected, !configuration.isSelected {
                configuration.entity.select()
            }
            else if !isSelected, configuration.isSelected {
                configuration.entity.deselect()
            }
            
            // Update the components
            if let body = entity.component(BodyComponent.self) {
                body.update(scale: simulation.scale)
            }
            if let point = entity.component(PointComponent.self) {
                point.update(isEnabled: isEnabled, isVisible: pointVisible, thickness: simulation.entityThickness, cameraPosition: root.cameraPosition)
            }
            if let orbit = entity.component(OrbitComponent.self) {
                orbit.update(isEnabled: orbitEnabled, isVisible: trailVisibile, isSelected: isSelected, noSelection: simulation.noSelection, scale: simulation.scale, thickness: simulation.entityThickness, cameraPosition: root.cameraPosition)
            }
            if let label = entity.component(LabelComponent.self) {
                label.update(isEnabled: isEnabled, isVisible: labelVisible, thickness: simulation.entityThickness, cameraPosition: root.cameraPosition)
            }
            
            if isSelected, configuration.node.category != .system {
                root.setTarget(entity)
            }
        }
    }
}
