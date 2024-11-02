//
//  TargetComponent.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 9/7/24.
//

import RealityKit
import SwiftUI

// A target that shows an object is selected
class TargetComponent: Component {
    
    var model: ModelEntity
    
    static let radius: Float = 1.6
    
    private var opacity: Float = 1.0
    
    init?(node: Node) {
        self.model = ModelEntity()
    
        Task {
            if let mesh = try? await MeshResource.generateRing(outerRadius: Self.radius, innerRadius: Self.radius*0.9) {
                let material = UnlitMaterial(color: ColorType(node.color?.lighter() ?? .gray))
                let modelComponent = ModelComponent(mesh: mesh, materials: [material])
                await model.components.set(modelComponent)
            }
        }
    }
    
    func update(isEnabled: Bool, scale: Float, orientation: simd_quatf, opacity: Float) {
        model.isEnabled = isEnabled
        model.scale = SIMD3(repeating: scale)
        model.orientation = orientation
        
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
