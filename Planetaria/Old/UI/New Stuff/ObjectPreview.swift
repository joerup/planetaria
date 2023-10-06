////
////  ObjectPreview.swift
////  Planetaria
////
////  Created by Joe Rupertus on 5/18/23.
////
//
//import SwiftUI
//
//struct ObjectPreview: View {
//    
//    @EnvironmentObject var spacetime: Spacetime
//    
//    @Environment(\.horizontalSizeClass) var horizontalSizeClass
//    @Environment(\.dynamicTypeSize) var dynamicTypeSize
//    
//    var object: Object
//    var dynamic: Bool = true
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            
//            HStack(alignment: .top) {
//                HStack {
//                    visual(size: 50)
//                        .disabled(true)
//                        .padding(.trailing, 5)
//                    VStack(alignment: .leading) {
//                        Text(object.name)
//                            .font(.system(.largeTitle, design: .default, weight: .bold))
//                        DetailText(object.name, object.subtitle)
//                            .font(.system(.headline, design: .default, weight: .semibold))
//                            .foregroundColor(.init(white: 0.8))
//                            .padding(.bottom, 3)
//                    }
//                }
//                .padding()
//                Spacer()
//                XButton {
//                    withAnimation {
//                        spacetime.selectedObject = nil
//                    }
//                }
//                .padding(5)
//            }
//            
//            ScrollView {
//                
//                VStack(alignment: .leading, spacing: 15) {
//                    
//                    DetailText(object.name, .description)
//                        .foregroundColor(.init(white: 0.9))
//                    
//                    if let discoveryText {
//                        Text(discoveryText)
//                            .foregroundColor(.init(white: 0.65))
//                    }
//                    if let namesakeText {
//                        Text(namesakeText)
//                            .foregroundColor(.init(white: 0.65))
//                    }
//                
//                    VStack {
//                        
//                        headline("Dynamics")
//                        group {
//                            property("Orbital Period") { $0.siderealPeriod?.dynamic() }
//                            property("Rotation Period") { $0.siderealRotation?.dynamic() }
//                        }
//                        let currentDistance = Property(object.distanceFromCOM ?? 0, DistanceU.km).dynamicDistance(for: object)
//                        if let orbiting = object.orbiting {
//                            let unit = currentDistance.unit
//                            group {
//                                property("Current distance from \(orbiting.name)", { _ in currentDistance })
//                                ScaleView(minText: "Perihelion", maxText: "Aphelion", minValue: object.perihelion?[unit], maxValue: object.aphelion?[unit], currentValue: currentDistance[unit], derivativeScale: sin(object.trueAnomaly), color: object.associatedColor)
//                                property("Current Speed", { Property($0.speed, DistanceU.km / TimeU.s) })
//                            }
//                        }
//                        group {
//                            property("Semimajor Axis") { $0.semimajorAxis?.dynamicDistance(for: $0) }
//                            property("Eccentricity") { $0.eccentricity }
//                            property("Inclination") { $0.inclination?[.deg] }
//                        }
//                        
//                        headline("Structure")
//                        group {
//                            property("Mass") { $0.mass?[.kg] }
//                            property("Radius") { $0.meanRadius?[.km] }
//                            property("Density") { $0.meanDensity?[.g / Cube(.cm)] }
//                            property("Axial Tilt") { $0.axialTilt?[.deg] }
//                        }
//                        
//                        headline("Environment")
//                        group {
//                            property("Temperature") { $0.temperature?[.K] }
//                            property("Pressure") { $0.pressure?[.bars] }
//                            property("Gravity") { $0.surfaceGravity?[.m / Square(.s)] }
//                            property("Escape Velocity") { $0.escapeVelocity?[.km / .s] }
//                        }
//                        
//                        headline("Satellites")
//                        group {
//                            property("Number of Moons") { Property(($0 as? Planet)?.moons.count) }
//                        }
////                            if let planet = object as? Planet, !planet.moons.isEmpty {
////                                VStack {
////                                    ForEach(planet.moons, id: \.id) { moon in
////                                        ObjectRow(object: moon)
////                                    }
////                                }
////                            }
//                    }
//                    
//                    Footnote()
//                }
//                .padding(.horizontal)
//            }
//            .overlay {
//                if !dynamic {
//                    Color.black.opacity(1E-6)
//                }
//            }
//        }
//    }
//    
//    @ViewBuilder
//    private func visual(size: CGFloat) -> some View {
//        if object.hasModel {
//            Object3DView(object)
//                .frame(width: size, height: size)
//        } else {
//            Circle()
//                .fill(.gray.opacity(0.3))
//                .frame(width: size*0.75, height: size*0.75)
//                .padding(size*0.125)
//        }
//    }
//    
//    private func headline(_ name: String) -> some View {
//        HStack {
//            Text(name)
//                .font(.system(.title3, design: .rounded, weight: .semibold))
//                .padding(.top)
//            Spacer()
//        }
//    }
//    
//    private func subheadline(_ name: String) -> some View {
//        HStack {
//            Text(name)
//                .font(.system(.headline, design: .rounded, weight: .semibold))
//                .foregroundColor(.init(white: 0.8))
//            Spacer()
//        }
//    }
//    
//    @ViewBuilder
//    private func group<Content: View>(@ViewBuilder content: () -> Content) -> some View {
//        VStack(spacing: 5, content: content)
//            .padding()
//            .background(object.associatedColor.opacity(0.1).cornerRadius(10))
//            .padding(.horizontal, -3)
//    }
//    
//    private func row<Content: View>(@ViewBuilder content: () -> Content) -> some View {
//        HStack {
//            if dynamicTypeSize >= .accessibility1 {
//                ScrollView(.horizontal) {
//                    HStack(content: content)
//                }
//                    .frame(maxWidth: .infinity)
//            } else {
//                content()
//            }
//        }
//        .padding()
//        .background(object.associatedColor.opacity(0.1).cornerRadius(10))
//        .padding(.horizontal, -3)
//    }
//    
//    @ViewBuilder
//    private func systemChangeButton(_ label: String, system: System?) -> some View {
//        if let system {
//            Button {
////                spacetime.selectedSystem = system
//            } label: {
//                Text(label)
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .padding(.horizontal).padding(.vertical, 5)
//                    .frame(maxWidth: .infinity)
////                    .background(object.associatedColor.opacity(spacetime.selectedSystem == system ? 0.3 : 0.1).cornerRadius(10))
//            }
//        }
//    }
//
//    private func property<ValueType: Equatable, UnitType: Unit>(_ name: String, _ value: @escaping (Object) -> Property<ValueType, UnitType>?) -> some View {
//        let property = PropertyItem(name: name, value: value)
//        return PropertyText(property: property.value(object), text: name, row: true)
//    }
//    
//    private func verticalProperty<ValueType: Equatable, UnitType: Unit>(_ name: String, _ value: @escaping (Object) -> Property<ValueType, UnitType>?) -> some View {
//        VStack {
//            Text(name)
//                .font(.system(.body, design: .rounded, weight: .semibold))
//                .foregroundColor(.white)
//            if let property = PropertyItem(name: name, value: value).value(object) {
//                PropertyText(property: property)
//            }
//        }
//        .frame(maxWidth: .infinity)
//    }
//    
//    private var discoveryText: String? {
//        if let discoveryYear = object.discoveryYear, let discoveredBy = object.discoveredBy {
//            return "Discovered in \(discoveryYear) by \(discoveredBy)\(discoveredBy.last == "." ? "" : ".")"
//        } else if let discoveryYear = object.discoveryYear {
//            return "Discovered in \(discoveryYear)."
//        } else if let discoveredBy = object.discoveredBy {
//            return "Discovered by \(discoveredBy)\(discoveredBy.last == "." ? "" : ".")"
//        }
//        return nil
//    }
//    
//    private var namesakeText: String? {
//        if let namesake = object.namesake {
//            return "Named after \(namesake)."
//        }
//        return nil
//    }
//}
//
//
