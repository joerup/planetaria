//
//  Node.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/2/23.
//

import Foundation
import SwiftUI

public class Node: Decodable {
    
    public var name: String
    public var id: Int
    
    public var category: Category
    public var rank: Rank
    public var color: Color
    
    public var overview: String?
    public var group: String?
    public var discovered: Int?
    public var discoverer: String?
    public var namesake: String?
    
    public weak var parent: SystemNode?
    public var children: [Node]
    
    public var isSystem: Bool {
        return category == .system
    }
    public var isObject: Bool {
        return category != .system
    }
    
    public var system: SystemNode? {
        return parent?.object == self ? parent : nil
    }
    public var object: ObjectNode? {
        return children.first(where: { $0.isObject }) as? ObjectNode
    }
    
    public var parentLine: [SystemNode] {
        guard let parent else { return [] }
        return parent.parentLine + [parent]
    }
    public var siblings: [Node] {
        return (parent?.children ?? []).filter { $0 != self }
    }
    public var hostNode: Node? {
        return siblings.max(by: { $0.mass < $1.mass })
    }
    public var orbitingNode: ObjectNode? {
        return (system ?? self).hostNode?.object
    }
    public var relatedNodes: [Node] {
        return children + parentLine + siblings + parentLine.map(\.siblings).reduce([], +)
    }
    
    public static var earth: Node?
    
    public var timestamp: Date?
    public var position: Vector
    public var velocity: Vector
    
    public var mass: Double
    public var size: Double
    
    public var totalSemimajorAxis: Double
    public var semimajorAxis: Double
    public var eccentricity: Double
    public var orbitalInclination: Double
    public var longitudeOfPeriapsis: Double
    public var longitudeOfAscendingNode: Double
    public var trueAnomaly: Double
    
    internal var orbitalPeriod: Double
    internal var orbitalSpeed: Double
    internal var perihelion: Double
    internal var aphelion: Double
    
    public var orbitalPlane: Vector
    public var eccentricityVector: Vector
    public var lineOfNodes: Vector
    
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
    public var scaleDistance: Double? {
        guard let child = children.max(by: { $0.position.magnitude < $1.position.magnitude }) else { return nil }
        return child.position.magnitude + (child.scaleDistance ?? 0)
    }
    
    public var orbitalElementsAvailable: Bool {
        return orbitingNode != nil
    }
    public var structuralElementsAvailable: Bool {
        return mass != 0 && size != 0
    }
    
    
    enum CodingKeys: String, CodingKey {
        case name
        case id
        case category
        case rank
        case color
        case group
        case discovered
        case discoverer
        case namesake
        case systems
        case objects
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        self.id = try container.decode(Int.self, forKey: .id)
        self.category = try container.decode(Category.self, forKey: .category)
        self.rank = try container.decode(Rank.self, forKey: .rank)
        
        self.color = Color(hex: (try? container.decode(String.self, forKey: .color)) ?? "#777777")
        self.group = try? container.decode(String.self, forKey: .group)
        self.discovered = try? container.decode(Int.self, forKey: .discovered)
        self.discoverer = try? container.decode(String.self, forKey: .discoverer)
        self.namesake = try? container.decode(String.self, forKey: .namesake)
        
        self.children = (try? container.decode([SystemNode].self, forKey: .systems)) ?? []
        self.children += (try? container.decode([ObjectNode].self, forKey: .objects)) ?? []
        
        self.position = .zero
        self.velocity = .zero
        self.trueAnomaly = 0
        self.totalSemimajorAxis = 0
        self.semimajorAxis = 0
        self.orbitalPeriod = 0
        self.orbitalSpeed = 0
        self.eccentricity = 0
        self.orbitalInclination = 0
        self.longitudeOfPeriapsis = 0
        self.longitudeOfAscendingNode = 0
        self.perihelion = 0
        self.aphelion = 0
        self.orbitalPlane = .zero
        self.eccentricityVector = .zero
        self.lineOfNodes = .zero
        self.mass = 0
        self.size = 0
    }
    
    public func printTree(indent: Int = 0) {
        print("\(String(repeating: " ", count: indent))\(self.id) \(self.name)")
        children.forEach { $0.printTree(indent: indent+4) }
    }
}
 
extension Node: Identifiable, Equatable {
    public static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.id == rhs.id && lhs.position == rhs.position 
    }
}

extension Node: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Node {
    public enum Category: String, Codable {
        case system
        case star
        case planet
        case moon
        case asteroid
        case tno
        
        public var text: String {
            switch self {
            case .system:
                return "System"
            case .star:
                return "Star"
            case .planet:
                return "Planet"
            case .moon:
                return "Moon"
            case .asteroid:
                return "Asteroid"
            case .tno:
                return "Trans-Neptunian Object"
            }
        }
    }
    public enum Rank: String, Codable {
        case primary
        case secondary
        case tertiary
        case quaternary
    }
}
