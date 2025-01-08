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
    func position(scale: Double, orientation: simd_quatf, offset: Vector3, center: SIMD3<Float>) -> SIMD3<Float> {
        let position = (node.globalPosition - offset) * scale / size
        let scaledOffset = center * Float(scale / size)
        return orientation.act(position.toFloat()) + scaledOffset
    }
}
