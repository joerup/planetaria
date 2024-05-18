//
//  OrbitComponent.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 1/14/24.
//

import SwiftUI
import RealityKit

class OrbitComponent: Component {
    
    var node: Node
    
    private let numberOfSegments: Int = 50
    private let numberOfPreciseSegments: Int = 10
    
    private var scale: CGFloat
    private var size: CGFloat
    
    private var segments: [Entity] = []
    var model: Entity
    
    init?(node: Node, size: CGFloat) {
        guard node.orbit != nil else { return nil }
          
        self.node = node
        self.size = size
        self.scale = 1.0
        
        self.model = Entity()
        
        for i in 1...numberOfSegments {
            let thickness: Float = node.object?.category == .planet ? 0.5 : 0.4
            let mesh = MeshResource.generateBox(width: 1.0, height: thickness, depth: thickness)
            #if os(iOS) || os(visionOS)
            var material = UnlitMaterial(color: UIColor(node.color ?? .gray))
            material.blending = .transparent(opacity: .init(floatLiteral: 1.0 - Float(i) / Float(numberOfSegments)))
            #elseif os(macOS)
            let material = UnlitMaterial(color: NSColor(node.color ?? .gray))
            #endif
            let segment = ModelEntity(mesh: mesh, materials: [material])
            segments.append(segment)
            model.addChild(segment)
        }
        
        update(isEnabled: false, isVisible: true, isSelected: false, noSelection: true, scale: 1.0, thickness: 0.001, cameraPosition: .zero)
    }
    
    func update(isEnabled: Bool, isVisible: Bool, isSelected: Bool, noSelection: Bool, scale: CGFloat, thickness: Float, cameraPosition: SIMD3<Float>, duration: Double = 0) {
        model.isEnabled = isEnabled
        guard isEnabled, let orbit = node.orbit, !segments.isEmpty else { self.scale = scale; return }
        
        let currentPosition = (node.position - node.barycenterPosition) * scale / size
        var lastPoint: Vector = .zero
        let scaleRatio = Float(self.scale / scale)
        let extraScale: Float = thickness * (isVisible ? 1 : 0) * (isSelected ? 1.1 : noSelection ? 1.0 : 0.8)
        self.scale = scale
        
        if duration != 0 {
            model.scale = SIMD3(repeating: scaleRatio)
            model.move(to: Transform(), relativeTo: model.parent, duration: duration, timingFunction: .easeInOut)
        } 
        
        for i in 0..<segments.endIndex {
        
            // angle spacing forces higher precision closest to the actual object (theta = 0)
            var point: Vector
            if i < numberOfPreciseSegments {
                let angle = Double(1) / Double(numberOfSegments-numberOfPreciseSegments) * 2 * .pi
                point = orbit.ellipsePosition3D(orbit.trueAnomaly - angle) * scale / size - currentPosition
                point = point.magnitude * pow(Double(i+1)/Double(numberOfPreciseSegments),5) * point.unitVector
            } else {
                let angle = Double(i+1-numberOfPreciseSegments) / Double(numberOfSegments-numberOfPreciseSegments) * 2 * .pi
                point = orbit.ellipsePosition3D(orbit.trueAnomaly - angle) * scale / size - currentPosition
            }
            let length = Float((point - lastPoint).magnitude)
            
            segments[i].position = ((point + lastPoint) / 2).simdf
            segments[i].orientation = simd_quatf(from: [1,0,0], to: normalize((point - lastPoint).simdf))
            
            let distanceScale = distance(segments[i].position(relativeTo: nil), cameraPosition)
            let totalScale = distanceScale * extraScale
            
            if duration == 0 {
                segments[i].scale = [length, totalScale, totalScale]
            } else {
                segments[i].scale = [length, totalScale/scaleRatio, totalScale/scaleRatio]
                let transform = Transform(scale: [length, totalScale, totalScale], rotation: segments[i].orientation, translation: segments[i].position)
                segments[i].move(to: transform, relativeTo: segments[i].parent, duration: duration, timingFunction: .easeInOut)
            }
            
            lastPoint = point
        }
    }
}
