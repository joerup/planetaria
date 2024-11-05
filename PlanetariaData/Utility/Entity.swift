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

public extension Entity {
    
    /// Finds all decendant entites with a model component.
    ///
    /// - Returns: An array of decendant entities that have a model component.
    private func getModelDescendents() -> [Entity] {
        var descendents = [Entity]()
        
        for child in children {
            if child.components[ModelComponent.self] != nil {
                descendents.append(child)
            }
            descendents.append(contentsOf: child.getModelDescendents())
        }
        return descendents
    }

    @available(iOS 18.0, macOS 15.0, visionOS 2.0, *)
    func setSunPosition(_ position: SIMD3<Float>) {
        for modelEntity in self.getModelDescendents() {
            guard var modelComponent = modelEntity.component(ModelComponent.self) else {
                return
            }

            // Tell any material that has a sun angle parameter about the
            // position of the sun so that it can adjust its appearance.
            modelComponent.materials = modelComponent.materials.map {
                guard var material = $0 as? ShaderGraphMaterial else { return $0 }
                if material.parameterNames.contains("sun_direction") {
                    do {
                        try material.setParameter(
                            name: "sun_direction",
                            value: .simd3Float(position)
                        )
                    } catch {
                        fatalError("Failed to set material parameter: \(error.localizedDescription)")
                    }
                }
                return material
            }
 
            modelEntity.components.set(modelComponent)
        }
    }
}
