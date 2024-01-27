//
//  PropertyText.swift
//  Planetaria
//
//  Created by Joe Rupertus on 1/25/23.
//

import SwiftUI
import PlanetariaData

struct PropertyText<ValueType: Equatable, UnitType: PlanetariaData.Unit>: View {
    
    typealias CurrentProperty = Property<ValueType, UnitType>
    
    var type: DisplayType
    var name: String?
    var property: CurrentProperty?

    var body: some View {
        Group {
            if let property {
                switch type {
                case .row:
                    row(for: property)
                case .large:
                    large(for: property)
                }
            }
        }
    }
    
    @ViewBuilder
    private func row(for property: CurrentProperty) -> some View {
        if let name {
            HStack {
                Text(name)
                    .font(.system(.callout, weight: .medium))
                    .foregroundStyle(.secondary)
                Spacer()
                valueText(for: property, scientific: true, valueFont: .callout, unitFont: .callout)
            }
        } else {
            valueText(for: property, scientific: true, valueFont: .body, unitFont: .body)
        }
    }
    
    @ViewBuilder
    private func large(for property: CurrentProperty) -> some View {
        HStack {
            VStack(alignment: .leading) {
                valueText(for: property, scientific: false, valueFont: .title2, unitFont: .title3)
                if let name {
                    Text(name)
                        .font(.footnote)
                        .fontWidth(.condensed)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 5)
    }

    private func valueText(for property: CurrentProperty, scientific: Bool, valueFont: Font.TextStyle, unitFont: Font.TextStyle) -> some View {
        FormattedText(value: scientific ? property.scientificString : property.string, unit: property.unit, valueFont: valueFont, unitFont: unitFont)
            .foregroundStyle(.tint)
            #if os(iOS)
            .contextMenu {
                Button {
                    let pasteboard = UIPasteboard.general
                    pasteboard.string = property.scientificString
                } label: {
                    Label("Copy", systemImage: "doc.on.clipboard")
                }
            }
            #endif
    }

    public enum DisplayType {
        case row
        case large
    }
}

