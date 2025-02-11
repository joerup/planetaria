//
//  Node+Orbit.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 12/28/23.
//

import Foundation
import simd

extension Node {
    
    public class Orbit {
        
        public private(set) var semimajorAxis: Double = 0
        public private(set) var eccentricity: Double = 0
        public private(set) var orbitalInclination: Double = 0
        public private(set) var longitudeOfPeriapsis: Double = 0
        public private(set) var longitudeOfAscendingNode: Double = 0
        
        public private(set) var semiminorAxis: Double = 0
        public private(set) var focusOffsetFromCenter: Vector3 = .zero
        private var sqrtEccentricityRatio: Double = 0
        
        public private(set) var trueAnomaly: Double = 0
        public private(set) var eccentricAnomaly: Double = 0
        
        public private(set) var axis: Vector3 = .zero
        public private(set) var eccentricityVector: Vector3 = .zero
        public private(set) var lineOfNodes: Vector3 = .zero
        
        public private(set) var period: Double = 0
        public private(set) var averageSpeed: Double = 0
        
        public var speedRatio: Double = 0
        private var lastUpdateTimestamp: Double = 0
        private let orbitsBeforeElementUpdate: Double = 1
         
        init?(node: Node, time: Date) {
            guard let hostNode = node.hostNode else { return nil }
            calculateKeplerianElements(node: node, hostNode: hostNode)
            calculateAnomalies(node: node)
            lastUpdateTimestamp = time.timeIntervalSince1970
        }
        
        func update(node: Node, time: Date) {
            let timestamp = time.timeIntervalSince1970
            if let hostNode = node.hostNode, abs(timestamp - lastUpdateTimestamp) > orbitsBeforeElementUpdate * period {
                calculateKeplerianElements(node: node, hostNode: hostNode)
                lastUpdateTimestamp = timestamp
            }
            calculateAnomalies(node: node)
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
        
        // Calculate the keplerian elements (and associated quantities)
        // Done regularly (but not every frame) as elements will change with time
        private func calculateKeplerianElements(node: Node, hostNode: Node) {
            var μ = G * (node.mass + hostNode.mass)
            var r = (node.position - hostNode.position) * 1000
            var v = (node.velocity - hostNode.velocity) * 1000
            
            // special case for Pluto's small moons b/c of binary system
            if hostNode.name == "Pluto" && node.mass < 1e+21, let system = hostNode.parent {
                μ = G * system.mass
                r = node.position * 1000
                v = node.velocity * 1000
            }
            
            let totalSemimajorAxis = μ / (2 * μ / r.magnitude - pow(v.magnitude, 2)) / 1000
            self.semimajorAxis = totalSemimajorAxis * hostNode.mass / (hostNode.mass + node.mass)
            self.period = Double(2 * .pi / sqrt(μ) * pow(totalSemimajorAxis * 1000, 3/2))
            self.averageSpeed = 2 * .pi / period
            
            self.axis = cross(r, v).unitVector
            self.orbitalInclination = axis.angle(with: .referencePlane)
            
            self.eccentricityVector = (pow(v.magnitude, 2) / μ - 1 / r.magnitude) * r - (dot(r, v) / μ) * v
            self.eccentricity = eccentricityVector.magnitude
            self.sqrtEccentricityRatio = sqrt((1 - eccentricity) / (1 + eccentricity))
            
            self.semiminorAxis = semimajorAxis * sqrt(1 - pow(eccentricity, 2))
            self.focusOffsetFromCenter = semimajorAxis * eccentricityVector
            
            self.longitudeOfAscendingNode = atan2(axis.x, -axis.y)
            self.lineOfNodes = [cos(longitudeOfAscendingNode), sin(longitudeOfAscendingNode), 0]
            
            self.longitudeOfPeriapsis = eccentricityVector.rotated(by: -orbitalInclination, about: lineOfNodes).angle
        }
        
        // Calculate the anomalies
        // Done every frame to update the orbit correctly
        private func calculateAnomalies(node: Node) {
            self.trueAnomaly = node.position.signedAngle(with: eccentricityVector, around: axis, clockwise: false)
            self.eccentricAnomaly = 2 * atan(sqrtEccentricityRatio * tan(trueAnomaly / 2))
        }
    }
}
