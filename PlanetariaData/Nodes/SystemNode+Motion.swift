//
//  SystemNode+Motion.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 3/17/23.
//

import Foundation
import SwiftUI

extension SystemNode {
    
    // Advance the system by a time dt
    internal func advanceSystem(by dt: Double) {
        childSystems.forEach { $0.advanceSystem(by: dt) }
        
        for node in children {
            node.elapsedTime += dt
            
            if abs(node.elapsedTime) >= node.timeStep {
                let ratio = Int(abs(node.elapsedTime) / node.timeStep)
                let interval = node.elapsedTime / Double(ratio)
                for _ in 0..<ratio {
                    stepRK4(node: node, dt: interval)
                }
                
                node.orbit?.update(position: node.position, velocity: node.velocity)
                node.rotation?.update(timeStep: interval)
                
                node.elapsedTime = 0
            }
        }
    }
    
    // Perform one step using Euler's method
    private func stepEuler(node: Node, dt: Double) {
        
        // Velocity increment
        node.velocity += acceleration(for: node) * dt
        
        // Position increment
        node.position += node.velocity * dt
    }
    
    // Perform one step using Verlet's leapfrog method
    private func stepVerlet(node: Node, dt: Double) {
        
        // First-half velocity increment
        node.velocity += acceleration(for: node) * dt/2
        
        // Position increment
        node.position += node.velocity * dt
        
        // Second-half velocity increment
        node.velocity += acceleration(for: node) * dt/2
    }
    
    // Perform one step using Runge-Kutta method 4th order
    private func stepRK4(node: Node, dt: Double) {
        
        // First RK4 stage
        let k1Velocity: Vector = acceleration(for: node) * dt
        let k1Position: Vector = node.velocity * dt

        // Second RK4 stage
        let k2Velocity: Vector = acceleration(for: node, offset: k1Position/2) * dt
        let k2Position: Vector = (node.velocity + k1Velocity/2) * dt

        // Third RK4 stage
        let k3Velocity: Vector = acceleration(for: node, offset: k2Position/2) * dt
        let k3Position: Vector = (node.velocity + k2Velocity/2) * dt

        // Fourth RK4 stage
        let k4Velocity: Vector = acceleration(for: node, offset: k3Position) * dt
        let k4Position: Vector = (node.velocity + k3Velocity) * dt

        // Weighted average
        let avgPosition: Vector = k1Position + 2 * k2Position + 2 * k3Position + k4Position
        let avgVelocity: Vector = k1Velocity + 2 * k2Velocity + 2 * k3Velocity + k4Velocity

        // Increment using weighted averages
        node.position += avgPosition / 6
        node.velocity += avgVelocity / 6
    }

    // Calculate the net acceleration of a node
    private func acceleration(for target: Node, offset: Vector = .zero) -> Vector {
        var acc: Vector = .zero
        for child in children {
            guard target != child else { continue }
            let displacement = child.position - (target.position + offset)
            guard displacement != .zero else { continue }
            acc += child.mass / pow(displacement.magnitude * 1000, 2) * displacement.unitVector
        }
        return G * acc / 1000
    }
}
