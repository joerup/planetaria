//
//  MotionGuide.swift
//  Planetaria
//
//  Created by Joe Rupertus on 12/9/24.
//

import PlanetariaData
import Foundation
import SwiftUI

// A script to make the camera move in a specific way
// Used for testing and for promotional material
class MotionGuide {
    
    init(for simulation: Simulation) async {
        
        await simulation.transitionCamera(duration: 2.0)
        
        await simulation.resetTiming()
        await simulation.adjustTiming(speed: 1500000)
        
        if let mercury = simulation.getNode("Mercury") {
            await simulation.transitionCamera(toSize: mercury.size * 2.8, withRotation: .degrees(200), withPitch: .degrees(-60), toFocus: mercury, easingType: .cubicInOut, duration: 5)
            await simulation.transitionCamera(toSize: mercury.size * 1.4, easingType: .cubicIn, duration: 1)
        }
        
        if let saturn = simulation.getNode("Saturn"), let titan = simulation.getNode("Titan"), let axis = saturn.rotation?.axis {
            await simulation.setCamera(toSize: saturn.size * 2, toDirection: axis, withRotation: .degrees(170), withPitch: -.degrees(30), toFocus: saturn)
            await simulation.resetTiming()
            await simulation.adjustTiming(speed: 20000)
            await simulation.transitionCamera(toSize: saturn.size * 50, toDirection: axis, duration: 2)
            
            await simulation.transitionCamera(toSize: titan.size * 3, withRotation: .degrees(-140), withPitch: -.degrees(48), toFocus: titan, duration: 2.5)
            await simulation.transitionCamera(toSize: titan.size * 1.5, toFocus: titan, easingType: .cubicIn, duration: 1)
        }
        
        if let mars = simulation.getNode("Mars"), let phobos = simulation.getNode("Phobos"), let axis = mars.rotation?.axis {
            await simulation.resetTiming()
            await simulation.adjustTiming(speed: 800)
            await simulation.setCamera(toSize: mars.size * 25, toDirection: axis, toFocus: mars)
            await simulation.transitionCamera(toSize: mars.size * 6, toDirection: axis, withRotation: .degrees(-10), withPitch: .degrees(-10), easingType: .quadraticOut, duration: 2)
            
            await simulation.transitionCamera(toSize: phobos.size * 6, toDirection: phobos.position.unitVector, withRotation: .degrees(25), toFocus: phobos, duration: 1.5)
            await simulation.transitionCamera(toSize: phobos.size * 1.2, withRotation: .degrees(-78), easingType: .cubicIn, duration: 2)
        }
        
        if let jupiter = simulation.getNode("Jupiter"), let axis = jupiter.rotation?.axis {
            await simulation.setCamera(toSize: jupiter.globalPosition.magnitude * 2.5)
            await simulation.resetTiming()
            await simulation.adjustTiming(speed: 25000)
            await simulation.transitionCamera(toSize: jupiter.size * 40, toDirection: axis, toFocus: jupiter, easingType: .cubicOut, duration: 2)
            await simulation.transitionCamera(byScale: 15, withRotation: -.degrees(60), withPitch: .degrees(-55), duration: 2)
            
            await simulation.transitionCamera(toSize: jupiter.size * 1.2, easingType: .cubicIn, duration: 1)
        }
        
        if let earth = simulation.getNode("Earth"), let axis = earth.rotation?.axis {
            await simulation.resetTiming()
            await simulation.adjustTiming(speed: 2000)
            await simulation.setCamera(toSize: earth.size * 5, toDirection: axis, withRotation: -.degrees(180), withPitch: -.degrees(45), toFocus: earth)
            await simulation.transitionCamera(toSize: earth.size * 2.2, withRotation: -.degrees(160), easingType: .cubicOut, duration: 6.5)
        }
        
        await simulation.transitionCamera(toSize: 1e+12, duration: 2)
    }
}
