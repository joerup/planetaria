//
//  ObjectDot.swift
//
//
//  Created by Joe Rupertus on 12/27/23.
//

import SwiftUI
import PlanetariaData

struct ObjectDot: View {
    
    var node: Node
    
    var modelSize: CGFloat
    
    var isSelected: Bool
    var noSelection: Bool
    var isSystem: Bool
    var isReference: Bool
    
    var body: some View {
        ZStack {
            let dotSize: CGFloat = isSelected ? 8 : node.rank == .primary ? 7 : 6
            
            // Tap Area
            Circle()
                .fill(.black.opacity(0.01))
                .frame(width: dotSize * 3)
            
            // Object Dot
            if !isSystem {
                Circle()
                    .fill(node.color ?? .gray)
                    .opacity(noSelection || isSelected ? 1 : 0.6)
                    .opacity(node.rank == .primary || isSelected ? 1 : node.rank == .secondary ? 0.8 : 0.5)
                    .opacity(cbrt(dotSize/modelSize-1.0))
                    .frame(width: dotSize)
                    .shadow(color: .white.opacity(isSelected ? 1 : 0), radius: 5)
            }
            
            // System Dot
            else {
                Circle()
                    .fill(Color.init(white: 0.2))
                    .opacity(isReference ? 0.5 : 0)
                    .frame(width: 5)
            }
        }
    }
}
