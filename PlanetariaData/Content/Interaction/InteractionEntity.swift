//
//  InteractionEntity.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 10/2/24.
//

import RealityKit

class InteractionEntity: Entity {
    
    let distance: Float
    let size: Float
    
    @MainActor required init() {
        distance = 0
        size = 1
    }
    
    init(node: Node, secondary: Bool = false, debugMode: Bool) {
        self.distance = (secondary ? 15 : 10) - Float(0.01 * log(node.object?.size ?? 1))
        self.size = secondary ? 5 : 3
        
        super.init()
        
        let collisionShape = ShapeResource.generateSphere(radius: size)
        components.set(CollisionComponent(shapes: [collisionShape]))
        
        // Visual for debugging
        if debugMode {
            let sphere = MeshResource.generateSphere(radius: size)
            var material = UnlitMaterial(color: secondary ? .cyan : .blue)
            material.blending = .transparent(opacity: 0.3)
            components.set(ModelComponent(mesh: sphere, materials: [material]))
        }
        
        #if os(visionOS)
        components.set(InputTargetComponent())
        #endif
    }
}
