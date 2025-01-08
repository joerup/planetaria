//
//  Node+Rotation.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 12/28/23.
//

import Foundation

extension Node {
    
    public class Rotation {
        
        public private(set) var axis: Vector3?
        public private(set) var angle: Double
        
        private var rotationRef: Double
        private var rotationRate: Double
        private var poleRA: Double?
        private var poleDec: Double?
        
        init?(rotationRef: Double?, rotationRate: Double?, poleRA: Double?, poleDec: Double?) {
            guard let rotationRate else { return nil }
            self.angle = 0
            
            self.rotationRef = rotationRef ?? 0
            self.rotationRate = rotationRate
            self.poleRA = poleRA
            self.poleDec = poleDec
            
            if let poleRA, let poleDec {
                self.axis = Vector3(ra: poleRA, dec: poleDec)
            }
            
            self.angle = .zero
        }
        
        func set(time: Date) {
            self.angle = (rotationRef + rotationRate * time.j2000Date) * .pi/180
        }
        
        func update(timeStep: Double) {
            self.angle += rotationRate * timeStep / 86400 * .pi/180
        }
    }
}
