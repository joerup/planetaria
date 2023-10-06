//
//  Matrix.swift
//  Planetaria
//
//  Created by Joe Rupertus on 6/11/23.
//

import Foundation

public struct Matrix {
    
    let rows: Int
    let columns: Int
    var elements: [Vector]

    public init(_ elements: [Vector]) {
        guard !elements.isEmpty, let columnCount = elements.first?.count else {
            fatalError("Invalid matrix dimensions")
        }
        guard elements.allSatisfy({ $0.count == columnCount }) else {
            fatalError("Inconsistent column count in matrix")
        }
        self.rows = elements.count
        self.columns = columnCount
        self.elements = elements
    }
    
    public init(rotation angle: Double, about vector: Vector) {
        self.rows = 3
        self.columns = 3
        self.elements = [
            [cos(angle) + (1-cos(angle)) * pow(vector.x, 2),                 vector.x * -vector.y * (1-cos(angle)) - vector.z * sin(angle),  vector.x * vector.z * (1-cos(angle)) + -vector.y * sin(angle)],
            [-vector.y * vector.x * (1-cos(angle)) + vector.z * sin(angle),  cos(angle) + (1-cos(angle)) * pow(vector.y, 2),                 -vector.y * vector.z * (1-cos(angle)) - vector.x * sin(angle)],
            [vector.z * vector.x * (1-cos(angle)) - -vector.y * sin(angle),  vector.z * -vector.y * (1-cos(angle)) + vector.x * sin(angle),  cos(angle) + (1-cos(angle)) * pow(vector.z, 2)               ],
        ]
    }
    
    public init(rotation angle: Double) {
        self.init(rotation: angle, about: [0,0,1])
    }
    
    public var transformation: CGAffineTransform {
        guard columns >= 2, rows >= 3 else { return .identity }
        return CGAffineTransform(elements[0][0], elements[0][1], elements[1][0], elements[1][1], 0, 0)
    }

    public static func * (lhs: Matrix, rhs: Matrix) -> Matrix {
        guard lhs.columns == rhs.rows else { return lhs }
        var result = Matrix(Array(repeating: Array(repeating: 0.0, count: rhs.columns), count: lhs.rows))
        for i in 0..<lhs.rows {
            for j in 0..<rhs.columns {
                var sum = 0.0
                for k in 0..<lhs.columns {
                    sum += lhs.elements[i][k] * rhs.elements[k][j]
                }
                result.elements[i][j] = sum
            }
        }
        return result
    }
    
    public func applying(_ matrix: Matrix) -> Matrix {
        return self * matrix
    }
}
