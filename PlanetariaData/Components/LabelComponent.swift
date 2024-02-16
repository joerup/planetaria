//
//  LabelComponent.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 2/4/24.
//

import Foundation
import RealityKit
import SwiftUI
#if canImport(UIKit)
import UIKit
typealias FontType = UIFont
#else
typealias FontType = NSFont
#endif

class LabelComponent: Component {
    
    var model: Entity
    
    init?(node: Node) {
        let text = node.object?.name ?? node.name
        let font: FontType = .systemFont(ofSize: 1.0)
        
        let labelMesh = MeshResource.generateText(text, extrusionDepth: 0.01, font: font)
        let labelEntity = ModelEntity(mesh: labelMesh, materials: [UnlitMaterial(color: .white)])
        self.model = Entity()
        model.addChild(labelEntity)
        
        let sampleLabel = UILabel()
        sampleLabel.text = text
        sampleLabel.font = font
        sampleLabel.textAlignment = .center
        sampleLabel.numberOfLines = 1
        let width = sampleLabel.intrinsicContentSize.width
        
        labelEntity.position = [-Float(width)/2, -1.7, 0.1]
        
        model.components.set(BillboardComponent())
        #if os(visionOS)
        model.components.set(InputTargetComponent())
        model.components.set(HoverEffectComponent())
        #endif
    }
    
    func update(isEnabled: Bool, isVisible: Bool, thickness: Float) {
        model.isEnabled = isEnabled
        model.position = .zero
        model.scale = SIMD3(repeating: 4 * thickness * (isVisible ? 1 : 0))
    }
}
