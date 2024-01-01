//
//  Node+Simulation.swift
//  Planetaria
//
//  Created by Joe Rupertus on 3/17/23.
//

import Foundation
import SwiftUI

extension Node {

    public func simulate(dt: Double) {
        // Adjust the timestamp
//        for child in children {
//            if let timestamp = child.timestamp {
//                child.timestamp = timestamp.advanced(by: dt)
//            }
//        }
        
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
////            guard child.orbitalPeriod > 25*timeStep else { continue }
////            child.position += child.velocity * timeStep
//        }
//    }
//
//    private func updateVelocities(timeStep: Double) {
//        for child in children {
//            // Adjust the velocity according to the net force
////            guard child.orbitalPeriod > 25*timeStep else { continue }
////            child.velocity += force(on: child) / child.mass * timeStep / 1000
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

public enum SimulationSpeed: Double, CaseIterable {
    case stationary = 0
    case realtime = 1
    case minute = 60
    case hour = 3600
    case day = 86400
    case week = 604800
    case month = 2592000
    case halfyear = 15778800
    case year = 31557600
    
    public var text: String {
        switch self {
        case .stationary:
            return "paused"
        case .realtime:
            return "1 s/s"
        case .minute:
            return "1 min/s"
        case .hour:
            return "1 hr/s"
        case .day:
            return "1 day/s"
        case .week:
            return "1 wk/s"
        case .month:
            return "1 mth/s"
        case .halfyear:
            return "6 mth/s"
        case .year:
            return "1 yr/s"
        }
    }
    
    public var prev: Self? {
        guard let index = Self.allCases.firstIndex(of: self), index-1 >= 0 else { return nil }
        return Self.allCases[index-1]
    }
    public var next: Self? {
        guard let index = Self.allCases.firstIndex(of: self), index+1 < Self.allCases.count else { return nil }
        return Self.allCases[index+1]
    }
}
