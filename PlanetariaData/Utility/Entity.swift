//
//  Entity.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 2/4/24.
//

#if canImport(ARKit)
import ARKit
#endif
import Foundation
import RealityKit
import SwiftUI

extension Entity {
    
    func component<T: Component>(_ type: T.Type) -> T? {
        #if os(visionOS)
        guard let component = self.components[type] else { return nil }
        #else
        guard let component = self.components[type] as T? else { return nil }
        #endif
        return component
    }
    
    var globalDirection: SIMD3<Float> {
        return orientation(relativeTo: nil).inverse.act([0,0,-1])
    }
    
    func globalPosition(_ position: SIMD3<Float>) -> SIMD3<Float> {
        return orientation(relativeTo: nil).inverse.act(position/self.scale(relativeTo: nil) - self.position(relativeTo: nil))
    }
    
    func distanceScale(position: SIMD3<Float>, cameraPosition: SIMD3<Float>, cameraForward: SIMD3<Float>) -> Float {
        return abs(dot(position - cameraPosition, cameraForward))
    }
    
    func billboardOrientation(position: SIMD3<Float>, cameraPosition: SIMD3<Float>, toPoint: Bool) -> simd_quatf {
        guard let parent else { return .identity }
        if toPoint {
            let forward = normalize(cameraPosition - position)
            let right = normalize(cross([0,1,0], forward))
            let up = cross(forward, right)
            let rotationMatrix = simd_float3x3(right, up, forward)
            return simd_quatf(rotationMatrix)
        } else {
            let transform = Transform(matrix: parent.transformMatrix(relativeTo: nil))
            return transform.rotation.inverse
        }
    }
    
    static func registerAll() {
        SimulationComponent.registerComponent()
        SimulationSystem.registerSystem()
        
        InteractionComponent.registerComponent()
        BodyComponent.registerComponent()
        PointComponent.registerComponent()
        TargetComponent.registerComponent()
        LabelComponent.registerComponent()
        
        if #available(iOS 18.0, macOS 15.0, visionOS 2.0, *) {
            OrbitComponent.registerComponent()
        } else {
            OrbitComponentLegacy.registerComponent()
        }
    }
}
