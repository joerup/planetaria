//
//  Vector.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 6/11/23.
//

import Foundation
import SwiftUI
import SceneKit
import simd

public typealias Vector3 = SIMD3<Double>

public extension Vector3 {
    
    var magnitude: Double {
        return length(self)
    }
    var magnitudeSquared: Double {
        return length_squared(self)
    }
    var unitVector: Vector3 {
        return normalize(self)
    }
    
    var angle: Double {
        if self.y >= 0 {
            return angle(with: .e1)
        } else {
            return 2 * .pi - angle(with: .e1)
        }
    }
    func angle(with vector: Vector3) -> Double {
        return acos(dot(self, vector) / (self.magnitude * vector.magnitude))
    }
    func signedAngle(with vector: Vector3, around normal: Vector3, clockwise: Bool) -> Double {
        return atan2((clockwise ? 1 : -1) * dot(cross(self, vector), normal.unitVector), dot(self, vector))
    }
    func rotated(by angle: Double, about vector: Vector3) -> Vector3 {
        let x: Vector3 = [cos(angle) + (1-cos(angle)) * pow(vector.x, 2),
                 vector.x * vector.y * (1-cos(angle)) - vector.z * sin(angle),
                 vector.x * vector.z * (1-cos(angle)) + vector.y * sin(angle)]
        let y: Vector3 = [vector.y * vector.x * (1-cos(angle)) + vector.z * sin(angle),
                 cos(angle) + (1-cos(angle)) * pow(vector.y, 2),
                 vector.y * vector.z * (1-cos(angle)) - vector.x * sin(angle)]
        let z: Vector3 = [vector.z * vector.x * (1-cos(angle)) - vector.y * sin(angle),
                 vector.z * vector.y * (1-cos(angle)) + vector.x * sin(angle),
                 cos(angle) + (1-cos(angle)) * pow(vector.z, 2)              ]
        return [dot(self, x), dot(self, y), dot(self, z)]
    }
    
    func proj(vector: Vector3) -> Vector3 {
        return dot(self, vector) / pow(vector.magnitude, 2) * vector
    }
    func proj(plane: Vector3) -> Vector3 {
        return self - proj(vector: plane)
    }
    
    static var zero = Vector3(0, 0, 0)
    
    static var e1 = Vector3(1, 0, 0)
    static var e2 = Vector3(0, 1, 0)
    static var e3 = Vector3(0, 0, 1)
    
    static var referencePlane = e3
    static var vernalEquinox = Vector3(ra: 0, dec: 0)
    static var celestialPole = Vector3(ra: 0, dec: 90)
    
    init(ra: Double, dec: Double) {
        let raRad = ra * .pi/180; let decRad = dec * .pi/180
        let relativeDirection: Vector3 = [cos(raRad) * cos(decRad), sin(raRad) * cos(decRad), sin(decRad)]
        self = relativeDirection.rotated(by: -23.44 * .pi/180, about: .e1)
    }
    
    var ra: Double {
        let ra = proj(plane: .celestialPole).angle(with: .vernalEquinox)
        if ra.isNaN { return 0 }
        return ra
    }
    var dec: Double {
        return .pi/2 - angle(with: .celestialPole)
    }
    
    func toFloat() -> SIMD3<Float> {
        return [Float(x), Float(z), Float(-y)]
    }
    
    func isApproximately(_ other: Vector3, epsilon: Double = 1e-10) -> Bool {
        return abs(self.x - other.x) < epsilon && abs(self.y - other.y) < epsilon && abs(self.z - other.z) < epsilon
    }
}

