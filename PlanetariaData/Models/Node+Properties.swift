//
//  Node+Properties.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/14/23.
//

import Foundation

extension Node {
    
    public class Properties {
        
        private var mainNode: Node?
        private var referenceNode: Node?
        
        public var currentDistance: Value<DistanceU>? {
            guard let node = referenceNode else { return nil }
            return Value(node.position.magnitude, .km)
        }
        public var currentSpeed: Value<SpeedU>? {
            guard let node = referenceNode else { return nil }
            return Value(node.velocity.magnitude, .km / .s)
        }
        public var trueAnomaly: Value<AngleU>? {
            guard let node = referenceNode else { return nil }
            return Value(node.trueAnomaly, .rad)
        }
        
        public var distanceFromEarth: Value<DistanceU>? {
            guard let node = referenceNode, let earth = Node.earth else { return nil }
            return Value((node.globalPosition-earth.globalPosition).magnitude)
        }
        
        public var orbitalPeriod: Value<TimeU>?
        public var semimajorAxis: Value<DistanceU>?
        public var orbitalSpeed: Value<SpeedU>?
        public var eccentricity: Value<Unitless>?
        public var inclination: Value<AngleU>?
        public var longitudeOfPeriapsis: Value<AngleU>?
        public var longitudeOfAscendingNode: Value<AngleU>?
        
        public var perihelion: Value<DistanceU>?
        public var aphelion: Value<DistanceU>?
        
        public var rotationPeriod: Value<TimeU>?
        public var rotationSpeed: Value<SpeedU>?
        public var axialTilt: Value<AngleU>?
        
        public var mass: Value<MassU>?
        public var radius: Value<DistanceU>?
        
        public init() { }
        
        public convenience init(node: Node) {
            if let reference = node.parent, reference.object == node {
                self.init(mainNode: node, referenceNode: reference)
            } else {
                self.init(mainNode: node, referenceNode: node)
            }
        }
        
        private init(mainNode: Node, referenceNode: Node) {
            
            self.mainNode = mainNode
            self.referenceNode = referenceNode
            
            self.orbitalPeriod = Value(referenceNode.orbitalPeriod, .s)
            self.semimajorAxis = Value(referenceNode.semimajorAxis, .km)
            self.orbitalSpeed = Value(referenceNode.orbitalSpeed, .km / .s)
            self.eccentricity = Value(referenceNode.eccentricity)
            self.inclination = Value(referenceNode.orbitalInclination, .rad)
            self.longitudeOfPeriapsis = Value(referenceNode.longitudeOfPeriapsis, .rad)
            self.longitudeOfAscendingNode = Value(referenceNode.longitudeOfAscendingNode, .rad)
            
            self.perihelion = Value(referenceNode.perihelion, .km)
            self.aphelion = Value(referenceNode.aphelion, .km)
            
            if let objectNode = mainNode as? ObjectNode {
                self.rotationPeriod = Value(objectNode.rotationPeriod, .d)
                self.rotationSpeed = Value(objectNode.rotationSpeed, .km / .d)
                self.axialTilt = Value(objectNode.axialTilt, .rad)
            }
            
            self.mass = Value(mainNode.mass, .kg)
            self.radius = Value(mainNode.size, .km)
        }
    }
}
