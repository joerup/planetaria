//
//  LightComponent.swift
//
//
//  Created by Joe Rupertus on 1/11/24.
//

import RealityKit

class LightComponent: Component {
    
    var model: Entity
    
    #if !os(visionOS)
    private var intensity: Double
    private var light: PointLightComponent
    #endif
    
    init?(node: Node, size: Double) {
        guard let object = node as? ObjectNode, object.luminosity > 0 else { return nil }
        self.model = Entity()
        
        #if !os(visionOS)
        self.intensity = object.intensity * 1000
        self.light = PointLightComponent(intensity: Float(intensity), attenuationRadius: 1E+20)
        
        model.components.set(light)
        #endif
    }
    
    func update(scale: Double) {
        
    }
}
