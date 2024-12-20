//
//  SystemNode+Motion.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 3/17/23.
//

import Foundation
import SwiftUI

extension SystemNode {
    
    // Recursively advance the entire system by a time interval
    internal func integrate(by time: Double) {
        childSystems.forEach { $0.integrate(by: time) }
        
        // Split the interval into steps
        // `dt` is guaranteed to be at most `systemIntegrationStep`
        var steps: Int
        var dt: Double
        if abs(time) >= systemIntegrationStep {
            steps = Int(abs(time / systemIntegrationStep)) + 1
            dt = time / Double(steps)
        } else {
            steps = 1
            dt = time
        }
        
        // Perform each step
        for _ in 0..<steps {
            for node in children {
                node.integrationElapsedTime += dt
                
                // Update this node if its time step has elapsed
                // (it's guaranteed that elapsed time never exceeds 2 * time step)
                if abs(node.integrationElapsedTime) >= node.integrationStep {
                    stepVerlet(node: node, dt: node.integrationElapsedTime)
                    node.integrationElapsedTime = 0
                }
            }
        }
        
        // Extra step
        // (if the time step never elapsed in any step, it will be updated here)
        // (this guarantees an update for every node every frame)
        for node in children {
            stepVerlet(node: node, dt: node.integrationElapsedTime)
            node.integrationElapsedTime = 0
        }
        
        // Center position and velocity distribution at the center of mass
        // (keeps everything centered on the system and corrects for error buildup)
        let comP = self.centerOfMass
        let comV = self.centerOfMassVelocity
        for node in children {
            node.position -= comP
            node.velocity -= comV
        }
    }
    
    // Perform one step for one node using Euler's method
    private func stepEuler(node: Node, dt: Double) {
        
        // Velocity increment
        node.velocity += acceleration(for: node) * dt
        
        // Position increment
        node.position += node.velocity * dt
    }
    
    // Perform one step for one node using Verlet's leapfrog method
    private func stepVerlet(node: Node, dt: Double) {
        
        // First-half velocity increment
        node.velocity += acceleration(for: node) * dt/2
        
        // Position increment
        node.position += node.velocity * dt
        
        // Second-half velocity increment
        node.velocity += acceleration(for: node) * dt/2
    }
    
    // Perform one step for one node using Runge-Kutta method 4th order
    private func stepRK4(node: Node, dt: Double) {
        
        // First RK4 stage
        let k1Velocity: Vector3 = acceleration(for: node) * dt
        let k1Position: Vector3 = node.velocity * dt

        // Second RK4 stage
        let k2Velocity: Vector3 = acceleration(for: node, offset: k1Position/2) * dt
        let k2Position: Vector3 = (node.velocity + k1Velocity/2) * dt

        // Third RK4 stage
        let k3Velocity: Vector3 = acceleration(for: node, offset: k2Position/2) * dt
        let k3Position: Vector3 = (node.velocity + k2Velocity/2) * dt

        // Fourth RK4 stage
        let k4Velocity: Vector3 = acceleration(for: node, offset: k3Position) * dt
        let k4Position: Vector3 = (node.velocity + k3Velocity) * dt

        // Weighted average
        let avgPosition: Vector3 = k1Position + 2 * k2Position + 2 * k3Position + k4Position
        let avgVelocity: Vector3 = k1Velocity + 2 * k2Velocity + 2 * k3Velocity + k4Velocity

        // Increment using weighted averages
        node.position += avgPosition / 6
        node.velocity += avgVelocity / 6
    }

    // Calculate the net acceleration of a node
    private func acceleration(for target: Node, offset: Vector3 = .zero) -> Vector3 {
        var acc: Vector3 = .zero
        
        if let hostNode = target.hostNode {
            let displacement = hostNode.position - (target.position + offset)
            let magnitudeSquared = displacement.magnitudeSquared
            guard magnitudeSquared > .zero else { return .zero }
            acc += hostNode.mass / magnitudeSquared * displacement.unitVector
            
        } else {
            for child in children {
                guard target != child else { continue }
                let displacement = child.position - (target.position + offset)
                let magnitudeSquared = displacement.magnitudeSquared
                guard magnitudeSquared > .zero else { continue }
                acc += child.mass / magnitudeSquared * displacement.unitVector
            }
        }
        
        return G * 1E-9 * acc
    }
}
