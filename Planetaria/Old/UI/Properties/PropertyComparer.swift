////
////  PropertyComparer.swift
////  Planetaria
////
////  Created by Joe Rupertus on 1/26/23.
////
//
//import SwiftUI
//import Charts
//
//struct PropertyComparer<ObjectType: Object, ValueType: Equatable, UnitType: Unit>: View {
//
//    var objects: [Object]
//    var name: String
//    var subtitleArg: ((ObjectType) -> String?)?
//    var units: [UnitType]
//    
//    var properties: [PropertyItem<ObjectType, ValueType, UnitType>]
//
//    @Binding var selectedUnit: UnitType?
//    @State private var selectedProperty: PropertyItem<ObjectType, ValueType, UnitType>
//
//    @ScaledMetric private var chartBarHeight: Double = 40
//
//    init(object: ObjectType, name: String, subtitleArg: ((ObjectType) -> String?)? = nil, units: [UnitType], properties: [PropertyItem<ObjectType, ValueType, UnitType>], selectedUnit: Binding<UnitType?>) {
//        self.objects = object.matchingObjects
//        self.name = name
//        self.subtitleArg = subtitleArg
//        self.units = units
//        self.properties = properties
//        self._selectedUnit = selectedUnit
//        self._selectedProperty = State(initialValue: properties.first!)
//    }
//
//    var body: some View {
//        DetailView {
//            ScrollView {
//                VStack(alignment: .leading, spacing: 20) {
//
//                    DetailText(name, .description)
//                        .font(.system(.callout, design: .rounded))
//                        .foregroundColor(.init(white: 0.9))
//                    VStack(alignment: .leading, spacing: 20) {
//
//                        AStack {
//                            PropertyPicker(properties: properties, selectedProperty: $selectedProperty, color: .white)
//                            Spacer()
//                            UnitPicker(units: units, selectedUnit: $selectedUnit, color: .white)
//                        }
//
//                        Chart {
//                            ForEach(self.objects, id: \.id) { object in
//                                if let object = object as? ObjectType, let value = selectedProperty.value(object) as? Property<Double, UnitType>, let selectedUnit {
//                                    BarMark(x: .value("Value", value[selectedUnit].value), y: .value("Name", object.name))
//                                        .foregroundStyle(object.associatedColor.opacity(0.4))
//                                        .annotation(position: .trailing) {
//                                            FormattedText(value: (value[selectedUnit] as Value).string, unit: selectedUnit)
//                                                .font(.caption2)
//                                        }
//                                }
//                            }
//                        }
//                        .chartXAxisLabel("\(name)\(selectedUnit != nil && !(selectedUnit! is Unitless) ? " (\(selectedUnit!.name))":"")")
//                        .frame(height: chartBarHeight*Double(getObjectNumber() + 1))
//                        .padding(.horizontal, 5)
//                    }
//                    .padding()
//                    .background(Color.init(white: 0.5).opacity(0.2).cornerRadius(15))
//
//                    Footnote()
//                }
//                .padding()
//            }
//            .navigationTitle(name)
//            .xButton()
//        }
//    }
//
//    private func getObjectNumber() -> Int {
//        var number = 0
//        for object in objects {
//            if let object = object as? ObjectType, let value = selectedProperty.value(object), value.value is Double {
//                number += 1
//            }
//        }
//        return number
//    }
//}
//
//
//struct PropertyPicker<ObjectType: Object, ValueType: Equatable, UnitType: Unit>: View {
//
//    var properties: [PropertyItem<ObjectType, ValueType, UnitType>]
//    @Binding var selectedProperty: PropertyItem<ObjectType, ValueType, UnitType>
//    var color: Color
//
//    var body: some View {
//        HStack {
//            if properties.count > 1 {
//                Menu {
//                    ForEach(properties, id: \.id) { property in
//                        Button {
//                            withAnimation {
//                                self.selectedProperty = property
//                            }
//                        } label: {
//                            Text(property.name)
//                                .font(.system(.callout, design: .rounded))
//                        }
//                    }
//                } label: {
//                    HStack {
//                        Image(systemName: "chevron.down")
//                            .foregroundColor(color.opacity(0.4))
//                            .bold()
//                        Text(selectedProperty.name)
//                            .font(.system(.callout, design: .rounded, weight: .bold))
//                            .foregroundColor(.white)
//                            .minimumScaleFactor(0.5)
//                            .lineLimit(0)
//                    }
//                }
//            } else {
//                Text(selectedProperty.name)
//                    .font(.system(.callout, design: .rounded, weight: .bold))
//                    .foregroundColor(.init(white: 0.8))
//                    .minimumScaleFactor(0.5)
//                    .lineLimit(0)
//            }
//        }
//        .padding(.horizontal, 5)
//    }
//}
