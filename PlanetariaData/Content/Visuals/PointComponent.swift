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
    
    static let mesh = makePoint()
    static let defaultMaterial = UnlitMaterial(color: ColorType(.gray))
    
    private var opacity: Float = 1.0
    
    init?(node: Node) {
        self.model = ModelEntity()
        
        let material = if let color = node.color {
            UnlitMaterial(color: ColorType(color.lighter().lighter()))
        } else {
            Self.defaultMaterial
        }
        
        let modelComponent = ModelComponent(mesh: Self.mesh, materials: [material])
        model.components.set(modelComponent)
    }
    
    func update(isEnabled: Bool, scale: Float, orientation: simd_quatf, opacity: Float) {
        model.isEnabled = isEnabled
        guard isEnabled else { return }
        
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
    
    private static func makePoint() -> MeshResource {
        
        // Create a custom octagon mesh
        var meshDescriptor = MeshDescriptor()
        let sides = 8
        let radius: Float = 0.4
        var vertices: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        
        // Generate vertices for the octagon
        for i in 0..<sides {
            let angle = Float(i) * (2 * .pi / Float(sides))
            let x = radius * cos(angle)
            let y = radius * sin(angle)
            vertices.append(SIMD3(x, y, 0))
        }
        vertices.append(SIMD3(0, 0, 0)) // Add center vertex
        
        // Generate triangle indices for the octagon
        let centerIndex = UInt32(vertices.count - 1)
        for i in 0..<sides {
            indices.append(centerIndex)
            indices.append(UInt32(i))
            indices.append(UInt32((i + 1) % sides))
        }
        
        meshDescriptor.positions = MeshBuffer(vertices)
        meshDescriptor.primitives = .triangles(indices)
        return try! MeshResource.generate(from: [meshDescriptor])
    }
}
