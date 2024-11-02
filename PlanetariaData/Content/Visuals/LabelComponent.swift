//
//  LabelComponent.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 2/4/24.
//

import Foundation
import RealityKit
import SwiftUI

// A text label underneath an object
class LabelComponent: Component {
    
    var model: Entity
    
    private var opacity: Float = 1.0
    
    init?(node: Node) {
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
        
        labelEntity.position = [-Float(width)/2, -2.0, 0.1]
    }
    
    func update(isEnabled: Bool, scale: Float, orientation: simd_quatf, opacity: Float) {
        model.isEnabled = isEnabled
        model.scale = SIMD3(repeating: 2.5 * scale)
        model.orientation = orientation
        
        if #available(iOS 18.0, macOS 15.0, visionOS 2.0, *) {
            if self.opacity != opacity {
                self.opacity = opacity
                model.components.remove(OpacityComponent.self)
                model.components.set(OpacityComponent(opacity: opacity))
            }
        }
    }
}

