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
        guard node is Object else { return nil }
        
        let radius: Float = node.system != nil ? 0.004 : 0.003
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
}
