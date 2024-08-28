//
//  OrbitComponent.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 1/14/24.
//

import SwiftUI
import RealityKit


// MARK: UPDATED COMPONENT FOR IOS 17

class OrbitComponent: Component {
    
    var node: Node
    
    private let numberOfSegments: Int = 50
    private let numberOfPreciseSegments: Int = 0
    
    private var size: CGFloat
    
    private var points: [Entity] = []
    private var segments: [ModelEntity] = []
    
    var model: Entity
    
    init?(node: Node, size: CGFloat, scale: CGFloat = 1.0, thickness: Float = 0.001, cameraPosition: SIMD3<Float> = .zero) {
        guard node.orbit != nil else { return nil }
          
        self.node = node
        self.size = size
        
        self.model = Entity()
        
        for i in 1...numberOfSegments {
            let thickness: Float = 0.3
            let mesh = MeshResource.generateBox(width: 1.0, height: thickness, depth: thickness)
            #if os(iOS) || os(visionOS)
            var material = UnlitMaterial(color: UIColor(node.color ?? .gray))
            material.blending = .transparent(opacity: .init(floatLiteral: 1.0 - Float(i) / Float(numberOfSegments)))
            #elseif os(macOS)
            let material = UnlitMaterial(color: NSColor(node.color ?? .gray))
            #endif
            let point = Entity()
            let segment = ModelEntity(mesh: mesh, materials: [material])
            points.append(point)
            segments.append(segment)
            model.addChild(point)
            point.addChild(segment)
        }
        
        update(isEnabled: true, isVisible: true, isSelected: false, noSelection: true, scale: scale, thickness: thickness, cameraPosition: cameraPosition)
    }
    
    func update(isEnabled: Bool, isVisible: Bool, isSelected: Bool, noSelection: Bool, scale: CGFloat, thickness: Float, cameraPosition: SIMD3<Float>, duration: Double = 0) {
        model.isEnabled = isEnabled
        guard isEnabled, let orbit = node.orbit else { return }
        
        let currentPosition = (node.position - node.barycenterPosition) * scale / size
        var lastPoint: Vector = .zero
        let extraScale: Float = thickness * (isVisible ? 1 : 0) * (isSelected ? 1.1 : noSelection ? 1.0 : 0.8)
        
        for i in 0..<points.endIndex {
        
            // angle spacing forces higher precision closest to the actual object (theta = 0)
            var point: Vector
            if i < numberOfPreciseSegments {
                let angle = Double(1) / Double(numberOfSegments-numberOfPreciseSegments) * 2 * .pi
                point = orbit.ellipsePosition3D(orbit.trueAnomaly - angle) * scale / size - currentPosition
                point = point.unitVector * min(pow(2, Double(i)), point.magnitude)
            } else {
                let angle = Double(i+1-numberOfPreciseSegments) / Double(numberOfSegments-numberOfPreciseSegments) * 2 * .pi
                point = orbit.ellipsePosition3D(orbit.trueAnomaly - angle) * scale / size - currentPosition
            }
            let length = Float((point - lastPoint).magnitude)
            
            let position = ((point + lastPoint) / 2).simdf
            let orientation = simd_quatf(from: [1,0,0], to: normalize((point - lastPoint).simdf))
            
            if duration == 0 {
                points[i].position = position
                
                let scale = distance(points[i].position(relativeTo: nil), cameraPosition) * extraScale
                
                segments[i].position = .zero
                segments[i].scale = [length, scale, scale]
                segments[i].orientation = orientation
            } else {
                let transform1 = Transform(translation: position)
                points[i].move(to: transform1, relativeTo: points[i].parent, duration: duration, timingFunction: .easeInOut)
                
                let scale = distance(points[i].position(relativeTo: nil), cameraPosition) * extraScale
                
                segments[i].orientation = orientation
                let transform2 = Transform(scale: [length, scale, scale], rotation: segments[i].orientation)
                segments[i].move(to: transform2, relativeTo: points[i], duration: duration, timingFunction: .easeInOut)
            }
            
            lastPoint = point
        }
    }
}



// MARK: - ORIGINAL COMPONENT

//class OrbitComponent: Component {
//    
//    var node: Node
//    
//    private let numberOfSegments: Int = 50
//    
//    private var scale: CGFloat
//    private var size: CGFloat
//    
//    private var segments: [ModelEntity] = []
//    var model: Entity
//    
//    init?(node: Node, size: CGFloat, scale: CGFloat = 1.0, thickness: Float = 0.001, cameraPosition: SIMD3<Float> = .zero) {
//        guard node.orbit != nil else { return nil }
//          
//        self.node = node
//        self.size = size
//        self.scale = 1.0
//        
//        self.model = Entity()
//        
//        for i in 1...numberOfSegments {
//            let thickness: Float = node.object?.category == .planet ? 0.5 : 0.4
//            let mesh = MeshResource.generateBox(width: 1.0, height: thickness, depth: thickness)
//            #if os(iOS) || os(visionOS)
//            var material = UnlitMaterial(color: UIColor(node.color ?? .gray))
//            material.blending = .transparent(opacity: .init(floatLiteral: 1.0 - Float(i) / Float(numberOfSegments)))
//            #elseif os(macOS)
//            let material = UnlitMaterial(color: NSColor(node.color ?? .gray))
//            #endif
//            let segment = ModelEntity(mesh: mesh, materials: [material])
//            segments.append(segment)
//            model.addChild(segment)
//        }
//        
//        update(isEnabled: true, isVisible: true, isSelected: false, noSelection: true, scale: scale, thickness: thickness, cameraPosition: cameraPosition)
//    }
//    
//    func update(isEnabled: Bool, isVisible: Bool, isSelected: Bool, noSelection: Bool, scale: CGFloat, thickness: Float, cameraPosition: SIMD3<Float>, duration: Double = 0) {
//        model.isEnabled = isEnabled
//        guard isEnabled, let orbit = node.orbit, !segments.isEmpty else { self.scale = scale; return }
//        
//        let currentPosition = (node.position - node.barycenterPosition) * scale / size
//        var lastPoint: Vector = .zero
//        let scaleRatio = Float(self.scale / scale)
//        let extraScale: Float = thickness * (isVisible ? 1 : 0) * (isSelected ? 1.1 : noSelection ? 1.0 : 0.8)
//        self.scale = scale
//        
//        if duration != 0 {
//            model.scale = SIMD3(repeating: scaleRatio)
//            model.move(to: Transform(), relativeTo: model.parent, duration: duration, timingFunction: .easeInOut)
//        }
//        
//        for i in 0..<segments.endIndex {
//        
//            let angle = Double(i+1) / Double(numberOfSegments) * 2 * .pi
//            let point = orbit.ellipsePosition3D(orbit.trueAnomaly - angle) * scale / size - currentPosition
//            let length = Float((point - lastPoint).magnitude)
//            
//            segments[i].position = ((point + lastPoint) / 2).simdf
//            segments[i].orientation = simd_quatf(from: [1,0,0], to: normalize((point - lastPoint).simdf))
//            
//            if duration == 0 {
//                segments[i].scale = [length, extraScale, extraScale]
//            } else {
//                segments[i].scale = [length, extraScale/scaleRatio, extraScale/scaleRatio]
//                let transform = Transform(scale: [length, extraScale, extraScale], rotation: segments[i].orientation, translation: segments[i].position)
//                segments[i].move(to: transform, relativeTo: segments[i].parent, duration: duration, timingFunction: .easeInOut)
//            }
//            
//            lastPoint = point
//        }
//    }
//}



// MARK: UPDATED & OPTIMIZED COMPONENT FOR IOS 18

// to do
