//
//  System.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/9/23.
//

import Foundation
import SwiftUI
import RealityKit

public class System: Node, Equatable, Identifiable, Hashable {
    
    public var id: Int
    public var name: String
    
    public var category: Category
    public var rank: Rank
    public var color: Color? {
        get { return object?.color }
        set { }
    }
    
    public weak var parent: System?
    public var children: [Node]
    
    public var position: Vector = .zero
    public var velocity: Vector = .zero
    
    public var mass: Double
    public var size: Double 
    
    public var totalSize: Double {
        return size
    }
    
    public var orbit: Orbit?
    
    public var properties: Properties?
    
    public var system: System? {
        return self
    }
    public var object: Object? {
        return children.first(where: { $0 is Object }) as? Object
    }
    
    public var isSet: Bool = false
    
    public func children(category: Category) -> [Node] {
        if category == .system {
            return children.filter { $0.category == category }
        } else {
            return children.filter { ($0.object ?? $0).category == category }
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, name, systems, objects, category, rank
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        
        self.children = (try? container.decode([System].self, forKey: .systems)) ?? []
        self.children += (try? container.decode([Object].self, forKey: .objects)) ?? []
        
        self.mass = children.map(\.mass).reduce(0, +)
        self.size = 0
        
        self.category = try container.decode(Category.self, forKey: .category)
        self.rank = try container.decode(Rank.self, forKey: .rank)
        
        children.indices.forEach { children[$0].parent = self }
    }
    
    public func set(position: Vector, velocity: Vector) {
        self.position = position
        self.velocity = velocity
        self.isSet = true
        
        self.orbit = Orbit(position: position, velocity: velocity, mass: mass, size: size, hostNode: hostNode)
    }
    
    public static func == (lhs: System, rhs: System) -> Bool {
        return lhs.id == rhs.id && lhs.position == rhs.position
    }
    public static func == (lhs: any Node, rhs: System) -> Bool {
        return lhs.id == rhs.id && lhs.position == rhs.position
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
