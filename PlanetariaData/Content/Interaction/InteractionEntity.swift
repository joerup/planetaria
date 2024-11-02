//
//  InteractionEntity.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 10/2/24.
//

import RealityKit

class InteractionEntity: Entity {
    
    // Size of an interaction entity
    static let size: Float = 3.0
    
    // All interaction entities always remain at this fixed distance from the camera
    static let distance: Float = 10.0
    
    @MainActor required init() { }
    
    init(node: Node, debugMode: Bool) {
        super.init()
        
        let collisionShape = ShapeResource.generateSphere(radius: Self.size)
        components.set(CollisionComponent(shapes: [collisionShape]))
        
        // Visual for debugging
        if debugMode {
            let sphere = MeshResource.generateSphere(radius: Self.size)
            var material = UnlitMaterial(color: .blue)
            material.blending = .transparent(opacity: 0.3)
            components.set(ModelComponent(mesh: sphere, materials: [material]))
        }
        
        #if os(visionOS)
        components.set(InputTargetComponent())
        components.set(HoverEffectComponent())
        #endif
    }
}
