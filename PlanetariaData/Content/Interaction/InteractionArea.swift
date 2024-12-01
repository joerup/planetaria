//
//  InteractionArea.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 11/30/24.
//

import RealityKit
import SwiftUI

// A huge hitbox at the center of the scene
class InteractionArea: Entity {
    
    private let size: Float = 30
    private let distance: Float = 20
    private let depth: Float = 0.1
    
    required init() { }
    
    init(debugMode: Bool) {
        super.init()
        components.set(InteractionAreaComponent())
        
        let collisionShape = ShapeResource.generateBox(width: size, height: size, depth: depth)
        components.set(CollisionComponent(shapes: [collisionShape]))
        
        if debugMode {
            let box = MeshResource.generateBox(width: size, height: size, depth: depth)
            var material = UnlitMaterial(color: .purple)
            material.blending = .transparent(opacity: 0.1)
            components.set(ModelComponent(mesh: box, materials: [material]))
        }
        
        #if os(visionOS)
        components.set(InputTargetComponent())
        #endif
    }
    
    func update(orientation: simd_quatf, cameraPosition: SIMD3<Float>, centerPosition: SIMD3<Float>) {
        self.orientation = orientation
        self.position = cameraPosition + normalize(centerPosition - cameraPosition) * distance
    }
}
