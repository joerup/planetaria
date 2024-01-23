//
//  LightComponent.swift
//
//
//  Created by Joe Rupertus on 1/11/24.
//

import RealityKit

class LightComponent: Component {
    
    var node: Node
    
    var model: Entity
    
    init?(node: Node, size: Double) {
        guard let node = node as? ObjectNode else { return nil }
        self.node = node
        
        self.model = Entity()
    }
    
    func update(scale: Double) {
        
    }
}
