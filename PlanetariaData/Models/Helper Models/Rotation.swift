//
//  Rotation.swift
//
//
//  Created by Joe Rupertus on 12/28/23.
//

import Foundation

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
        
        update(timestamp: .now)
    }
    
    public func update(timestamp: Date) {
        if let poleRARef, let poleDecRef {
            let ra = poleRARef + poleRARate * timestamp.j2000Century
            let dec = poleDecRef + poleDecRate * timestamp.j2000Century
            self.axis = Vector(ra: ra, dec: dec)
        }
        self.angle = (rotationRef + rotationRate * timestamp.j2000Date) * .pi/180
    }
}
