////
////  PropertyList.swift
////  Planetaria
////
////  Created by Joe Rupertus on 1/26/23.
////
//
//import SwiftUI
//
//struct PropertyList<ObjectType: Object, ValueType: Equatable, UnitType: Unit>: View {
//
//    var object: ObjectType
//    var properties: [PropertyItem<ObjectType, ValueType, UnitType>]
//    var subtitleArg: ((ObjectType) -> String?)?
//    var selectedUnit: UnitType?
//
//    @Environment(\.sizeCategory) var sizeCategory
//
//    var body: some View {
//        VStack {
//            ForEach(properties, id: \.id) { property in
//                if let value = property.value(object) {
//                    VStack(alignment: .leading) {
//                        AStack {
//                            Text(property.name)
//                                .font(.system(.headline, design: .rounded, weight: .semibold))
//                                .foregroundColor(.white)
//                            Spacer()
//                            if let value = value as? Property<Double, UnitType>, !(value.unit is Unitless), let selectedUnit {
//                                FormattedText(value: (value[selectedUnit] as Value).string, unit: selectedUnit)
//                                    .font(.system(.headline, design: .rounded))
//                            } else {
//                                FormattedText(value: value.string, unit: value.unit)
//                                    .font(.system(.headline, design: .rounded))
//                            }
//                        }
//                        if let subtitleArg = subtitleArg?(object) {
//                            DetailText(property.name, .subtitle, arguments: [subtitleArg])
//                                .font(.system(.caption, design: .rounded))
//                                .foregroundColor(.init(white: 0.7))
//                                .padding(.bottom, 1)
//                        } else {
//                            DetailText(property.name, .subtitle)
//                                .font(.system(.caption, design: .rounded))
//                                .foregroundColor(.init(white: 0.7))
//                                .padding(.bottom, 1)
//                        }
//                    }
//                }
//            }
//        }
//        .padding()
//        .background(Color.init(white: 0.5).opacity(0.2).cornerRadius(15))
//    }
//}
