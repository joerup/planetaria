//
//  SimulationComponent.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 1/13/24.
//

import RealityKit
import SwiftUI

class SimulationComponent: Component {
    
    private(set) var entity: SimulationEntity
    private(set) var node: Node
    private(set) var size: Double
    
    var isSelected: Bool = false
    
    init(entity: SimulationEntity, node: Node, size: Double) {
        self.entity = entity
        self.node = node
        self.size = size
    }
    
    // Get the position for this object, taking into account the current scale and offset
    func position(scale: Double, offset: Vector) -> SIMD3<Float> {
        let position = scale * (node.globalPosition - offset) / size
        return position.simdf
    }
}
