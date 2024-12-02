//
//  OrbitComponent.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 1/14/24.
//

import SwiftUI
import RealityKit

// An orbit trail behind an object
@available(iOS 18.0, macOS 15.0, visionOS 2.0, *)
@MainActor class OrbitComponent: Component {
    
    enum TrailType {
        case partial
        case full
    }
    
    let model: Entity
    let type: TrailType
    
    private let node: Node
    private let size: Double
    
    private var angles: [Double] = []
    
    private var fadeSegments: Int = 20
    private var segments: Int = 150
    
    private var fadeAlphas: [Float] = []
    
    private var opacity: Float = 1.0
    
    private var isSmallOrbit: Bool
    
    fileprivate var vertexBuffer: UnsafeMutableBufferPointer<OrbitVertex>?
    
    init?(node: Node, size: Double, type: TrailType) {
        guard let orbit = node.orbit, orbit.position.magnitude > node.size else { return nil }
        
        self.model = Entity()
        self.type = type
        self.node = node
        self.size = size
        
        self.isSmallOrbit = orbit.position.magnitude < 10 * node.size
        
        setAngles()
        
        do {
            let lowLevelMesh = try initialMesh(color: node.color ?? .gray)
            lowLevelMesh.withUnsafeMutableBytes(bufferIndex: 0) { rawBytes in
                self.vertexBuffer = rawBytes.bindMemory(to: OrbitVertex.self)
            }
            Task {
                let resource = try await MeshResource(from: lowLevelMesh)
                let material = try await ShaderGraphMaterial(named: "/Root/ColorMaterial", from: "ColorMaterialScene")
                let modelComponent = ModelComponent(mesh: resource, materials: [material])
                model.components.set(modelComponent)
            }
        } catch {
            return nil
        }
    }
    
    func update(isEnabled: Bool, scale: Double, orientation: simd_quatf, opacity: Float, fadeFraction: Float, anchored: Bool) {
        model.isEnabled = isEnabled
        guard isEnabled, let vertexBuffer, let orbit = node.orbit else { return }
        
        // Offset the orbit by the current position
        let currentPoint = orbit.ellipsePosition(orbit.centralAnomaly) / size
        
        // Calculate the offset to align the trail to the body's center
        // (this is really only a correction for Earth)
        let objectOffset: SIMD3<Float> =
        if let object = node.object, node != object, object.orbit != nil, object.name == "Earth" {
            orientation.act((object.position * scale / size).toFloat())
        } else {
            .zero
        }
        
        // Compute the total orientation
        let totalOrientation = orientation * simd_quatf(angle: Float(orbit.orbitalInclination), axis: orbit.lineOfNodes.toFloat()) * simd_quatf(angle: Float(orbit.longitudeOfPeriapsis), axis: [0,1,0])
        
        if anchored && !isSmallOrbit {
            // The vertex buffer is given coordinates relative to the object
            // (this is necessary to prevent floating-point precision errors when looking at a far-away object close-up)
            // There is no need for an anchor offset because it's already anchored to the object
             
            // Start the trail at zero (relative to the current point)
            vertexBuffer[0].position = .zero
            
            // Compute segment points to make the trail (relative to the current point)
            for i in 1..<segments {
                let angle = orbit.centralAnomaly - angles[i]
                let point = orbit.ellipsePosition(angle) / size - currentPoint
                
                vertexBuffer[i].position = point.toFloat()
            }
            
            // Apply transforms
            model.scale = SIMD3(repeating: Float(scale))
            model.orientation = totalOrientation
            model.position = objectOffset
            
        } else {
            // The vertex buffer is given coordinates relative to the orbit center
            // (this is necessary to prevent jittering bug on visionOS)
            // The model coordinates are relative to the object so the entire model is offset to correct for this
            
            // Start the trail at the object's current position
            vertexBuffer[0].position = currentPoint.toFloat()
            
            // Compute segment points to make the trail
            for i in 1..<segments {
                let angle = orbit.centralAnomaly - Double(i) / Double(segments) * 2 * .pi
                let point = orbit.ellipsePosition(angle) / size
                
                vertexBuffer[i].position = point.toFloat()
            }
            
            // Calculate the anchor offset to align the trail to the object
            let anchorOffset = -totalOrientation.act(currentPoint.toFloat() * Float(scale))
            
            // Apply transforms
            model.scale = SIMD3(repeating: Float(scale))
            model.orientation = totalOrientation
            model.position = anchorOffset + objectOffset
        }
        
        // Update the fade segments
        for i in 0..<fadeSegments {
            // fadeFraction ranges from 0.0 (when object is large) to 1.0 (when object is small)
            let alphaFloat = fadeAlphas[i] * (1-fadeFraction) + fadeFraction * (type == .partial ? 0.5 : 1.0)
            let alpha = UInt32(255 * alphaFloat) << 24
            vertexBuffer[i].color = vertexBuffer[i].color & 0x00FFFFFF | alpha
        }
        
        // Apply opacity
        let opacity = isSmallOrbit ? (opacity * fadeFraction) : opacity
        if self.opacity != opacity {
            self.opacity = opacity
            model.components.remove(OpacityComponent.self)
            model.components.set(OpacityComponent(opacity: opacity))
        }
    }
    
    private func initialMesh(color: Color) throws -> LowLevelMesh {
        var desc = OrbitVertex.descriptor
        desc.vertexCapacity = segments
        desc.indexCapacity = segments

        let mesh = try LowLevelMesh(descriptor: desc)
        
        let hex = color.hex
        
        // Fill vertex data to create gradient
        mesh.withUnsafeMutableBytes(bufferIndex: 0) { rawBytes in
            let vertices = rawBytes.bindMemory(to: OrbitVertex.self)
            
            for i in 0..<fadeSegments {
                let fraction = pow(Float(i) / Float(fadeSegments), 2.0) * (type == .partial ? 0.5 : 1.0)
                self.fadeAlphas.append(fraction)
                let alpha = UInt32(255 * fraction) << 24
                vertices[i].color = hex & 0x00FFFFFF | alpha
            }
            for i in fadeSegments..<segments {
                let fraction = (1 - Float(i) / Float(segments)) * (type == .partial ? 0.5 : 1.0)
                let alpha = UInt32(255 * fraction) << 24
                vertices[i].color = hex & 0x00FFFFFF | alpha
            }
        }

        // Fill index data to connect points in a line
        mesh.withUnsafeMutableIndices { rawIndices in
            let indices = rawIndices.bindMemory(to: UInt32.self)
            for i in 0..<segments {
                indices[i] = UInt32(i)
            }
        }
        
        // Define the bounding box
        let distance = 4 * Float(node.position.magnitude / size)
        let meshBounds = BoundingBox(
            min: [-distance, -distance, -distance],
            max: [ distance,  distance,  distance]
        )

        // Set mesh part
        mesh.parts.replaceAll([
            LowLevelMesh.Part(
                indexCount: segments,
                topology: .lineStrip,
                bounds: meshBounds
            )
        ])

        return mesh
    }
    
    private func setAngles() {
        let fraction = (node.object?.size ?? node.size) / (node.position.magnitude)
        let minAngle = atan(fraction)
        let fadeFactor: Double = 10.0 // orbit will reach full opacity at at this factor of the object size
        let fadeAngle = atan(fadeFactor * fraction)
        
        let param: Double = 0.7
        let power: Double = 2.0
        
        let fadeAngles = (0..<fadeSegments).map { i in
            let t = Double(i) / Double(fadeSegments-1)
            return minAngle + (fadeAngle - minAngle) * t
        }
        let angles = (fadeSegments..<segments).map { i in
            let t = Double(i - fadeSegments) / Double(segments - fadeSegments)
            if t < param {
                return 0.5 * pow(t / param, power) * (2 * Double.pi - fadeAngle) + fadeAngle
            } else {
                return (0.5 + (t - param) * (0.5 / (1 - param))) * (2 * Double.pi - fadeAngle) + fadeAngle
            }
        }
        
        self.angles = fadeAngles + angles
    }
}

@available(iOS 18.0, macOS 15.0, visionOS 2.0, *)
fileprivate struct OrbitVertex {
    var position: SIMD3<Float> = .zero
    var color: UInt32 = .zero
}

@available(iOS 18.0, macOS 15.0, visionOS 2.0, *)
fileprivate extension OrbitVertex {
    static var vertexAttributes: [LowLevelMesh.Attribute] = [
        .init(semantic: .position, format: .float3, offset: MemoryLayout<Self>.offset(of: \.position)!),
        .init(semantic: .color, format: .uchar4Normalized_bgra, offset: MemoryLayout<Self>.offset(of: \.color)!)
    ]

    static var vertexLayouts: [LowLevelMesh.Layout] = [
        .init(bufferIndex: 0, bufferStride: MemoryLayout<Self>.stride)
    ]

    static var descriptor: LowLevelMesh.Descriptor {
        var desc = LowLevelMesh.Descriptor()
        desc.vertexAttributes = OrbitVertex.vertexAttributes
        desc.vertexLayouts = OrbitVertex.vertexLayouts
        desc.indexType = .uint32
        return desc
    }
}




// MARK: - ORIGINAL COMPONENT FOR IOS 17 AND BELOW

class OrbitComponentLegacy: Component {
    
    var node: Node
    
    private let numberOfSegments: Int = 50
    
    private var size: Double
    
    private var segments: [ModelEntity] = []
    var model: Entity
    
    init?(node: Node, size: Double) {
        guard let orbit = node.orbit, orbit.position.magnitude > node.size, node.rank == .primary else { return nil }
          
        self.node = node
        self.size = size
        
        self.model = Entity()
        
        for i in 1...numberOfSegments {
            let thickness: Float = node.object?.category == .planet ? 0.5 : 0.4
            let mesh = MeshResource.generateBox(width: 1.0, height: thickness, depth: thickness)
            var material = UnlitMaterial(color: ColorType((node.color ?? .gray).lighter()))
            material.blending = .transparent(opacity: .init(floatLiteral: 1.0 - Float(i) / Float(numberOfSegments)))
            let segment = ModelEntity(mesh: mesh, materials: [material])
            segments.append(segment)
            model.addChild(segment)
        }
    }
    
    func update(isEnabled: Bool, isVisible: Bool, isSelected: Bool, noSelection: Bool, scale: Double, orientation: simd_quatf, thickness: Float, modelPosition: SIMD3<Float>, cameraPosition: SIMD3<Float>) {
        model.isEnabled = isEnabled
        guard isEnabled, let orbit = node.orbit, !segments.isEmpty else { return }
        
        let currentPosition = (node.position - node.barycenterPosition) * scale / size
        var lastPoint: Vector3 = .zero
        let extraScale: Float = thickness * 0.5 * (isVisible ? 1 : 0) * (isSelected ? 1.1 : noSelection ? 1.0 : 0.8)
        
        for i in 0..<segments.endIndex {
        
            let angle = Double(i+1) / Double(numberOfSegments) * 2 * .pi
            let point = orbit.ellipsePosition3D(orbit.trueAnomaly - angle) * scale / size - currentPosition
            let length = Float((point - lastPoint).magnitude)
            
            segments[i].position = orientation.act((point + lastPoint).toFloat() / 2)
            segments[i].orientation = orientation * simd_quatf(from: [1,0,0], to: normalize(point - lastPoint).toFloat())
            segments[i].scale = [length, extraScale, extraScale]
            
            lastPoint = point
        }
    }
}

