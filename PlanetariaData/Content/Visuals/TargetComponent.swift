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

        let color = ColorType(node.color?.lighter().lighter().lighter() ?? .gray)
        let material = UnlitMaterial(color: color)

        let ringRadius: Float = Self.radius
        let boxWidth: Float = 2 * .pi * ringRadius / 24
        let boxHeight: Float = Self.radius * 0.1
        let segmentCount = 48

        for i in 0..<segmentCount {
            let angle = Float(i) * (2 * .pi / Float(segmentCount))
            let x = ringRadius * cos(angle)
            let y = ringRadius * sin(angle)
            
            // Create a box instead of a sphere
            let boxMesh = MeshResource.generateBox(width: boxWidth, height: boxHeight, depth: boxHeight)
            let boxEntity = ModelEntity(mesh: boxMesh, materials: [material])
            
            // Position the box on the ring
            boxEntity.position = SIMD3(x, y, 0)
            
            // Rotate the box to align with the tangent of the ring
            let tangentRotation = simd_quatf(angle: angle + .pi / 2, axis: SIMD3(0, 0, 1))
            boxEntity.orientation = tangentRotation
            
            model.addChild(boxEntity)
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
