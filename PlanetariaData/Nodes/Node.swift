//
//  Node.swift
//  Planetaria
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
    
    public var position: Vector = .zero
    public var velocity: Vector = .zero
    
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
    
    public func set(position: Vector, velocity: Vector) {
        self.position = position
        self.velocity = velocity
        self.orbit = Orbit(position: position, velocity: velocity, mass: mass, size: size, hostNode: hostNode)
    }
    
    
    private enum CodingKeys: String, CodingKey {
        case id, name, category, rank, color, mass, size
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

