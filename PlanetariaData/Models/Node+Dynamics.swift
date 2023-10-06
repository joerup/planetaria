//
//  Node+Dynamics.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/6/23.
//

import Foundation

extension Node {
    
    public func setOrbitalElements() {
        guard let hostNode else { return }
        
        let μ = G * (mass + hostNode.mass)
        let r = (position - hostNode.position) * 1000
        let v = (velocity - hostNode.velocity) * 1000
        
        self.totalSemimajorAxis = μ / (2 * μ / r.magnitude - pow(v.magnitude, 2)) / 1000
        self.semimajorAxis = totalSemimajorAxis * hostNode.mass / (hostNode.mass + mass)
        self.orbitalPeriod = 2 * .pi / sqrt(μ) * pow(totalSemimajorAxis * 1000, 3/2)
        self.orbitalSpeed = 2 * .pi * totalSemimajorAxis / orbitalPeriod
        
        self.orbitalPlane = r.cross(v).unitVector
        self.orbitalInclination = orbitalPlane.angle(with: .referencePlane)
        
        self.eccentricityVector = (pow(v.magnitude, 2) / μ - 1 / r.magnitude) * r - (r.dot(v) / μ) * v
        self.eccentricity = eccentricityVector.magnitude
        
        self.perihelion = semimajorAxis * (1 - eccentricity)
        self.aphelion = semimajorAxis * (1 + eccentricity)
        
        self.longitudeOfAscendingNode = atan2(orbitalPlane.x, -orbitalPlane.y)
        self.lineOfNodes = [cos(longitudeOfAscendingNode), sin(longitudeOfAscendingNode), 0]
        
        self.longitudeOfPeriapsis = eccentricityVector.rotated(by: -orbitalInclination, about: lineOfNodes).angle
        
        updateOrbitalElements()
    }
    
    public func updateOrbitalElements() {
        
        self.trueAnomaly = (position - barycenterPosition).signedAngle(with: eccentricityVector, around: orbitalPlane, clockwise: false)
    }
    
    public func setRotationalElements() {
        guard let object, object.rotationPeriod == nil, let rotationRate = object.rotationRate else { return }
        
        updateRotationalElements()
        
        object.rotationPeriod = 360 / abs(rotationRate)
        object.rotationSpeed = abs(rotationRate) * .pi / 180 * object.size
        object.axialTilt = object.poleDirection.angle(with: orbitalPlane)
    }
    
    public func updateRotationalElements() {
        guard let timestamp, let object,
            let rotationRef = object.rotationRef,
            let rotationRate = object.rotationRate,
            let poleRARef = object.poleRARef,
            let poleDecRef = object.poleDecRef
        else { return }
        let poleRARate = object.poleRARate ?? 0
        let poleDecRate = object.poleDecRate ?? 0
        
        object.rotation = (rotationRef + rotationRate * timestamp.j2000Date) * .pi/180
        object.poleRA = poleRARef + poleRARate * timestamp.j2000Century
        object.poleDec = poleDecRef + poleDecRate * timestamp.j2000Century
        object.poleDirection = Vector(ra: object.poleRA, dec: object.poleDec)
    }
}
