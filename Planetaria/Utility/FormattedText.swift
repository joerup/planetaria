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
    
    private var mainValue: String {
        if Double(value) != nil, let index = value.firstIndex(of: "E") {
            return String(value.prefix(upTo: index)) + "×10"
        }
        return value
    }
    private var superscriptedValue: String? {
        if Double(value) != nil, let index = value.firstIndex(of: "E") {
            return makeSuperscript(String(value.suffix(from: index).dropFirst()))
        }
        return nil
    }
    
    var body: some View {
        HStack(alignment: unit?.string == "º" ? .top : .firstTextBaseline, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                Text(mainValue)
                    .font(.system(valueFont, weight: .semibold))
                if let superscriptedValue {
                    Text(superscriptedValue)
                        .font(.system(valueFont, weight: .semibold))
                }
            }
            if let unit {
                Text(unit.string)
                    .font(.system(unitFont, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .lineLimit(0)
    }
    
    private func makeSuperscript(_ value: String) -> String {
        return String(value.map { superscript($0) })
    }
    
    private func superscript(_ value: Character) -> Character {
        switch value {
        case "1": return "¹"
        case "2": return "²"
        case "3": return "³"
        case "4": return "⁴"
        case "5": return "⁵"
        case "6": return "⁶"
        case "7": return "⁷"
        case "8": return "⁸"
        case "9": return "⁹"
        case "0": return "⁰"
        default: return "⁻"
        }
    }
}
