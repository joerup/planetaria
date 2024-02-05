//
//  LabelComponent.swift
//
//
//  Created by Joe Rupertus on 2/4/24.
//

import Foundation
import RealityKit
import SwiftUI

class LabelComponent: Component {
    
    var model: ModelEntity
    
    init?(node: Node) {
        let label = MeshResource.generateText(
            node.object?.name ?? node.name,
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 1.0)
        )
        self.model = ModelEntity(mesh: label, materials: [UnlitMaterial(color: .white)])
        
        model.components.set(BillboardComponent())
        #if os(visionOS)
        model.components.set(InputTargetComponent())
        model.components.set(HoverEffectComponent())
        #endif
    }
    
    func update(isEnabled: Bool, isVisible: Bool, orientation: simd_quatf, thickness: Float) {
        model.isEnabled = isEnabled
        model.position = orientation.inverse.act([0, 0, 0])
        model.scale = SIMD3(repeating: 4 * thickness * (isVisible ? 1 : 0))
    }
}
