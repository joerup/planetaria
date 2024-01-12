//
//  LightComponent.swift
//
//
//  Created by Joe Rupertus on 1/11/24.
//

import RealityKit

class LightComponent: Component {
    
    var model: Entity
    
    private var intensity: Double
    private var light: PointLightComponent
    
    init?(node: Node, size: Double) {
        guard let object = node as? Object, object.luminosity > 0 else { return nil }
        
        self.intensity = object.intensity * 1000
        self.light = PointLightComponent(intensity: Float(intensity), attenuationRadius: 1E+20)
        
        self.model = Entity()
        model.components.set(light)
    }
    
    func update(scale: Double) {
        
    }
}
