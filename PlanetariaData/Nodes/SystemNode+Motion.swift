//
//  SystemNode+Motion.swift
//  Planetaria
//
//  Created by Joe Rupertus on 3/17/23.
//

import Foundation
import SwiftUI

extension SystemNode {

    // Advance the system by a time dt
    public func advance(by dt: Double) {
        updateVelocities(timeStep: dt)
        updatePositions(timeStep: dt)
        childSystems.forEach { $0.advance(by: dt) }
        
        for child in children {
            child.orbit?.update(position: child.position, velocity: child.velocity)
            child.rotation?.update(timeStep: dt)
        }
    }
    
    // Adjust the position according to the velocity step
    private func updatePositions(timeStep: Double) {
        for child in children {
            child.position += child.velocity * timeStep
        }
    }
    
    // Adjust the velocity according to the net force
    private func updateVelocities(timeStep: Double) {
        for child in children {
            child.velocity += acceleration(for: child) * timeStep
        }
    }

    // Calculate the net acceleration of a child node
    private func acceleration(for target: Node) -> Vector {
        var netForce: Vector = .zero
        for child in children {
            guard target != child else { continue }
            let displacement = child.position - target.position
            guard displacement != .zero else { continue }
            netForce += G * child.mass / pow(displacement.magnitude * 1000, 2) * displacement.unitVector
        }
        return netForce / 1000
    }
}
