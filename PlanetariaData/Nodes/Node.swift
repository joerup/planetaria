//
//  Node.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 8/2/23.
//

import Foundation
import SwiftUI

public class Node: Decodable {
    
    public var id: Int
    public var name: String
    
    public var parent: SystemNode?
    
    public var category: Category
    public var rank: Rank
    public var color: Color?
    
    public var position: Vector
    public var velocity: Vector
    
    public var elapsedTime: Double = 0
    public var period: Double = 1.0
    public var timeStep: Double = 1.0
    private static let precision: Double = 0.001
    // frequency of timesteps relative to orbital period
    
    public var mass: Double
    public var size: Double
    
    public var totalSize: Double {
        return size
    }
    
    public var orbit: Orbit?
    public var rotation: Rotation?
    
    public var system: SystemNode? { nil }
    public var object: ObjectNode? { nil }
    
    public var parentLine: [SystemNode] {
        guard let parent else { return [] }
        return parent.parentLine + [parent]
    }
    public var siblings: [Node] {
        return parent?.children ?? []
    }
    public var hostNode: Node? {
        guard let object = parent?.object else { return nil }
        return object != self ? object : nil
    }
    
    public var globalPosition: Vector {
        return parentLine.map(\.position).reduce(.zero, +) + self.position
    }
    public var barycenterPosition: Vector {
        guard let hostNode else { return .zero }
        return (hostNode.mass * hostNode.position + self.mass * self.position) / (hostNode.mass + self.mass)
    }
    public var barycenterVelocity: Vector {
        guard let hostNode else { return .zero }
        return (hostNode.mass * hostNode.velocity + self.mass * self.velocity) / (hostNode.mass + self.mass)
    }
    
    internal func set(state: StateVector) {
        self.position = state.position
        self.velocity = state.velocity
        self.orbit = Orbit(position: state.position, velocity: state.velocity, mass: mass, size: size, hostNode: hostNode)
        if let orbit {
            self.period = orbit.period
            self.timeStep = orbit.period * Self.precision
            if hostNode?.timeStep == 1.0 && timeStep != 1.0 {
                hostNode?.timeStep = timeStep
            }
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, name, category, rank, color, mass, size, position, velocity
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        
        self.category = try container.decode(Category.self, forKey: .category)
        self.rank = try container.decode(Rank.self, forKey: .rank)
        if let hex = try? container.decode(String.self, forKey: .color) {
            self.color = Color(hex: hex)
        }
        
        self.mass = (try? container.decode(Double.self, forKey: .mass)) ?? 0
        self.size = (try? container.decode(Double.self, forKey: .size)) ?? 0
        
        self.position = (try? container.decode(Vector.self, forKey: .position)) ?? .zero
        self.velocity = (try? container.decode(Vector.self, forKey: .velocity)) ?? .zero
    }
}

extension Node: Identifiable, Equatable, Hashable {
    public static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.id == rhs.id
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

