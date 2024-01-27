//
//  SimulationComponent.swift
//  
//
//  Created by Joe Rupertus on 1/13/24.
//

import RealityKit
import SwiftUI

class SimulationComponent: Component {
    
    private(set) var node: Node
    private var size: Double
    
    var screenPosition: CGPoint = .zero
    
    init(node: Node, size: Double) {
        self.node = node
        self.size = size
    }
    
    func position(scale: Double, offset: Vector) -> SIMD3<Float> {
        let position = scale * (node.globalPosition - offset) / size
        return position.simdf
    }
}
