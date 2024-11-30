//
//  Orbit.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 12/28/23.
//

import Foundation
import simd

extension Node {
    
    public class Orbit {
        
        public private(set) var position: Vector3
        public private(set) var velocity: Vector3
        
        public private(set) var semimajorAxis: Double
        public private(set) var eccentricity: Double
        public private(set) var orbitalInclination: Double
        public private(set) var longitudeOfPeriapsis: Double
        public private(set) var longitudeOfAscendingNode: Double
        
        public private(set) var semiminorAxis: Double
        public private(set) var focusOffsetFromCenter: Vector3
        
        public private(set) var trueAnomaly: Double
        public private(set) var centralAnomaly: Double
        
        public private(set) var axis: Vector3
        public private(set) var eccentricityVector: Vector3
        public private(set) var lineOfNodes: Vector3
        
        public private(set) var period: Double
        
        init(position: Vector3, velocity: Vector3, mass: Double, hostNode: Node) {
            self.position = position
            self.velocity = velocity
            
            let μ = G * (mass + hostNode.mass)
            let r = (position - hostNode.position) * 1000
            let v = (velocity - hostNode.velocity) * 1000
            
            let totalSemimajorAxis = μ / (2 * μ / r.magnitude - pow(v.magnitude, 2)) / 1000
            self.semimajorAxis = totalSemimajorAxis * hostNode.mass / (hostNode.mass + mass)
            self.period = Double(2 * .pi / sqrt(μ) * pow(totalSemimajorAxis * 1000, 3/2))
            
            self.axis = cross(r, v).unitVector
            self.orbitalInclination = axis.angle(with: .referencePlane)
            
            self.eccentricityVector = (pow(v.magnitude, 2) / μ - 1 / r.magnitude) * r - (dot(r, v) / μ) * v
            self.eccentricity = eccentricityVector.magnitude
            
            self.semiminorAxis = semimajorAxis * sqrt(1 - pow(eccentricity, 2))
            self.focusOffsetFromCenter = semimajorAxis * eccentricityVector
            
            self.longitudeOfAscendingNode = atan2(axis.x, -axis.y)
            self.lineOfNodes = [cos(longitudeOfAscendingNode), sin(longitudeOfAscendingNode), 0]
            
            self.longitudeOfPeriapsis = eccentricityVector.rotated(by: -orbitalInclination, about: lineOfNodes).angle
            
            self.trueAnomaly = position.signedAngle(with: eccentricityVector, around: axis, clockwise: false)
            self.centralAnomaly = (position + focusOffsetFromCenter).signedAngle(with: eccentricityVector, around: axis, clockwise: false)
        }
        
        func update(position: Vector3, velocity: Vector3) {
            guard self.position != position, self.velocity != velocity else { return }
            self.position = position
            self.velocity = velocity
            self.trueAnomaly = position.signedAngle(with: eccentricityVector, around: axis, clockwise: false)
            self.centralAnomaly = (position + focusOffsetFromCenter).signedAngle(with: eccentricityVector, around: axis, clockwise: false)
        }
        
        func ellipsePosition(_ theta: Double) -> Vector3 {
            let x = semimajorAxis * cos(theta)
            let y = semiminorAxis * sin(theta)
            return [x,y,0]
        }
        
        func ellipsePosition3D(_ theta: Double) -> Vector3 {
            let distance = semimajorAxis * (1 - pow(eccentricity, 2)) / (1 + eccentricity * cos(theta))
            let direction = eccentricityVector.rotated(by: theta, about: axis).unitVector
            return distance * direction
        }
    }
}
