//
//  SimulationEntity.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 1/5/24.
//

import Foundation
import RealityKit

class SimulationEntity: Entity {
    
    @MainActor required init() { }
    
    init(node: Node, size: Double) async {
        super.init()
        
        self.name = "\(node.id)"
        
        components.set(SimulationComponent(entity: self, node: node, size: size))
        
        if let point = PointComponent(node: node) {
            components.set(point)
            addChild(point.model)
        }
        
        guard node.rank == .primary else { return }
        
        if let body = BodyComponent(node: node, size: size) {
            components.set(body)
            addChild(body.model)
        }
        if let label = LabelComponent(node: node) {
            components.set(label)
            addChild(label.model)
        }
        if let orbit = OrbitComponent(node: node, size: size) {
            components.set(orbit)
            addChild(orbit.model)
        }
    }
    
    // Update entity in response to being selected
    func select(scale: CGFloat, thickness: Float, cameraPosition: SIMD3<Float>) {
        guard let configuration = component(SimulationComponent.self) else { return }
        configuration.isSelected = true
                
        guard configuration.node.rank < .primary else { return }
        
        if let body = BodyComponent(node: configuration.node, size: configuration.size) {
            components.set(body)
            addChild(body.model)
        }
        if let label = LabelComponent(node: configuration.node, thickness: thickness, cameraPosition: cameraPosition) {
            components.set(label)
            addChild(label.model)
        }
        if let orbit = OrbitComponent(node: configuration.node, size: configuration.size, scale: scale, thickness: thickness, cameraPosition: cameraPosition) {
            components.set(orbit)
            addChild(orbit.model)
        }
    }
    // Update node in response to being deselected
    func deselect() {
        guard let configuration = component(SimulationComponent.self) else { return }
        configuration.isSelected = false
                
        guard configuration.node.rank < .primary else { return }
        
        if let body = component(BodyComponent.self) {
            components.remove(BodyComponent.self)
            removeChild(body.model)
        }
        if let label = component(LabelComponent.self) {
            components.remove(LabelComponent.self)
            removeChild(label.model)
        }
        if let orbit = component(OrbitComponent.self) {
            components.remove(OrbitComponent.self)
            removeChild(orbit.model)
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
