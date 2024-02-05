//
//  SystemNode.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/9/23.
//

import Foundation
import SwiftUI

public class SystemNode: Node {
    
    public private(set) var childSystems: [SystemNode]
    public private(set) var childObjects: [ObjectNode]
    
    public private(set) var children: [Node]
    
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
    
    public var scaleDistance: Double? {
        guard let child = children.filter({ $0.rank == .primary }).max(by: { $0.position.magnitude < $1.position.magnitude }) else { return nil }
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
    
    override public func set(state: StateVector) {
        super.set(state: state)
        object?.properties?.orbit = orbit
    }
}
