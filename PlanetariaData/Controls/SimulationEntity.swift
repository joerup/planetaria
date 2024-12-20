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
    
    init(node: Node, size: Double, root: SimulationRootEntity) async {
        super.init()
        root.addChild(self)
        
        self.name = "\(node.id)"
        
        components.set(SimulationComponent(entity: self, node: node, size: size))
        
        let interaction = InteractionComponent(node: node, size: size, debugMode: SimulationRootEntity.debugMode)
        components.set(interaction)
        root.addChild(interaction.primaryEntity)
        root.addChild(interaction.secondaryEntity)
        
        if let body = BodyComponent(node: node, size: size) {
            components.set(body)
            addChild(body.model)
        }
        if let point = PointComponent(node: node) {
            components.set(point)
            addChild(point.model)
        }
        if let label = LabelComponent(node: node) {
            components.set(label)
            addChild(label.model)
        }
        if #available(iOS 18.0, macOS 15.0, visionOS 2.0, *) {
            if let orbit = OrbitComponent(node: node, size: size, type: node.rank == .primary ? .full : .partial) {
                components.set(orbit)
                addChild(orbit.model)
            }
        } else {
            if let orbit = OrbitComponentLegacy(node: node, size: size) {
                components.set(orbit)
                addChild(orbit.model)
            }
        }
    }
    
    // Update entity in response to being selected
    func select() {
        guard let configuration = component(SimulationComponent.self) else { return }
        configuration.isSelected = true
        
        if let target = TargetComponent(node: configuration.node) {
            components.set(target)
            addChild(target.model)
        }
        if let label = component(LabelComponent.self) {
            label.select()
        }
    }
    
    // Update node in response to being deselected
    func deselect() {
        guard let configuration = component(SimulationComponent.self) else { return }
        configuration.isSelected = false
        
        if let target = component(TargetComponent.self) {
            components.remove(TargetComponent.self)
            removeChild(target.model)
        }
        if let label = component(LabelComponent.self) {
            label.deselect()
        }
    }
}
