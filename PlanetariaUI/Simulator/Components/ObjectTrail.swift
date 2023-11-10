//
//  ObjectTrail.swift
//
//
//  Created by Joe Rupertus on 11/9/23.
//

import SwiftUI
import PlanetariaData

struct ObjectTrail: View {
    
    var node: Node
    
    var isSelected: Bool
    var noSelection: Bool
    
    var centerOffset: Double
    var lineWidth: CGFloat
    var totalWidth: CGFloat
    var totalHeight: CGFloat
    
    var size: CGSize
    
    var body: some View {
        trailGradient(angle: -.radians(node.trueAnomaly), rank: isSelected ? .primary : node.rank, centerOffset: centerOffset, size: size, color: node.color)
            .allowsHitTesting(false)
            .opacity(isSelected ? 1 : noSelection ? 0.8 : 0.3)
            .frame(width: totalWidth, height: totalHeight)
            .mask {
                Ellipse()
                    .stroke(lineWidth: lineWidth)
                    .padding(lineWidth/2)
            }
    }
    
    private func trailGradient(angle: Angle, rank: Node.Rank, centerOffset: Double, size: CGSize, color: Color) -> some View {
        AngularGradient(
            colors: rank == .primary ? [color, .black.opacity(0.2)] : [rank == .secondary ? color.opacity(0.5) : .init(white: 0.3).opacity(0.5), .black.opacity(0.2), .black.opacity(0.2), .black.opacity(0.2), .black.opacity(0.2)],
            center: UnitPoint(x: 0.5 - centerOffset, y: 0.5),
            startAngle: angle,
            endAngle: angle + .degrees(360)
        )
    }
}
