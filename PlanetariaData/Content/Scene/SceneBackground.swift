//
//  SceneBackground.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 10/3/24.
//

#if canImport(ARKit)
import ARKit
#endif
import RealityKit

class SceneBackground: Entity {
    private let textureName = "sky"
    
    static let scaleLimit: Float = 1E+12 // distance limit after which logarithmic scaling begins
    static let maxDistance: Float = 1E+16 // theoretical max distance (this function will map maxDistance -> 2*scaleLimit)
    
    required init() {
        super.init()
        
        Task {
            #if os(visionOS)
            guard let resource = try? await TextureResource(named: textureName, in: .module) else { return }
            #elseif os(iOS) || os(macOS)
            var resource: TextureResource
            if #available(iOS 18, macOS 15, *) {
                guard let r = try? await TextureResource(named: textureName, in: .module) else { return }
                resource = r
            } else {
                guard let r = try? TextureResource.load(named: textureName, in: .module) else { return }
                resource = r
            }
            #endif
            
            var material = UnlitMaterial()
            material.color = .init(texture: .init(resource))
            let component = ModelComponent(mesh: .generateBox(size: 4 * Self.scaleLimit), materials: [material])
            
            self.components.set(component)
            self.scale *= .init(x: -1, y: 1, z: 1)
        }
    }
    
    func update(orientation: simd_quatf) {
        self.orientation = orientation
    }
}

public extension SIMD3<Float> {
    
    // Constrain entity positions to be within a reasonable radius
    var constrainFactor: Float {
        let scaleLimit = SceneBackground.scaleLimit
        let maxDistance = SceneBackground.maxDistance
        
        if length(self) <= scaleLimit {
            return 1.0
        } else {
            return scaleLimit/length(self) * (1 + log(length(self) / scaleLimit) / log(maxDistance / scaleLimit))
        }
    }
    func constrainFactor(scale: Float) -> Float {
        let scaleLimit = SceneBackground.scaleLimit / scale
        let maxDistance = SceneBackground.maxDistance / scale
        
        if length(self) <= scaleLimit {
            return 1.0
        } else {
            return scaleLimit/length(self) * (1 + log(length(self) / scaleLimit) / log(maxDistance / scaleLimit))
        }
    }
}
