//
//  ScaleView.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/14/23.
//

import SwiftUI
import PlanetariaData

struct ScaleView<UnitType: PlanetariaData.Unit>: View {
    
    var minText: String
    var maxText: String
    
    var minValue: Property<Double, UnitType>?
    var maxValue: Property<Double, UnitType>?
    
    var currentValue: Property<Double, UnitType>?
    var derivativeScale: Double?
    
    var body: some View {
        if let minValue, let maxValue, let currentValue {
            VStack {
                GeometryReader { geometry in
                    VStack {
                        ZStack {
                            Rectangle()
                                .fill(.white.opacity(0.2))
                                .frame(maxWidth: .infinity, minHeight: 10)
                                .cornerRadius(5)
                            if let derivativeScale {
                                Capsule()
//                                    .fill(LinearGradient(colors: [.tint.opacity(0.9), .clear], startPoint: derivativeScale > 0 ? .trailing : .leading, endPoint: derivativeScale > 0 ? .leading : .trailing))
                                    .frame(width: abs(derivativeScale) * 40 + 15, height: 10)
                                    .position(x: -derivativeScale * 20 + geometry.size.width * (currentValue.value - minValue.value) / (maxValue.value - minValue.value), y: geometry.size.height / 2)
                            }
                            Circle()
                                .fill(.tint)
                                .shadow(radius: 5)
                                .frame(width: 15, height: 15)
                                .position(x: geometry.size.width * (currentValue.value - minValue.value) / (maxValue.value - minValue.value), y: geometry.size.height / 2)
                        }
                    }
                }
                AStack {
                    VStack(alignment: .leading) {
                        PropertyText(type: .row, property: minValue)
                        Text(minText).font(.system(.footnote, design: .rounded)).foregroundColor(.init(white: 0.8))
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        PropertyText(type: .row, property: maxValue)
                        Text(maxText).font(.system(.footnote, design: .rounded)).foregroundColor(.init(white: 0.8))
                    }
                }
            }
            .padding(.vertical)
        }
    }
}
