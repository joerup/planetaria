//
//  SystemNode.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 8/9/23.
//

import Foundation
import SwiftUI

public class SystemNode: Node {
    
    public var childSystems: [SystemNode]
    public var childObjects: [ObjectNode]
    public var children: [Node]
    
    public var tree: [Node] {
        return [self] + subtree
    }
    private var subtree: [Node] {
        return children + childSystems.map(\.subtree).reduce([], +)
    }
    
    override public var system: SystemNode? {
        return self
    }
    override public var object: ObjectNode? {
        return childObjects.first
    }
    
    override public var color: Color? {
        get { return object?.color } set { }
    }
    
    public var scaleDistance: Double {
        guard let child = children.max(by: { $0.position.magnitude < $1.position.magnitude }) else { return 0 }
        return child.position.magnitude
    }
    public var primaryScaleDistance: Double {
        guard let child = children.filter({ $0.rank == .primary }).max(by: { $0.position.magnitude < $1.position.magnitude }) else { return 0 }
        return child.position.magnitude
    }
    
    private enum CodingKeys: String, CodingKey {
        case systems, objects
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.childSystems = (try? container.decode([SystemNode].self, forKey: .systems)) ?? []
        self.childObjects = (try? container.decode([ObjectNode].self, forKey: .objects)) ?? []
        self.children = childSystems + childObjects
        
        try super.init(from: decoder)
        
        self.mass = children.map(\.mass).reduce(0, +)
        self.size = 0
        
        for child in children {
            child.parent = self
        }
    }
    
    override internal func set(state: StateVector) {
        super.set(state: state)
        object?.properties?.orbit = orbit
    }
    
    public var totalEnergy: Double {
        return childSystems.map(\.totalEnergy).reduce(0, +) + childObjects.map(objectEnergy(_:)).reduce(0, +)
    }
    private func objectEnergy(_ object: ObjectNode) -> Double {
        1/2 * object.mass * pow(object.velocity.magnitude, 2) - G * (object.hostNode?.mass ?? 1) * object.mass / object.position.magnitude
    }
}
