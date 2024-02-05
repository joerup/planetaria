//
//  TargetSelectComponent.swift
//
//
//  Created by Joe Rupertus on 2/4/24.
//

import Foundation
import RealityKit

class TargetSelectComponent: Component {
    
    var model: ModelEntity
    
    init?(node: Node) {
        let target = MeshResource.generateSphere(radius: 1.0)
        self.model = ModelEntity(mesh: target, materials: [UnlitMaterial(color: .white)])
        
        model.components.set(BillboardComponent())
        #if os(visionOS)
        model.components.set(InputTargetComponent())
        model.components.set(HoverEffectComponent())
        #endif
    }
    
    func update(isSelected: Bool, thickness: Float) {
        model.isEnabled = isSelected
        model.scale = SIMD3(repeating: 4 * thickness)
    }
}
