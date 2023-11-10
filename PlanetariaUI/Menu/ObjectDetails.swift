//
//  ObjectDetails.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/10/23.
//

import SwiftUI
import PlanetariaData

public struct ObjectDetails: View {
    
    var object: ObjectNode
    var properties: Node.Properties
    
    public init(object: ObjectNode) {
        self.object = object
        self.properties = Node.Properties(node: object)
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    
                    header(showModel: false).opacity(0)
                    
                    Text(LocalizedStringKey(stringLiteral: "\(object.name) Description"), bundle: .module)
                        .padding(.top, -20)
                    
                    PropertyBox {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            if object.orbitalElementsAvailable {
                                PropertyText(type: .large, name: "Orbital Period", property: properties.orbitalPeriod?.dynamic())
                            }
                            if object.rotationalElementsAvailable {
                                PropertyText(type: .large, name: "Rotation Period", property: properties.rotationPeriod?.dynamic())
                            }
                            if object.orbitalElementsAvailable {
                                PropertyText(type: .large, name: "Orbital Distance", property: properties.semimajorAxis?.dynamicDistance(for: object.category))
                            }
                            if object.structuralElementsAvailable {
                                PropertyText(type: .large, name: "Mass", property: properties.mass)
                                PropertyText(type: .large, name: "Radius", property: properties.radius)
                            }
                            if object.rotationalElementsAvailable {
                                PropertyText(type: .large, name: "Axial Tilt", property: properties.axialTilt?[.deg])
                            }
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, -2)
                    
                    if let discoverer = object.discoverer, let discovered = object.discovered {
                        Text("Discovered by \(discoverer) in \(String(discovered)).")
                            .foregroundColor(.gray)
                    }
                    if let namesake = object.namesake {
                        Text("Named after \(namesake).")
                            .foregroundColor(.gray)
                    }
                    
//                    Text("Position")
//                        .font(.system(.title2, weight: .bold))
//                        .fontWidth(.expanded)
//                        .padding(.vertical)
//
//                    VStack {
//                        PropertyText(type: .row, name: "Distance from Earth", property: properties.distanceFromEarth?.dynamicDistance(for: object.category))
//                        PropertyText(type: .row, name: "Current Speed", property: properties.currentSpeed)
//                    }
//
//                    Text("Orbit")
//                        .font(.system(.title2, weight: .bold))
//                        .fontWidth(.expanded)
//                        .padding(.vertical)
//
//                    VStack {
//                        PropertyText(type: .row, name: "Semimajor Axis", property: properties.semimajorAxis?.dynamicDistance(for: object.category))
//                        PropertyText(type: .row, name: "Orbital Eccentricity", property: properties.eccentricity)
//                        PropertyText(type: .row, name: "Orbital Inclination", property: properties.inclination?[.deg])
//                        PropertyText(type: .row, name: "Longitude of Periapsis", property: properties.longitudeOfPeriapsis?[.deg])
//                        PropertyText(type: .row, name: "Longitude of Ascending Node", property: properties.longitudeOfAscendingNode?[.deg])
//                        PropertyText(type: .row, name: "True Anomaly", property: properties.trueAnomaly?[.deg])
//                    }
//
//                    PropertyBox {
//                        PropertyText(type: .row, name: "Current Distance from \(object.orbitingNode?.name ?? "")", property: properties.currentDistance?.dynamicDistance(for: object.category))
//                        ScaleView(minText: "Perihelion",
//                                  maxText: "Aphelion",
//                                  minValue: properties.perihelion?.dynamicDistance(for: object.category),
//                                  maxValue: properties.aphelion?.dynamicDistance(for: object.category),
//                                  currentValue: properties.currentDistance?.dynamicDistance(for: object.category)
//                        )
//                    }
//                    .padding(.horizontal, -2)
//                    .padding(.top)
                    
                    Footnote()
                    
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            
            header()
//                .background(Color.init(white: 0.1).opacity(0.97))
        }
//        .background(Color.init(white: 0.1))
        .tint(object.color)
    }
    
    private func header(showModel: Bool = true) -> some View {
        HStack {
            #if os(iOS) || os(macOS)
            let previewSize: CGFloat = 75
            if showModel {
                Object3D(object: object)
                    .frame(width: previewSize, height: previewSize)
                    .id(object.id)
            } else {
                Circle()
                    .fill(Color.init(white: 0.4))
                    .padding(5)
                    .frame(width: previewSize, height: previewSize)
            }
            #endif
            VStack(alignment: .leading) {
                Text(object.name)
                    .font(.system(.title, design: .default, weight: .semibold))
                Text(subtitle)
                    .font(.headline)
                    .fontWidth(.condensed)
                    .foregroundStyle(.gray)
            }
            .padding(.leading, 5)
            Spacer(minLength: 0)
        }
        .padding(.top, 5)
        .padding(10)
    }
    
    private var subtitle: String {
        if object.category == .planet, object.parent?.parent?.name == "Solar" {
            return "The \((object.id/100).ordinalString) Planet from the Sun"
        }
        else if object.category == .moon, let host = object.hostNode {
            if let group = object.group {
                return "Moon of \(host.name) - \(group)"
            } else {
                return "Moon of \(host.name)"
            }
        }
        return "\(object.category.text)"
    }
}

