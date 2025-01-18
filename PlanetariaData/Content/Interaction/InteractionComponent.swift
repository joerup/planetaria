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
    
    private(set) var primaryEntity: InteractionEntity
    private(set) var secondaryEntity: InteractionEntity
    
    private(set) var node: Node
    private(set) var size: Double
    
    init(node: Node, size: Double, debugMode: Bool) {
        self.primaryEntity = InteractionEntity(node: node, debugMode: debugMode)
        self.secondaryEntity = InteractionEntity(node: node, secondary: true, debugMode: debugMode)
        
        self.node = node
        self.size = size
        
        primaryEntity.components.set(self)
        secondaryEntity.components.set(self)
    }
    
    func update(isEnabled: Bool, scale: Double, thickness: Float, modelPosition: SIMD3<Float>, cameraPosition: SIMD3<Float>) {
        guard Double.random(in: 0..<1) < 0.1 else { return }
        
        updateEntity(entity: primaryEntity, isEnabled: isEnabled, scale: scale, thickness: thickness, modelPosition: modelPosition, cameraPosition: cameraPosition)
        updateEntity(entity: secondaryEntity, isEnabled: isEnabled, scale: scale, thickness: thickness, modelPosition: modelPosition, cameraPosition: cameraPosition)
    }
    
    private func updateEntity(entity: InteractionEntity, isEnabled: Bool, scale: Double, thickness: Float, modelPosition: SIMD3<Float>, cameraPosition: SIMD3<Float>) {
        entity.isEnabled = isEnabled
        guard isEnabled else { return }
        
        let sizeScale = Float(node.size * scale / size) / distance(modelPosition, cameraPosition) * entity.distance / entity.size
        let thicknessScale = 2 * thickness * entity.distance
        
        let scale = SIMD3(repeating: max(thicknessScale, sizeScale))
        let position = cameraPosition + normalize(modelPosition - cameraPosition) * entity.distance
        
        // Apply position and scale
        entity.position = position
        entity.scale = scale
    }
}

class InteractionAreaComponent: Component { }
