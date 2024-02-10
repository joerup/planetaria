//
//  SimulationEntity.swift
//  PlanetariaData
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
        if let label = LabelComponent(node: node) {
            components.set(label)
            addChild(label.model)
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
    var target = TargetSelector()
    
    #if os(iOS) || os(macOS)
    var arView: ARView?
    #endif
    
    required init() {
        super.init()
        self.name = "root"
    }
    
    private static let query = EntityQuery(where: .has(SimulationComponent.self))
    
    func transition(scale: CGFloat, offset: Vector, duration: Double = 0) {
        guard let simulation else { return }
        
        // Transition models
        scene?.performQuery(Self.query).forEach { entity in
            guard let configuration = entity.component(SimulationComponent.self) else { return }
            
            let position = configuration.position(scale: scale, offset: offset)
            let transform = Transform(scale: entity.scale, rotation: entity.orientation, translation: position)
            entity.move(to: transform, relativeTo: entity.parent, duration: duration, timingFunction: .easeInOut)
            
            let isEnabled = simulation.selectedSystem == configuration.node.parent
            let isSelected = simulation.isSelected(configuration.node)
            let orbitEnabled = simulation.showOrbits && isEnabled && (isSelected || configuration.node.rank == .primary)
            let trailVisibile = simulation.trailVisible(configuration.node)
            let labelVisible = simulation.labelVisible(configuration.node)
            
            if let body = entity.component(BodyComponent.self) {
                body.update(isEnabled: isEnabled, scale: scale, duration: duration)
            }
            if let point = entity.component(PointComponent.self) {
                point.update(isEnabled: isEnabled, thickness: simulation.entityThickness)
            }
            if let orbit = entity.component(OrbitComponent.self) {
                orbit.update(isEnabled: orbitEnabled, isVisible: trailVisibile, isSelected: isSelected, noSelection: simulation.noSelection, scale: scale, thickness: simulation.entityThickness, duration: duration)
            }
            if let label = entity.component(LabelComponent.self) {
                label.update(isEnabled: isEnabled, isVisible: labelVisible, thickness: simulation.entityThickness)
            }
            
            if isSelected {
                setTarget(entity)
            }
        }
    }
    
    func setTarget(_ entity: Entity) {
        if entity != target.parent {
            target.removeFromParent()
            entity.addChild(target)
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
            var iblComponent = ImageBasedLightComponent(source: .single(resource), intensityExponent: 0.5)
            iblComponent.inheritsRotation = true
            components.set(iblComponent)
            components.set(ImageBasedLightReceiverComponent(imageBasedLight: self))
        }
        #endif
    }
}
