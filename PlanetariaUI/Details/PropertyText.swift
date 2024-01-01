//
//  PropertyText.swift
//  Planetaria
//
//  Created by Joe Rupertus on 1/25/23.
//

import SwiftUI
import PlanetariaData

public struct PropertyText<ValueType: Equatable, UnitType: PlanetariaData.Unit>: View {
    
    public typealias CurrentProperty = Property<ValueType, UnitType>
    
    var type: DisplayType
    var name: String?
    var property: CurrentProperty?
    var units: [UnitType]?
    var additionalText: String?

    @State private var selectedUnit: UnitType?

    public init(type: DisplayType, name: String? = nil, property: CurrentProperty? = nil, units: [UnitType]? = nil, additionalText: String? = nil) {
        self.type = type
        self.name = name
        self.property = property
        self.additionalText = additionalText
        self.units = units ?? property?.unit.otherUnits ?? []
        self._selectedUnit = State(initialValue: property?.unit)
    }

    public var body: some View {
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
//        .onTapGesture {
//            if let selectedUnit, let units, let index = units.map({$0.name}).firstIndex(of: selectedUnit.name) {
//                if index+1 < units.count {
//                    self.selectedUnit = units[index+1]
//                } else {
//                    self.selectedUnit = units[0]
//                }
//            }
//        }
    }
    
    @ViewBuilder
    private func row(for property: CurrentProperty) -> some View {
        if let name {
            AStack {
                Text(name)
                    .font(.system(.body, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                HStack {
                    valueText(for: property, valueFont: .body, unitFont: .body)
                    if let additionalText {
                        Text(additionalText)
                    }
                }
            }
        } else {
            valueText(for: property, valueFont: .body, unitFont: .body)
        }
    }
    
    @ViewBuilder
    private func large(for property: CurrentProperty) -> some View {
        HStack {
            VStack(alignment: .leading) {
                valueText(for: property, valueFont: .title2, unitFont: .title3)
                    .foregroundStyle(.tint)
                if let name {
                    Text(name)
                        .font(.footnote)
                        .fontWidth(.condensed)
                        .foregroundColor(.white)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 5)
    }

    private func valueText(for property: CurrentProperty, valueFont: Font.TextStyle, unitFont: Font.TextStyle) -> some View {
        FormattedText(value: string(for: property), unit: selectedUnit, valueFont: valueFont, unitFont: unitFont)
            #if os(iOS)
            .contextMenu {
                Button {
                    let pasteboard = UIPasteboard.general
                    pasteboard.string = string(for: property)
                } label: {
                    Label("Copy", systemImage: "doc.on.clipboard")
                }
            }
            #endif
    }

    private func string(for property: CurrentProperty) -> String {
        if let property = property as? Value<UnitType> {
            return (property[selectedUnit] as Property).string
        } else {
            return property.string
        }
    }
    
    public enum DisplayType {
        case row
        case large
    }
}

