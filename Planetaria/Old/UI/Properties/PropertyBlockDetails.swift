////
////  PropertyBlockDetails.swift
////  Planetaria
////
////  Created by Joe Rupertus on 1/25/23.
////
//
//import SwiftUI
//import Charts
//
//struct PropertyBlockDetails<ObjectType: Object, ValueType: Equatable, UnitType: Unit>: View {
//    
//    var object: ObjectType
//    var name: String
//    var category: PropertyCategory
//    var subtitleArg: ((ObjectType) -> String?)?
//    var units: [UnitType]
//    
//    var properties: [PropertyItem<ObjectType, ValueType, UnitType>]
//    
//    @State private var selectedUnit: UnitType?
//    @State private var showComparer: Bool = false
//    
//    @ScaledMetric private var chartBarHeight: Double = 40
//    
//    init(object: ObjectType, name: String, category: PropertyCategory, subtitleArg: ((ObjectType) -> String?)?, units: [UnitType]?, properties: [PropertyItem<ObjectType, ValueType, UnitType>]) {
//        self.object = object
//        self.name = name
//        self.category = category
//        self.subtitleArg = subtitleArg
//        self.units = units ?? properties.first?.value(object)?.allUnits ?? []
//        self.properties = properties
//        self._selectedUnit = State(initialValue: properties.first?.value(object)?.unit ?? self.units.first)
//    }
//    
//    var body: some View {
//        if properties.contains(where: { $0.value(object) != nil }) {
//            VStack(alignment: .leading, spacing: 20) {
//                
//                AStack {
//                    Text(name)
//                        .font(.system(.title2, design: .rounded, weight: .bold))
//                        .foregroundColor(.white)
//                        .minimumScaleFactor(0.5)
//                        .lineLimit(0)
//                    Spacer()
//                    UnitPicker(units: units, selectedUnit: $selectedUnit, color: object.associatedColor)
//                }
//                
//                DetailText(name, .description)
//                    .font(.system(.caption, design: .rounded))
//                    .foregroundColor(.init(white: 0.6))
//                    .padding(.top, -5)
//                    .padding(.horizontal, 1)
//                
//                PropertyList(object: object, properties: properties, subtitleArg: subtitleArg, selectedUnit: selectedUnit)
//                
//                if properties.map({ $0.value(object) }).compactMap({$0}).count > 1 {
//                    visualChart
//                }
//                
//                HStack {
//                    if let property = properties.first, let description = object.shortComparisonDescription(for: property.value, category: category) {
//                        Text(description)
//                            .font(.system(.footnote, design: .rounded, weight: .bold))
//                            .padding(.vertical, 5).padding(.horizontal, 10)
//                            .background(Color.white.opacity(0.1).cornerRadius(10))
//                    }
//                    Spacer()
//                    Button {
//                        self.showComparer.toggle()
//                    } label: {
//                        HStack {
//                            Text("Compare")
//                                .font(.system(.body, design: .rounded, weight: .semibold))
//                                .foregroundColor(Color.init(white: 0.7))
//                            Image(systemName: "chevron.forward")
//                                .foregroundColor(.white)
//                                .bold()
//                        }
//                    }
//                }
//                .padding(5)
//                .sheet(isPresented: self.$showComparer) {
//                    PropertyComparer(object: object, name: name, units: units, properties: properties, selectedUnit: $selectedUnit)
//                        .preferredColorScheme(.dark)
//                }
//            }
//            .padding()
//            .background(object.backgroundColor.cornerRadius(15))
//            .padding(.horizontal)
//        }
//    }
//    
//    private var visualChart: some View {
//        Chart {
//            ForEach(self.properties, id: \.id) { property in
//                if let value = property.value(object) as? Property<Double, UnitType>, let selectedUnit {
//                    BarMark(x: .value("Value", value[selectedUnit].value), y: .value("Name", property.name))
//                        .foregroundStyle(object.associatedColor.opacity(0.4))
//                        .annotation(position: .trailing) {
//                            FormattedText(value: (value[selectedUnit] as Value).string, unit: selectedUnit)
//                                .font(.caption2)
//                        }
//                }
//            }
//        }
//        .chartXAxisLabel("\(name)\(selectedUnit != nil && !(selectedUnit! is Unitless) ? " (\(selectedUnit!.name))":"")")
//        .frame(height: chartBarHeight*Double(getPropertyNumber() + 1))
//        .padding(.horizontal, 5)
//    }
//    
//    private func getPropertyNumber() -> Int {
//        var number = 0
//        for property in properties {
//            if let value = property.value(object), value.value is Double {
//                number += 1
//            }
//        }
//        return number
//    }
//}
//
//
//struct UnitPicker<UnitType: Unit>: View {
//    
//    var units: [UnitType]
//    @Binding var selectedUnit: UnitType?
//    var color: Color
//    
//    var body: some View {
//        HStack {
//            if !units.isEmpty, !(selectedUnit is Unitless) {
//                Menu {
//                    ForEach(units, id: \.name) { unit in
//                        Button {
//                            withAnimation {
//                                self.selectedUnit = unit
//                            }
//                        } label: {
//                            Text(unit.name)
//                                .font(.system(.callout, design: .rounded))
//                        }
//                    }
//                } label: {
//                    HStack {
//                        Text(selectedUnit?.name ?? "")
//                            .font(.system(.callout, design: .rounded))
//                            .foregroundColor(.init(white: 0.7))
//                            .minimumScaleFactor(0.5)
//                            .lineLimit(0)
//                        Image(systemName: "chevron.down")
//                            .foregroundColor(color.opacity(0.4))
//                            .bold()
//                    }
//                }
//            }
//        }
//        .padding(.horizontal, 5)
//    }
//}
