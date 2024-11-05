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
    
    weak public var parent: SystemNode?
    
    public var category: Category
    public var rank: Rank
    public var color: Color?
    
    public var position: Vector3
    public var velocity: Vector3
    
    public var mass: Double
    public var size: Double
    
    public var totalSize: Double {
        return size
    }
    
    internal var elapsedTime: Double = 0
    internal var timeStep: Double = 0
    static let timeStepFraction: Double = 0.0025
    
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
    public var hostNode: ObjectNode?
    
    public var globalPosition: Vector3 {
        return parentLine.map(\.position).reduce(.zero, +) + self.position
    }
    public var barycenterPosition: Vector3 {
        guard let hostNode else { return .zero }
        return (hostNode.mass * hostNode.position + self.mass * self.position) / (hostNode.mass + self.mass)
    }
    public var barycenterVelocity: Vector3 {
        guard let hostNode else { return .zero }
        return (hostNode.mass * hostNode.velocity + self.mass * self.velocity) / (hostNode.mass + self.mass)
    }
    
    internal func setState(_ state: StateVector) {
        self.position = state.position
        self.velocity = state.velocity
    }
    
    internal func setOrbitAndRotation(time: Date) {
        if let hostNode {
            let orbit = Orbit(position: position, velocity: velocity, mass: mass, size: size, hostNode: hostNode)
            self.orbit = orbit
            self.timeStep = orbit.period * Self.timeStepFraction
        }
        self.rotation?.set(time: time)
    }
    
    public var subtitle: String {
        if category == .planet, parent?.parent?.name == "Solar" {
            return "The \((id/100).ordinalString) Planet from the Sun"
        }
        else if category == .planet, parent?.name == "Solar" {
            return "The \(id.ordinalString) Planet from the Sun"
        }
        else if category == .moon, let host = hostNode {
            return "Moon of \(host.name)"
        }
        else if rank == .primary || rank == .secondary, category == .tno || category == .asteroid {
            return "Dwarf Planet"
        }
        else {
            return "\(category.text)"
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
        
        self.position = (try? container.decode(Vector3.self, forKey: .position)) ?? .zero
        self.velocity = (try? container.decode(Vector3.self, forKey: .velocity)) ?? .zero
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

extension Node {
    public func globalPositionAtFraction(_ fraction: Double) -> Vector3 {
        parentLine.map(\.position).reduce(.zero, +) + self.position * fraction
    }
}

