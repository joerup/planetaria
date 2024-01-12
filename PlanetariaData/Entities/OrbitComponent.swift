//
//  OrbitComponent.swift
//
//
//  Created by Joe Rupertus on 1/8/24.
//

import RealityKit
import SwiftUI

class OrbitComponent: Component {
    
    private let fullNumberOfPoints: UInt32 = 100
    private let thickness: Float = 0.0005
    
    private var transformation: simd_quatf
    
    var model: ModelEntity
    
    init?(node: Node, size: Double) {
        guard let orbit = node.orbit else { return nil }
        
        self.transformation = simd_quatf(angle: Float(orbit.orbitalInclination), axis: orbit.lineOfNodes.simdf)
        
        let currentPosition = transformation.inverse.act((node.position - node.barycenterPosition).simdf / Float(size))
        
        var positions: [SIMD3<Float>] = []
        var uvs: [SIMD2<Float>] = []
        
        positions.append([0,thickness,0])
        positions.append([0,thickness,0])
        
        uvs.append([0, 0])
        uvs.append([0, 1])
        
        let numberOfPoints = node.rank == .primary ? fullNumberOfPoints : fullNumberOfPoints/2
        for i in 1...numberOfPoints {
            let angle = Double(i) / Double(fullNumberOfPoints) * 6
            let point = orbit.ellipsePosition(orbit.trueAnomaly - angle) / size
            
            positions.append(point.simdf - currentPosition + [0,thickness,0])
            positions.append(point.simdf - currentPosition - [0,thickness,0])
            
            uvs.append([Float(i) / Float(fullNumberOfPoints), 0])
            uvs.append([Float(i) / Float(fullNumberOfPoints), 1])
        }
        
        var meshPart = MeshResource.Part(id: "Orbit", materialIndex: 0)
        meshPart.textureCoordinates = .init(uvs.reversed())
        meshPart.positions = .init(positions)
        
        var indices: [UInt32] = []
        for index in 0 ..< 2*numberOfPoints {
            indices.append(contentsOf: [index, index + 1, index + 2])
            indices.append(contentsOf: [index + 2, index + 1, index])
        }
        meshPart.triangleIndices = .init(indices)

        var contents = MeshResource.Contents()
        contents.models = [.init(id: "Orbit", parts: [meshPart])]
        
        guard let mesh = try? MeshResource.generate(from: contents) else { return nil }
        guard let traceResource = try? TextureResource.load(named: "TrailGradient") else { return nil }
        
        let traceMap = MaterialParameters.Texture(traceResource)
        
        #if os(iOS) || os(tvOS) || os(visionOS)
        var material = UnlitMaterial(color: UIColor(node.color ?? .gray))
        material.opacityThreshold = 0
        material.blending = .transparent(opacity: .init(texture: traceMap))
        #elseif os(macOS)
        var material = UnlitMaterial(color: NSColor(node.color ?? .gray))
        material.opacityThreshold = 0
        #endif
        
        self.model = ModelEntity(mesh: mesh, materials: [material])
        model.orientation = transformation
    }
    
    func update(scale: Double, duration: Double) {
        let scale: SIMD3<Float> = [Float(scale), 1, Float(scale)]
        
        if duration == 0 {
            model.position = .zero
            model.scale = scale
            model.orientation = transformation
        } else {
            let transform = Transform(scale: scale, rotation: transformation, translation: model.position)
            model.move(to: transform, relativeTo: model.parent, duration: duration, timingFunction: .easeInOut)
        }
    }
}

