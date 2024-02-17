//
//  FormattedText.swift
//  Planetaria
//
//  Created by Joe Rupertus on 1/19/23.
//

import SwiftUI
import PlanetariaData

struct FormattedText: View {
    
    var value: String
    var unit: PlanetariaData.Unit?
    
    var valueFont: Font.TextStyle = .body
    var unitFont: Font.TextStyle = .body
    
    var body: some View {
        HStack(alignment: unit?.string == "º" ? .top : .firstTextBaseline, spacing: 0) {
            Text(value)
                .font(.system(valueFont, weight: .semibold))
                .brightness(0.25)
                .saturation(0.5)
            if let unit {
                Text(unit.string)
                    .font(.system(unitFont, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .brightness(0.5)
                    .saturation(0.5)
            }
        }
        .lineLimit(0)
    }
}
