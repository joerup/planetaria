//
//  Vector.swift
//  Planetaria
//
//  Created by Joe Rupertus on 6/11/23.
//

import Foundation
import SwiftUI
import SceneKit

public typealias Vector = Array<Double>

public extension Array where Element == Double {
    
    var x: Double {
        guard count > 0 else { return 0 }
        return self[0]
    }
    var y: Double {
        guard count > 1 else { return 0 }
        return self[1]
    }
    var z: Double {
        guard count > 2 else { return 0 }
        return self[2]
    }
    
    init(x: Double, y: Double, z: Double) {
        self = [x,y,z]
    }
    init(_ x: Double, _ y: Double, _ z: Double) {
        self = [x,y,z]
    }
    init(ra: Double, dec: Double) {
        let raRad = ra * .pi/180; let decRad = dec * .pi/180
        let relativeDirection = [cos(raRad) * cos(decRad), sin(raRad) * cos(decRad), sin(decRad)]
        self = relativeDirection.rotated(by: -23.44 * .pi/180, about: [1,0,0])
    }
    
    var magnitude: Double {
        return sqrt( map({ pow($0, 2) }).reduce(0, +) )
    }
    var unitVector: [Double] {
        guard magnitude != 0 else { return self }
        return self / magnitude
    }
    var negative: [Double] {
        return self * -1
    }
    var reduceDim: [Double] {
        return [x,y,0]
    }
    var isNan: Bool {
        return self.contains(where: { $0.isNaN })
    }
    
    static func +(lhs: Self, rhs: Self) -> Array {
        guard lhs.count == rhs.count else { return [] }
        return lhs.indices.map { lhs[$0] + rhs[$0] }
    }
    static func -(lhs: Self, rhs: Self) -> Array {
        guard lhs.count == rhs.count else { return [] }
        return lhs.indices.map { lhs[$0] - rhs[$0] }
    }
    static func *(lhs: Self, rhs: Double) -> Array {
        return lhs.map { $0 * rhs }
    }
    static func *(lhs: Double, rhs: Self) -> Array {
        return rhs.map { $0 * lhs }
    }
    static func /(lhs: Self, rhs: Double) -> Array {
        return lhs.map { $0 / rhs }
    }
    
    static func += (lhs: inout Self, rhs: Self) {
        guard lhs.count == rhs.count else { return }
        lhs.indices.forEach { lhs[$0] += rhs[$0] }
    }
    static func -= (lhs: inout Self, rhs: Self) {
        guard lhs.count == rhs.count else { return }
        lhs.indices.forEach { lhs[$0] -= rhs[$0] }
    }
    
    func dot(_ vector: [Double]) -> Double {
        guard self.count == vector.count else { return 0 }
        return vector.indices.map({ vector[$0] * self[$0] }).reduce(0, +)
    }
    func cross(_ vector: [Double]) -> [Double] {
        guard self.count == 3, vector.count == 3 else { return self }
        let x = self.y * vector.z - self.z * vector.y
        let y = self.z * vector.x - self.x * vector.z
        let z = self.x * vector.y - self.y * vector.x
        return [x, y, z]
    }
    func proj(vector: [Double]) -> [Double] {
        return self.dot(vector) / pow(vector.magnitude, 2) * vector
    }
    func proj(plane: [Double]) -> [Double] {
        return self - proj(vector: plane)
    }
    
    func rotated(by angle: Double, about vector: [Double]) -> [Double] {
        let x = [cos(angle) + (1-cos(angle)) * pow(vector.x, 2),                vector.x * vector.y * (1-cos(angle)) - vector.z * sin(angle),  vector.x * vector.z * (1-cos(angle)) + vector.y * sin(angle)]
        let y = [vector.y * vector.x * (1-cos(angle)) + vector.z * sin(angle),  cos(angle) + (1-cos(angle)) * pow(vector.y, 2),                vector.y * vector.z * (1-cos(angle)) - vector.x * sin(angle)]
        let z = [vector.z * vector.x * (1-cos(angle)) - vector.y * sin(angle),  vector.z * vector.y * (1-cos(angle)) + vector.x * sin(angle),  cos(angle) + (1-cos(angle)) * pow(vector.z, 2)              ]
        return [dot(x), dot(y), dot(z)]
    }
    
    func angle(with vector: [Double]) -> Double {
        return acos(self.dot(vector) / (self.magnitude * vector.magnitude))
    }
    func signedAngle(with vector: [Double], around normal: [Double], clockwise: Bool) -> Double {
        return atan2((clockwise ? 1 : -1)*self.cross(vector).dot(normal.unitVector), self.dot(vector))
    }
    var angle: Double {
        if self.y >= 0 {
            return angle(with: [1,0,0])
        } else {
            return 2 * .pi - angle(with: [1,0,0])
        }
    }
    var angle2: Double {
        .pi + atan2(self.x, -self.y)
    }
    
    func scnVector(scaledBy scalingFactor: Double = 1) -> SCNVector3 {
        #if !os(macOS)
        SCNVector3(x: Float(x/scalingFactor), y: Float(z/scalingFactor), z: -Float(y/scalingFactor))
        #else
        SCNVector3(x: CGFloat(x/scalingFactor), y: CGFloat(z/scalingFactor), z: -CGFloat(y/scalingFactor))
        #endif
    }
    func simd3Vector(scaledBy scalingFactor: Float = 1) -> SIMD3<Float> {
        SIMD3(x: Float(x)/scalingFactor, y: Float(z)/scalingFactor, z: -Float(y)/scalingFactor)
    }
    var size: CGSize {
        CGSize(width: x, height: y)
    }
    var mapSize: CGSize {
        CGSize(width: x, height: -y)
    }
    var point: CGPoint {
        CGPoint(x: x, y: y)
    }
    var mapPoint: CGPoint {
        CGPoint(x: x, y: -y)
    }
    var unitPoint: UnitPoint {
        UnitPoint(x: x, y: y)
    }
    var floatArray: (x: CGFloat, y: CGFloat, z: CGFloat) {
        return (x: CGFloat(x), y: CGFloat(-y), z: CGFloat(z))
    }
    
    var mean: Double {
        return self.reduce(0, +) / Double(self.count)
    }
    var stdev: Double {
        return sqrt(self.map({ pow($0 - self.mean, 2) }).reduce(0, +) / Double(self.count - 1))
    }
    var midpoint: Double {
        guard let max = self.max(), let min = self.min() else { return 0 }
        return (max + min)/2
    }
    
    var text: String {
        return String(format: "%.2f", x) + ", " + String(format: "%.2f", y) + ", " + String(format: "%.2f", z)
    }
    var display: some View {
        Text(text)
            .foregroundColor(.mint)
    }
    
    static var zero = Vector(0, 0, 0)
    
    static var e1 = Vector(1, 0, 0)
    static var e2 = Vector(0, 1, 0)
    static var e3 = Vector(0, 0, 1)
    
    static var referencePlane = e3
    static var vernalEquinox = Vector(ra: 0, dec: 0)
    static var celestialPole = Vector(ra: 0, dec: 90)
}
