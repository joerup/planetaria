//
//  OrbitTrail.swift
//
//
//  Created by Joe Rupertus on 11/9/23.
//

import SwiftUI
import PlanetariaData

struct OrbitTrail: View {
    
    var orbit: Orbit
    
    var isSelected: Bool
    var noSelection: Bool
    
    var color: Color
    var full: Bool
    
    var lineWidth: CGFloat
    var totalWidth: CGFloat
    var totalHeight: CGFloat
    
    var angle: Angle {
        .radians(atan2(totalWidth * -sin(orbit.trueAnomaly), totalHeight * cos(orbit.trueAnomaly)))
    }
    
    var body: some View {
        AngularGradient(
            colors: full ? [color, .clear] : [color.opacity(0.5), .clear, .clear, .clear, .clear],
            center: UnitPoint(x: 0.5 - orbit.center, y: 0.5),
            startAngle: angle,
            endAngle: angle + .degrees(360)
        )
        .allowsHitTesting(false)
        .opacity(isSelected ? 1 : noSelection ? 0.8 : 0.3)
        .frame(width: totalWidth, height: totalHeight)
        .mask {
            Ellipse()
                .stroke(lineWidth: lineWidth)
                .padding(lineWidth/2)
        }
        .offset(x: totalWidth * orbit.center)
    }
}
