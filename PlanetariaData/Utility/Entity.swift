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
    
    static func generateScene() async -> Entity? {
        #if os(visionOS)
        guard let resource = try? await TextureResource(named: "sky", in: .module) else { return nil }
        #else
        guard let resource = try? TextureResource.load(named: "sky", in: .module) else { return nil }
        #endif
        
        var material = UnlitMaterial()
        material.color = .init(texture: .init(resource))
        let entity = ModelEntity(mesh: .generateBox(size: 1E+10), materials: [material])
        entity.scale *= .init(x: -1, y: 1, z: 1)
        
        return entity
    }
    
    static func registerAll() {
        BodyComponent.registerComponent()
        LabelComponent.registerComponent()
        OrbitComponent.registerComponent()
        PointComponent.registerComponent()
        
        SimulationComponent.registerComponent()
        SimulationSystem.registerSystem()
        
        BillboardComponent.registerComponent()
        BillboardSystem.registerSystem()
    }
    
    func lighten() {
        #if os(visionOS)
        Task {
            guard let resource = try? await EnvironmentResource(named: "light") else { return }
            var iblComponent = ImageBasedLightComponent(source: .single(resource), intensityExponent: 0)
            iblComponent.inheritsRotation = true
            components.set(iblComponent)
            components.set(ImageBasedLightReceiverComponent(imageBasedLight: self))
        }
        #endif
    }
}

class BillboardComponent: Component, Codable {
    var isActive: Bool = false
    
    public init() { }
}

class BillboardSystem: System {
    
    private static let query = EntityQuery(where: .has(BillboardComponent.self))
    
    private var root: SimulationRootEntity?
    private var simulation: Simulation?
    
    required init(scene: RealityKit.Scene) { }
    
    func update(context: SceneUpdateContext) {
        guard let root, let simulation else {
            if let root = context.scene.findEntity(named: "root") as? SimulationRootEntity {
                self.root = root
                self.simulation = root.simulation
            }
            return
        }
        
        context.scene.performQuery(Self.query).forEach { entity in
            guard let billboard = entity.component(BillboardComponent.self), !(simulation.inTransition && billboard.isActive) else { return }
            billboard.isActive = true
            
            let entityPosition = entity.position(relativeTo: nil)
            let target = entityPosition - (root.cameraPosition - entityPosition)
            
            entity.look(at: target, from: entityPosition, relativeTo: nil)
        }
    }
}
