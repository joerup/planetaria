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
    var units: [UnitType]?
    var additionalText: String?

    @State private var selectedUnit: UnitType?

    init(type: DisplayType, name: String? = nil, property: CurrentProperty? = nil, units: [UnitType]? = nil, additionalText: String? = nil) {
        self.type = type
        self.name = name
        self.property = property
        self.additionalText = additionalText
        self.units = units?.sorted(by: { unit, _ in unit.string == property?.unit.string }) ?? []
        self._selectedUnit = State(initialValue: property?.unit)
    }

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
        .onTapGesture {
            if let selectedUnit, let units {
                if let index = units.map({$0.name}).firstIndex(of: selectedUnit.name), index+1 < units.count {
                    self.selectedUnit = units[index+1]
                } else if !units.isEmpty {
                    self.selectedUnit = units[0]
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
                HStack {
                    ZStack {
                        valueText(for: property, scientific: true, valueFont: .callout, unitFont: .callout)
                            .foregroundStyle(.white)
                        valueText(for: property, scientific: true, valueFont: .callout, unitFont: .callout)
                            .foregroundStyle(.tint.secondary)
                    }
                    if let additionalText {
                        Text(additionalText)
                    }
                }
            }
        } else {
            valueText(for: property, scientific: true, valueFont: .body, unitFont: .body)
        }
    }
    
    @ViewBuilder
    private func large(for property: CurrentProperty) -> some View {
        HStack {
            VStack(alignment: .leading) {
                ZStack {
                    valueText(for: property, scientific: false, valueFont: .title2, unitFont: .title3)
                        .foregroundStyle(.white)
                    valueText(for: property, scientific: false, valueFont: .title2, unitFont: .title3)
                        .foregroundStyle(.tint.secondary)
                }
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
        FormattedText(value: string(for: property, scientific: scientific), unit: selectedUnit, valueFont: valueFont, unitFont: unitFont)
            #if os(iOS)
            .contextMenu {
                Button {
                    let pasteboard = UIPasteboard.general
                    pasteboard.string = string(for: property, scientific: scientific)
                } label: {
                    Label("Copy", systemImage: "doc.on.clipboard")
                }
            }
            #endif
    }

    private func string(for property: CurrentProperty, scientific: Bool) -> String {
        if let property = property as? Value<UnitType> {
            return scientific ? (property[selectedUnit] as Property).scientificString : (property[selectedUnit] as Property).string
        } else {
            return scientific ? property.scientificString : property.string
        }
    }
    
    public enum DisplayType {
        case row
        case large
    }
}

