//
//  LabelComponent.swift
//
//
//  Created by Joe Rupertus on 1/11/24.
//

import RealityKit

class LabelComponent: Component {
    
    var model: ModelEntity
    
    private var radius: Double
    
    init?(node: Node, size: Double) {
        guard node is ObjectNode, node.id <= 10 || node.id % 100 == 99 else { return nil }
        
        self.radius = node.totalSize / size
        
        let mesh = MeshResource.generateText(node.name, extrusionDepth: 0, font: .systemFont(ofSize: 0.015), containerFrame: .zero, alignment: .center, lineBreakMode: .byClipping)
        
        var material = UnlitMaterial(color: .white)
        material.blending = .transparent(opacity: 0.5)
        
        self.model = ModelEntity(mesh: mesh, materials: [material])
        
        model.orientation = simd_quatf(angle: -.pi/2, axis: [1,0,0])
        model.position = [0, 0.05, 0]
    }
    
    func update(scale: Double, orientation: simd_quatf, duration: Double = 0) {
        let distance = Float(scale * radius + 0.03)
        
        let orientation = orientation.inverse * simd_quatf(angle: -.pi/2, axis: [1,0,0])
        let position = orientation.act([0, -distance, 0])
        
        if duration == 0 {
            model.position = position
            model.orientation = orientation
        } else {
            let transform = Transform(scale: model.scale, rotation: orientation, translation: position)
            model.move(to: transform, relativeTo: model.parent, duration: duration, timingFunction: .easeInOut)
        }
    }
}
