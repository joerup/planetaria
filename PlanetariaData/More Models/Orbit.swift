//
//  Orbit.swift
//
//
//  Created by Joe Rupertus on 12/28/23.
//

import Foundation

public class Orbit {
    
    public var semimajorAxis: Double
    public var eccentricity: Double
    public var orbitalInclination: Double
    public var longitudeOfPeriapsis: Double
    public var longitudeOfAscendingNode: Double
    public var trueAnomaly: Double
    
    public var axis: Vector
    public var eccentricityVector: Vector
    public var lineOfNodes: Vector
    
    public init?(position: Vector, velocity: Vector, mass: Double, size: Double, hostNode: Node?) {
        guard let hostNode, hostNode.mass > 0 else { return nil }
        
        let μ = G * (mass + hostNode.mass)
        let r = (position - hostNode.position) * 1000
        let v = (velocity - hostNode.velocity) * 1000
        
        self.semimajorAxis = μ / (2 * μ / r.magnitude - pow(v.magnitude, 2)) / 1000 * hostNode.mass / (hostNode.mass + mass)
        
        self.axis = r.cross(v).unitVector
        self.orbitalInclination = axis.angle(with: .referencePlane)
        
        self.eccentricityVector = (pow(v.magnitude, 2) / μ - 1 / r.magnitude) * r - (r.dot(v) / μ) * v
        self.eccentricity = eccentricityVector.magnitude
        
        self.longitudeOfAscendingNode = atan2(axis.x, -axis.y)
        self.lineOfNodes = [cos(longitudeOfAscendingNode), sin(longitudeOfAscendingNode), 0]
        
        self.longitudeOfPeriapsis = eccentricityVector.rotated(by: -orbitalInclination, about: lineOfNodes).angle
        
        self.trueAnomaly = position.signedAngle(with: eccentricityVector, around: axis, clockwise: false)
    }
    
    public func update(position: Vector) {
        self.trueAnomaly = position.signedAngle(with: eccentricityVector, around: axis, clockwise: false)
    }
}
