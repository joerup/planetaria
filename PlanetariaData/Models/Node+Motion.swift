//
//  Node+Motion.swift
//  Planetaria
//
//  Created by Joe Rupertus on 3/17/23.
//

import Foundation
import SwiftUI

extension Node {

    public func simulate(dt: Double) {
        
        // Update the velocities and positions
//        updateVelocities(timeStep: dt)
//        updatePositions(timeStep: dt)
        
        // Update the orbital elements
//        children.forEach { child in
//            child.updateOrbitalElements()
//            child.updateRotationalElements()
////            print("\(child.name) \(child.timestamp?.string ?? "N/A") \(child.position)")
//        }
    }

//    private func updatePositions(timeStep: Double) {
//        for child in children {
//            // Adjust the position according to the velocity step
//            child.position += child.velocity * timeStep
//        }
//    }
//
//    private func updateVelocities(timeStep: Double) {
//        for child in children {
//            // Adjust the velocity according to the net force
//            child.velocity += force(on: child) / child.mass * timeStep / 1000
//        }
//    }
//
//    private func force(on target: Node) -> Vector {
//        var netForce: Vector = .zero
//        
//        for child in children {
//            guard target != child else { continue }
//            
//            // Calculate the displacement
//            let displacement = child.position - target.position
//            guard displacement != .zero else { continue }
//
//            // Add the gravitational force
//            netForce += G * target.mass * child.mass / pow(displacement.magnitude * 1000, 2) * displacement.unitVector
//        }
//        
//        return netForce
//    }
}
