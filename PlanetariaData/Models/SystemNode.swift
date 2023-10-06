//
//  SystemNode.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/9/23.
//

import Foundation
import SwiftUI

public class SystemNode: Node {
    
    public override var system: SystemNode? {
        return self
    }
    
    public override var color: Color {
        get { return object?.color ?? .gray }
        set { }
    }

    public override var mass: Double {
        get { return children.map({ $0.mass }).reduce(0, +) }
        set { }
    }

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        self.children.indices.forEach { children[$0].parent = self }
    }

    public func contains(_ child: Node) -> Bool {
        return children.contains(child)
    }
    
    public func children(category: Node.Category) -> [Node] {
        if category == .system {
            return children.filter { $0.category == category }
        } else {
            return children.filter { ($0.object ?? $0).category == category }
        }
    }
    
    public func grandchildGroups(category: Node.Category) -> [Node] {
        children.reduce([]) { all, node in
            let grandchildren = node.children.filter { $0.category == category }
            switch grandchildren.count {
            case 0: return all
            case 1: return all + [grandchildren.first!]
            default: return all + [node]
            }
        }
    }
}

