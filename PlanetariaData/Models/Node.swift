//
//  Node.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/2/23.
//

import Foundation
import SwiftUI
import RealityKit

public protocol Node: Decodable {
    
    var id: Int { get set }
    var name: String { get set }
    
    var parent: System? { get set }
    var children: [Node] { get set }
    
    var category: Category { get set }
    var rank: Rank { get set }
    var color: Color? { get set }
    
    var position: Vector { get set }
    var velocity: Vector { get set }
    
    var mass: Double { get set }
    var size: Double { get set }
    var totalSize: Double { get }
    
    var orbit: Orbit? { get set }
    
    var properties: Properties? { get set }
    
    var system: System? { get }
    var object: Object? { get }
    
    var isSet: Bool { get set }
    
    var entity: SimulationEntity? { get set }
    
    func set(position: Vector, velocity: Vector)
}

extension Node {
    
    mutating public func appear() {
//        guard entity == nil else { return }
//        entity = SimulationEntity(node: self)
    }
    mutating public func disappear() {
//        entity = nil
    }
    
    public func matches(_ node: Node?) -> Bool {
        return self.id == node?.id
    }
    
    public var parentLine: [System] {
        guard let parent else { return [] }
        return parent.parentLine + [parent]
    }
    public var siblings: [Node] {
        return parent?.children ?? []
    }
    public var hostNode: Node? {
        return siblings.max(by: { $0.mass < $1.mass })
    }
    public var tree: [Node] {
        return [self] + subtree
    }
    private var subtree: [Node] {
        return children + children.map(\.subtree).reduce([], +)
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
    public var scaleDistance: Double? {
        guard let child = children.max(by: { $0.position.magnitude < $1.position.magnitude }) else { return nil }
        return child.position.magnitude + (child.scaleDistance ?? 0)
    }
    
    public var orbitalElementsAvailable: Bool {
        return orbit != nil
    }
    public var structuralElementsAvailable: Bool {
        return mass != 0 && size != 0
    }
}

public enum Category: String, Codable {
    case system
    case star
    case planet
    case asteroid
    case tno
    case moon
    
    public static var allCases: [Self] {
        return [.star, .planet, .asteroid, .tno, .moon]
    }
    
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

public enum Rank: String, Codable, CaseIterable {
    case primary
    case secondary
    case tertiary
    case quaternary
    
    public var amount: Int {
        switch self {
        case .primary:
            return 1
        case .secondary:
            return 2
        case .tertiary:
            return 3
        case .quaternary:
            return 4
        }
    }
}
