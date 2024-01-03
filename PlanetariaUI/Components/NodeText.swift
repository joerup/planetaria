//
//  NodeText.swift
//
//
//  Created by Joe Rupertus on 1/1/24.
//

import SwiftUI
import PlanetariaData

struct NodeText: View {
    
    var node: Node
    
    var isSelected: Bool
    var noSelection: Bool
    
    var body: some View {
        Text(node.object?.name ?? node.name)
            .font(.system(.caption2, design: .rounded))
            .foregroundColor(.white)
            .opacity(node.rank == .primary || isSelected ? 0.7 : node.rank == .secondary ? 0.5 : 0)
            .opacity(isSelected || noSelection ? 1.0 : 0.6)
    }
}

