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
    
    required init(scene: Scene) { 
        if let root = scene.anchors.first?.children.first as? SimulationRootEntity {
            self.root = root
            self.simulation = root.simulation
        }
    }
    
    func update(context: SceneUpdateContext) {
        if let simulation {
            
            // Update orientation
            root?.orientation = simd_quatf(angle: Float(simulation.pitch.radians), axis: SIMD3(1,0,0)) * simd_quatf(angle: Float(-simulation.rotation.radians), axis: SIMD3(0,1,0))
            
            // Update model entities by position and scale
            context.scene.performQuery(Self.query).forEach { entity in
                
                if let component = entity.component(SimulationComponent.self) {
                    entity.position = component.position(scale: simulation.scale, offset: simulation.offset)
                }
                
                if let body = entity.component(BodyComponent.self) {
                    body.update(scale: simulation.scale)
                }
                if let orbit = entity.component(OrbitComponent.self) {
                    orbit.update(scale: simulation.scale)
                }
//                if let label = component(LabelComponent.self) {
//                    label.update(scale: scale, orientation: orientation)
//                }
//                if let light = component(LightComponent.self) {
//                    light.update(scale: scale)
//                }
            }
        }
    }
}
