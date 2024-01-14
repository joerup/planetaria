//
//  Node+Rotation.swift
//
//
//  Created by Joe Rupertus on 12/28/23.
//

import Foundation

extension Node {
    
    public class Rotation {
        
        public var axis: Vector?
        public var angle: Double
        
        private var rotationRef: Double
        private var rotationRate: Double
        private var poleRARef: Double?
        private var poleRARate: Double
        private var poleDecRef: Double?
        private var poleDecRate: Double
        
        public init?(rotationRef: Double?, rotationRate: Double?, poleRARef: Double?, poleRARate: Double?, poleDecRef: Double?, poleDecRate: Double?) {
            guard let rotationRate else { return nil }
            self.angle = 0
            
            self.rotationRef = rotationRef ?? 0
            self.rotationRate = rotationRate
            self.poleRARef = poleRARef
            self.poleRARate = poleRARate ?? 0
            self.poleDecRef = poleDecRef
            self.poleDecRate = poleDecRate ?? 0
            
            if let poleRARef, let poleDecRef {
                let ra = poleRARef + self.poleRARate * Date.now.j2000Century
                let dec = poleDecRef + self.poleDecRate * Date.now.j2000Century
                self.axis = Vector(ra: ra, dec: dec)
            }
            
            self.angle = ((rotationRef ?? 0) + rotationRate * Date.now.j2000Date) * .pi/180
        }
        
        public func update(timeStep: Double) {
            self.angle += (rotationRate * timeStep/86400) * .pi/180
        }
    }
}
