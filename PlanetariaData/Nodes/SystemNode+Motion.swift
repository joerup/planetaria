//
//  SystemNode+Motion.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 3/17/23.
//

import Foundation
import SwiftUI

extension SystemNode {
    
    // Advance the entire system by a time interval
    internal func advanceSystem(by time: Double) {
        childSystems.forEach { $0.advanceSystem(by: time) }
        
        // Split the interval into steps
        // `dt` is guaranteed to be at most `systemTimeStep`
        var steps: Int
        var dt: Double
        if abs(time) >= systemTimeStep {
            steps = Int(abs(time / systemTimeStep)) + 1
            dt = time / Double(steps)
        } else {
            steps = 1
            dt = time
        }
        
        // Perform each step
        for _ in 0..<steps {
            for node in children {
                guard node != object else { continue }
                node.elapsedTime += dt
                
                // Update this node if its time step has elapsed
                // (it's guaranteed that elapsed time never exceeds 2 * time step)
                if abs(node.elapsedTime) >= node.timeStep {
                    stepVerlet(node: node, dt: node.elapsedTime)
                    node.elapsedTime = 0
                }
            }
        }
        
        // Extra step
        // (if the time step never elapsed in any step, it will be updated here)
        // (this guarantees an update for every node every frame)
        for node in children {
            guard node != object else { continue }
            stepVerlet(node: node, dt: node.elapsedTime)
            node.elapsedTime = 0
        }
        
        // Update the stored orbit and rotation states
        for node in children {
            node.orbit?.update(position: node.position, velocity: node.velocity)
            node.rotation?.update(timeStep: time)
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
        
        for child in children {
            guard target != child else { continue }
            let displacement = child.position - (target.position + offset)
            let magnitudeSquared = displacement.magnitudeSquared
            guard magnitudeSquared > .zero else { continue }
            acc += child.mass / magnitudeSquared * displacement.unitVector
        }
        return G * 1E-9 * acc
    }
}
