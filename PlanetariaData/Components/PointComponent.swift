//
//  PointComponent.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 1/9/24.
//

import RealityKit
import SwiftUI

class PointComponent: Component {
    
    var model: ModelEntity
    
    init?(node: Node) {
        let thickness: Float = 0.5
        let sphere = MeshResource.generateSphere(radius: thickness)
        let collisionShape = ShapeResource.generateSphere(radius: 8)
        #if os(macOS)
        let material = UnlitMaterial(color: NSColor(node.color ?? .gray))
        #else
        let material = UnlitMaterial(color: UIColor(node.color ?? .gray))
        #endif
        
        self.model = ModelEntity()
        
        model.components.set(ModelComponent(mesh: sphere, materials: [material]))
        model.components.set(CollisionComponent(shapes: [collisionShape]))
        #if os(visionOS)
        model.components.set(InputTargetComponent())
        model.components.set(HoverEffectComponent())
        #endif
    }
    
    func update(isEnabled: Bool, isVisible: Bool, thickness: Float, cameraPosition: SIMD3<Float>, duration: Double = 0) {
        let scale = SIMD3(repeating: thickness * (isEnabled ? 1 : 0) * (isVisible ? 1 : 0) * distance(model.position(relativeTo: nil), cameraPosition))
        
        if duration == 0 {
            model.position = .zero
            model.scale = scale
        } else {
            let transform = Transform(scale: scale, rotation: model.orientation, translation: model.position)
            model.move(to: transform, relativeTo: model.parent, duration: duration, timingFunction: .easeInOut)
        }
    }
}
