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
    var orbit: Orbit
    
    var isSelected: Bool
    var noSelection: Bool
    
    var centerOffset: Double
    var lineWidth: CGFloat
    var totalWidth: CGFloat
    var totalHeight: CGFloat
    
    var body: some View {
        let angle = Angle.radians(atan2(totalWidth * -sin(orbit.trueAnomaly), totalHeight * cos(orbit.trueAnomaly)))
        trailGradient(angle: angle, rank: isSelected ? .primary : node.rank, centerOffset: centerOffset, color: node.color ?? .gray)
            .allowsHitTesting(false)
            .opacity(isSelected ? 1 : noSelection ? 0.8 : 0.3)
            .frame(width: totalWidth, height: totalHeight)
            .mask {
                Ellipse()
                    .stroke(lineWidth: lineWidth)
                    .padding(lineWidth/2)
            }
    }
    
    private func trailGradient(angle: Angle, rank: Rank, centerOffset: Double, color: Color) -> some View {
        AngularGradient(
            colors: rank == .primary ? [color, .clear] : [rank == .secondary ? color.opacity(0.5) : color.opacity(0.25), .clear, .clear, .clear, .clear],
            center: UnitPoint(x: 0.5 - centerOffset, y: 0.5),
            startAngle: angle,
            endAngle: angle + .degrees(360)
        )
    }
}
