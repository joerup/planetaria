//
//  SimulationEntity.swift
//
//
//  Created by Joe Rupertus on 1/5/24.
//

import RealityKit

class SimulationEntity: Entity {
    
    @MainActor required init() { }
    
    init(node: Node, size: Double) async {
        super.init()
        
        self.name = "\(node.id)"
        
        components.set(SimulationComponent(node: node, size: size))
        
        if let point = PointComponent(node: node) {
            components.set(point)
            addChild(point.model)
        }
        if let body = BodyComponent(node: node, size: size) {
            components.set(body)
            addChild(body.model)
        }
//        if let orbit = OrbitComponent(node: node, size: size) {
//            components.set(orbit)
//            addChild(orbit.model)
//        }
//        if let label = LabelComponent(node: node, size: size) {
//            components.set(label)
//            addChild(label.model)
//        }
//        if let light = LightComponent(node: node, size: size) {
//            components.set(light)
//            addChild(light.model)
//        }
    }
}

class SimulationRootEntity: Entity {
    
    var simulation: Simulation?
    
    required init() { }
    
    private static let query = EntityQuery(where: .has(SimulationComponent.self))
    
    func transition(scale: Double, offset: Vector, duration: Double) {
        scene?.performQuery(Self.query).forEach { entity in
            
            // Move the simulation entity
            if let component = entity.component(SimulationComponent.self) {
                let position = component.position(scale: scale, offset: offset)
                let transform = Transform(scale: entity.scale, rotation: entity.orientation, translation: position)
                entity.move(to: transform, relativeTo: entity.parent, duration: duration, timingFunction: .easeInOut)
            }
            
            if let body = entity.component(BodyComponent.self) {
                body.update(scale: scale, duration: duration)
            }
            if let orbit = entity.component(OrbitComponent.self) {
                orbit.update(scale: scale, duration: duration)
            }
        }
    }
}


extension Entity {
    
    func component<T: Component>(_ type: T.Type) -> T? {
        #if os(visionOS)
        guard let component = self.components[type] else { return nil }
        #else
        guard let component = self.components[type] as T? else { return nil }
        #endif
        return component
    }
    
    static func generateBackground() async -> Entity? {
        #if os(visionOS)
        guard let resource = try? await TextureResource.load(named: "Starfield") else { return nil }
        #else
        guard let resource = try? TextureResource.load(named: "Starfield") else { return nil }
        #endif
        
        var material = UnlitMaterial()
        material.color = .init(texture: .init(resource))
        let entity = ModelEntity(mesh: .generateSphere(radius: 1E+10), materials: [material])
        entity.scale *= .init(x: -1, y: 1, z: 1)
        return entity
    }
}
