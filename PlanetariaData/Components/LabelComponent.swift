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
#elseif canImport(AppKit)
import AppKit
typealias FontType = NSFont
#endif

class LabelComponent: Component {
    
    var model: Entity
    
    init?(node: Node, thickness: Float = 0.001, cameraPosition: SIMD3<Float> = .zero) {
        let text = node.object?.name ?? node.name
        let font: FontType = .systemFont(ofSize: 1.0)
        
        let labelMesh = MeshResource.generateText(text, extrusionDepth: 0.01, font: font)
        let labelEntity = ModelEntity(mesh: labelMesh, materials: [UnlitMaterial(color: .white)])
        self.model = Entity()
        model.addChild(labelEntity)
        
        #if os(macOS)
        let sampleLabel = NSTextField(string: text)
        sampleLabel.font = font
        sampleLabel.alignment = .center
        #elseif os(iOS) || os(visionOS)
        let sampleLabel = UILabel()
        sampleLabel.textAlignment = .center
        sampleLabel.text = text
        sampleLabel.numberOfLines = 1
        sampleLabel.font = font
        #endif
        let width = sampleLabel.intrinsicContentSize.width
        
        labelEntity.position = [-Float(width)/2, -1.7, 0.1]
        
        model.components.set(BillboardComponent())
        #if os(visionOS)
        model.components.set(InputTargetComponent())
        model.components.set(HoverEffectComponent())
        #endif
        
        update(isEnabled: true, isVisible: true, thickness: thickness, cameraPosition: cameraPosition)
    }
    
    func update(isEnabled: Bool, isVisible: Bool, thickness: Float, cameraPosition: SIMD3<Float>, duration: Double = 0) {
        let modelPosition = model.position(relativeTo: nil)
        let scale = SIMD3(repeating: 3 * thickness * (isEnabled ? 1 : 0) * (isVisible ? 1 : 0) * distance(modelPosition, cameraPosition))
        
        if duration == 0 {
            model.position = .zero
            model.scale = scale
        } else {
            let transform = Transform(scale: scale, rotation: model.orientation, translation: model.position)
            model.move(to: transform, relativeTo: model.parent, duration: duration, timingFunction: .easeInOut)
        }
    }
}
