//
//  InteractionComponent.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 9/7/24.
//

import RealityKit
import SwiftUI

// A hitbox to interact with objects
class InteractionComponent: Component {
    
    private(set) var entity: InteractionEntity
    private(set) var node: Node
    private(set) var size: Double
    
    init(node: Node, size: Double, debugMode: Bool) {
        self.entity = InteractionEntity(node: node, debugMode: debugMode)
        self.node = node
        self.size = size
        entity.components.set(self)
    }
    
    func update(isEnabled: Bool, scale: Double, thickness: Float, modelPosition: SIMD3<Float>, cameraPosition: SIMD3<Float>) {
        entity.isEnabled = isEnabled
        
        // offset by the node id to give it a sort of hierarchical ordering
        let staticDistance = InteractionEntity.distance - Float(0.01 * log(node.object?.size ?? 1))
        
        let sizeScale = Float(node.size * scale / size) / distance(modelPosition, cameraPosition) * staticDistance / InteractionEntity.size
        let thicknessScale = 2 * thickness * staticDistance
        
        let scale = SIMD3(repeating: max(thicknessScale, sizeScale))
        let position = cameraPosition + normalize(modelPosition - cameraPosition) * staticDistance
        
        // Apply position and scale
        entity.position = position
        entity.scale = scale
    }
}
