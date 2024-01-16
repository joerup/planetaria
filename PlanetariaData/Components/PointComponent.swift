//
//  PointComponent.swift
//
//
//  Created by Joe Rupertus on 1/9/24.
//

import RealityKit
import SwiftUI

class PointComponent: Component {
    
    var model: ModelEntity
    
    init?(node: Node) {
        let radius: Float = 0.003
        let sphere = MeshResource.generateSphere(radius: radius)
        let collisionShape = ShapeResource.generateSphere(radius: 5 * radius)
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
        #endif
    }
    
    func update(isEnabled: Bool, isSelected: Bool, noSelection: Bool) {
        model.scale = SIMD3(repeating: isEnabled ? (isSelected ? 1.2 : noSelection ? 1 : 0.5) : 0)
    }
}
