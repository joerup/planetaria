//
//  PointComponent.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 11/2/24.
//

import RealityKit

// A point to show an object
class PointComponent: Component {
    
    var model: ModelEntity
    
    static let radius: Float = 0.2
    
    private var opacity: Float = 1.0
    
    init?(node: Node) {
        self.model = ModelEntity()
    
        let mesh = MeshResource.generateSphere(radius: Self.radius)
        let material = UnlitMaterial(color: ColorType(node.color?.lighter().lighter() ?? .gray))
        let modelComponent = ModelComponent(mesh: mesh, materials: [material])
        model.components.set(modelComponent)
    }
    
    func update(isEnabled: Bool, scale: Float, opacity: Float) {
        model.isEnabled = isEnabled
        model.scale = SIMD3(repeating: scale)
        
        // Apply opacity
        if #available(iOS 18.0, macOS 15.0, visionOS 2.0, *) {
            if self.opacity != opacity {
                self.opacity = opacity
                model.components.remove(OpacityComponent.self)
                model.components.set(OpacityComponent(opacity: opacity))
            }
        }
    }
}
