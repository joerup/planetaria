//
//  
// SimulationEntity.swift
//
//
//  Created by Joe Rupertus on 1/5/24.
//

import RealityKit

class SimulationEntity: Entity {
    
    private(set) var node: Node?
    
    private var coordinates: Vector = .zero
    
    @MainActor required init() { }
    
    init(node: Node, size: Double) async {
        self.node = node
        
        self.coordinates = node.globalPosition / size
        
        super.init()
        
        self.name = "\(node.id)"
        self.position = coordinates.simdf
        
        if let point = PointComponent(node: node) {
            components.set(point)
            addChild(point.model)
        }
        if let body = BodyComponent(node: node, size: size) {
            components.set(body)
            addChild(body.model)
        }
        if let orbit = OrbitComponent(node: node, size: size) {
            components.set(orbit)
            addChild(orbit.model)
        }
//        if let label = LabelComponent(node: node, size: size) {
//            components.set(label)
//            addChild(label.model)
//        }
//        if let light = LightComponent(node: node, size: size) {
//            components.set(light)
//            addChild(light.model)
//        }
    }
    
    func update(scale: Double, offset: Vector, orientation: simd_quatf, duration: Double) {
        animate(position: (coordinates - offset) * scale, duration: duration)
        
        if let body = component(BodyComponent.self) {
            body.update(scale: scale, duration: duration)
        }
        if let orbit = component(OrbitComponent.self) {
            orbit.update(scale: scale, duration: duration)
        }
        if let label = component(LabelComponent.self) {
            label.update(scale: scale, orientation: orientation, duration: duration)
        }
        if let light = component(LightComponent.self) {
            light.update(scale: scale)
        }
    }
    
    private func animate(position: Vector? = nil, scale: Double? = nil, duration: Double) {
        let newPosition = position?.simdf ?? self.position
        let newScale = if let scale { Float(scale) } else { self.scale.max() }
        
        if duration == 0 {
            self.position = newPosition
            self.scale = SIMD3(repeating: newScale)
        } else {
            let transform = Transform(scale: SIMD3(repeating: newScale), rotation: orientation, translation: newPosition)
            move(to: transform, relativeTo: parent, duration: duration, timingFunction: .easeInOut)
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
