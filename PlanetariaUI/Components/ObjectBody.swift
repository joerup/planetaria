//
//  ObjectBody.swift
//
//
//  Created by Joe Rupertus on 9/4/23.
//

import SwiftUI
import PlanetariaData
#if os(visionOS)
import RealityKit
#endif

struct ObjectBody: View {
    
    var object: Object
    
    var pitch: Angle
    var rotation: Angle
    
    var simulation: Bool
    
    // Static Model
    init(object: Object) {
        self.pitch = .degrees(0)
        self.rotation = .degrees(0)
        self.object = object
        self.simulation = false
    }
    // Dynamic Model
    init(object: Object, pitch: Angle, rotation: Angle) {
        self.pitch = pitch
        self.rotation = rotation
        self.object = object
        self.simulation = true
    }
    
    var body: some View {
#if os(visionOS)
        //        RealityView { context in
        //            let entity = try Entity(named: "\(object.name).usdz")
        //            context.add(entity)
        //        }
#elseif os(iOS) || os(macOS) || os(tvOS)
//        ObjectBody3D(object: object, pitch: pitch, rotation: rotation, simulation: simulation)
#endif
        Circle().fill(object.color ?? .gray)
    }
}
