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
        private var poleRA: Double?
        private var poleDec: Double?
        
        public init?(rotationRef: Double?, rotationRate: Double?, poleRA: Double?, poleDec: Double?) {
            guard let rotationRate else { return nil }
            self.angle = 0
            
            self.rotationRef = rotationRef ?? 0
            self.rotationRate = rotationRate
            self.poleRA = poleRA
            self.poleDec = poleDec
            
            if let poleRA, let poleDec {
                self.axis = Vector(ra: poleRA, dec: poleDec)
            }
            
            self.angle = ((rotationRef ?? 0) + rotationRate * Date.now.j2000Date) * .pi/180
        }
        
        public func update(timeStep: Double) {
            self.angle += (rotationRate * timeStep/86400) * .pi/180
        }
    }
}
