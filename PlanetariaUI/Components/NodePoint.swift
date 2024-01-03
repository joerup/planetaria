//
//  NodePoint.swift
//
//
//  Created by Joe Rupertus on 12/27/23.
//

import SwiftUI
import PlanetariaData

struct NodePoint: View {
    
    var node: Node
    
    var modelSize: CGFloat
    
    var isSelected: Bool
    var noSelection: Bool
    var isSystem: Bool
    var isReference: Bool
    
    var body: some View {
        if !isSystem {
            #if os(visionOS)
            let dotSize: CGFloat = 15
            #else
            let dotSize: CGFloat = node.rank == .primary ? 7 : 6
            #endif
            Circle()
                .fill(node.color ?? .gray)
                .opacity(noSelection || isSelected ? 1 : 0.6)
                .opacity(node.rank == .primary || isSelected ? 1 : node.rank == .secondary ? 0.8 : 0.5)
                .frame(width: dotSize)
                .shadow(color: .white.opacity(isSelected ? 1 : 0), radius: 5)
        }
        else {
            Circle()
                .fill(Color.init(white: 0.2))
                .opacity(isReference ? 0.5 : 0)
                .frame(width: 5)
        }
    }
}
