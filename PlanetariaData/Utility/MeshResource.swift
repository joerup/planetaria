//
//  MeshResource.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 10/13/24.
//

import RealityKit

extension MeshResource {
        
    static func generateCircle(radius: Float) async throws -> MeshResource {
    
        // Define the number of segments for the circle
        let segments = 36
        var positions: [SIMD3<Float>] = []
        var indices: [UInt32] = []

        // Calculate the angle step
        let angleStep = (2 * Float.pi) / Float(segments)

        // Generate positions for the circle
        for i in 0..<segments {
            let angle = angleStep * Float(i)
            let x = radius * cos(angle) // x coordinate
            let y = radius * sin(angle) // y coordinate
            positions.append(SIMD3<Float>(x, y, 0)) // Circle lies on the XY plane
        }

        // Generate indices for the triangles
        for i in 1..<segments - 1 {
            indices.append(0) // Center of the circle
            indices.append(UInt32(i))
            indices.append(UInt32(i + 1) % UInt32(segments))
        }

        // Create the mesh descriptor
        var descriptor = MeshDescriptor(name: "circle")
        descriptor.positions = MeshBuffers.Positions(positions)
        descriptor.primitives = .triangles(indices)

        return try await MeshResource(from: [descriptor])
    }
    
    static func generateRing(outerRadius: Float, innerRadius: Float) async throws -> MeshResource {
        // Define the number of segments for the ring
        let segments = 36
        var positions: [SIMD3<Float>] = []
        var indices: [UInt32] = []

        // Calculate the angle step
        let angleStep = (2 * Float.pi) / Float(segments)

        // Generate positions for the outer circle
        for i in 0..<segments {
            let angle = angleStep * Float(i)
            let xOuter = outerRadius * cos(angle) // Outer x coordinate
            let yOuter = outerRadius * sin(angle) // Outer y coordinate
            positions.append(SIMD3<Float>(xOuter, yOuter, 0)) // Outer circle lies on the XY plane
        }

        // Generate positions for the inner circle
        for i in 0..<segments {
            let angle = angleStep * Float(i)
            let xInner = innerRadius * cos(angle) // Inner x coordinate
            let yInner = innerRadius * sin(angle) // Inner y coordinate
            positions.append(SIMD3<Float>(xInner, yInner, 0)) // Inner circle lies on the XY plane
        }

        // Generate indices for the triangles forming the ring
        for i in 0..<segments {
            let nextIndex = (i + 1) % segments
            
            // Outer triangle
            indices.append(UInt32(i)) // Outer vertex
            indices.append(UInt32(nextIndex)) // Next outer vertex
            indices.append(UInt32(i + segments)) // Corresponding inner vertex

            // Inner triangle
            indices.append(UInt32(nextIndex)); // Next outer vertex
            indices.append(UInt32(nextIndex + segments)); // Corresponding inner vertex
            indices.append(UInt32(i + segments)); // Inner vertex
        }

        // Create the mesh descriptor
        var descriptor = MeshDescriptor(name: "ring")
        descriptor.positions = MeshBuffers.Positions(positions)
        descriptor.primitives = .triangles(indices)

        return try await MeshResource(from: [descriptor])
    }

}
