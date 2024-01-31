//
//  SimulationEntity.swift
//
//
//  Created by Joe Rupertus on 1/5/24.
//

import RealityKit
import SwiftUI

class SimulationEntity: Entity {
    
    @MainActor required init() { }
    
    init(node: Node, size: Double) async {
        super.init()
        
        self.name = "\(node.id)"
        
        components.set(SimulationComponent(node: node, size: size))
        
        if let body = BodyComponent(node: node, size: size) {
            components.set(body)
            addChild(body.model)
        }
        if let point = PointComponent(node: node) {
            components.set(point)
            addChild(point.model)
        }
        if let orbit = OrbitComponent(node: node, size: size) {
            components.set(orbit)
            addChild(orbit.model)
        }
    }
    
    var physicalBounds: BoundingBox {
        if let body = component(BodyComponent.self) {
            return body.model.visualBounds(relativeTo: nil)
        } else {
            return .init(min: .zero, max: .zero)
        }
    }
}

class SimulationRootEntity: Entity {
    
    var simulation: Simulation?
    
    #if os(iOS) || os(macOS)
    var arView: ARView?
    #endif
    
    required init() { 
        super.init()
        self.name = "root"
    }
    
    private static let query = EntityQuery(where: .has(SimulationComponent.self))
    
    func transition(scale: CGFloat, offset: Vector, duration: Double) {
        guard let simulation else { return }
        
        // Transition models
        scene?.performQuery(Self.query).forEach { entity in
            guard let configuration = entity.component(SimulationComponent.self) else { return }
            
            let position = configuration.position(scale: scale, offset: offset)
            let transform = Transform(scale: entity.scale, rotation: entity.orientation, translation: position)
            entity.move(to: transform, relativeTo: entity.parent, duration: duration, timingFunction: .easeInOut)
            
            let isEnabled = simulation.selectedSystem == configuration.node.parent
            let isSelected = simulation.isSelected(configuration.node)
            let orbitEnabled = isEnabled && (isSelected || configuration.node.rank == .primary)
            let trailVisibile = simulation.trailVisible(configuration.node)
            
            if let body = entity.component(BodyComponent.self) {
                body.update(isEnabled: isEnabled, scale: scale, duration: duration)
            }
            if let point = entity.component(PointComponent.self) {
                point.update(isEnabled: isEnabled, thickness: simulation.entityThickness)
            }
            if let orbit = entity.component(OrbitComponent.self) {
                orbit.update(isEnabled: orbitEnabled, isVisible: trailVisibile, scale: scale, thickness: simulation.entityThickness, duration: duration)
            }
        }
    }
    
    func rotate(rotation: Angle, pitch: Angle, duration: Double = 0) {
        let orientation = simd_quatf(angle: Float(pitch.radians), axis: SIMD3(1,0,0)) * simd_quatf(angle: Float(-rotation.radians), axis: SIMD3(0,1,0))
        
        if duration == 0 {
            self.orientation = orientation
        } else {
            let transformation = Transform(rotation: orientation)
            self.move(to: transformation, relativeTo: parent, duration: duration, timingFunction: .easeInOut)
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
    
    func lighten() {
        #if os(visionOS)
        Task {
            guard let resource = try? await EnvironmentResource(named: "light") else { return }
            var iblComponent = ImageBasedLightComponent(source: .single(resource), intensityExponent: 1)
            iblComponent.inheritsRotation = true
            components.set(iblComponent)
            components.set(ImageBasedLightReceiverComponent(imageBasedLight: self))
        }
        #endif
    }
}
