//
//  InteractionCube.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 11/30/24.
//

import RealityKit
import SwiftUI

// A huge hitbox that surrounds the user on visionOS
class InteractionCube: Entity {
    
    private static let size: Float = 30
    private static let thickness: Float = 0.1
    
    required init() { }
    
    init(debugMode: Bool) {
        let leftSide = Self.makeCubeSide(debugMode: debugMode, axis: 0)
        let rightSide = Self.makeCubeSide(debugMode: debugMode, axis: 0)
        let bottomSide = Self.makeCubeSide(debugMode: debugMode, axis: 1)
        let topSide = Self.makeCubeSide(debugMode: debugMode, axis: 1)
        let frontSide = Self.makeCubeSide(debugMode: debugMode, axis: 2)
        let backSide = Self.makeCubeSide(debugMode: debugMode, axis: 2)
        
        super.init()
        
        addChild(leftSide)
        addChild(rightSide)
        addChild(bottomSide)
        addChild(topSide)
        addChild(frontSide)
        addChild(backSide)
        
        leftSide.position = [-Self.size/2, 0, 0]
        rightSide.position = [Self.size/2, 0, 0]
        bottomSide.position = [0, -Self.size/2, 0]
        topSide.position = [0, Self.size/2, 0]
        frontSide.position = [0, 0, -Self.size/2]
        backSide.position = [0, 0, Self.size/2]
    }
    
    func update(cameraPosition: SIMD3<Float>, centerPosition: SIMD3<Float>) {
        self.position = cameraPosition
    }
    
    private static func makeCubeSide(debugMode: Bool, axis: Int) -> ModelEntity {
        let cubeSide = ModelEntity()
        
        #if os(visionOS)
        let width: Float = axis == 0 ? thickness : size
        let height: Float = axis == 1 ? thickness : size
        let depth: Float = axis == 2 ? thickness : size
        
        let collisionShape = ShapeResource.generateBox(width: width, height: height, depth: depth)
        cubeSide.components.set(CollisionComponent(shapes: [collisionShape]))
        
        if debugMode {
            let color = ColorType(axis == 0 ? .purple : axis == 1 ? .green : .orange)
            let box = MeshResource.generateBox(width: width, height: height, depth: depth)
            var material = UnlitMaterial(color: color)
            material.blending = .transparent(opacity: 0.1)
            cubeSide.components.set(ModelComponent(mesh: box, materials: [material]))
        }
        
        cubeSide.components.set(InputTargetComponent())
        cubeSide.components.set(InteractionComponent())
        #endif
        
        return cubeSide
    }
}

class InteractionComponent: Component { }
