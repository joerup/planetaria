//
//  TargetSelector.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 2/4/24.
//

import Foundation
import RealityKit

class TargetSelector: Entity {
    
    private let numberOfSides: Int = 50
    
    required init() {
        super.init()
        
        for i in 0..<numberOfSides {
            let angle = Double(i)/Double(numberOfSides) * 2 * .pi
            let segment = MeshResource.generateBox(width: 1, height: 0.3, depth: 0.3)
            let model = ModelEntity(mesh: segment, materials: [UnlitMaterial(color: .white)])
            self.addChild(model)
            model.position = simd_quatf(angle: Float(angle), axis: [0,0,1]).act([1,0,0])
            model.orientation = simd_quatf(angle: Float(angle + .pi/2), axis: [0,0,1])
        }
        
        components.set(BillboardComponent())
        
        #if os(visionOS)
        components.set(InputTargetComponent())
        components.set(HoverEffectComponent())
        #endif
    }
    
    func update(isEnabled: Bool, thickness: Float) {
        self.isEnabled = isEnabled
        self.position = .zero
        self.scale = SIMD3(repeating: 2 * thickness)
    }
}
