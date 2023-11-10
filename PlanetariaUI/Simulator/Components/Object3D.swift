//
//  Object3D.swift
//  
//
//  Created by Joe Rupertus on 9/4/23.
//

import SwiftUI
import PlanetariaData
import RealityKit

struct Object3D: View {
    
    var object: ObjectNode
    
    var pitch: Angle
    var rotation: Angle
    
    var simulation: Bool
    
    // Static Model
    init(object: ObjectNode) {
        self.pitch = .degrees(0)
        self.rotation = .degrees(0)
        self.object = object
        self.simulation = false
    }
    // Dynamic Model
    init(object: ObjectNode, pitch: Angle, rotation: Angle) {
        self.pitch = pitch
        self.rotation = rotation
        self.object = object
        self.simulation = true
    }
    
    var body: some View {
        #if os(visionOS)
        Model3D(named: "\(object.name).usdz")
        #elseif os(iOS) || os(macOS) || os(tvOS)
        ObjectBody(object: object, pitch: pitch, rotation: rotation, simulation: simulation)
        #endif
    }
}
