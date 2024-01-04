//
//  ObjectDetails.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/10/23.
//

import SwiftUI
import PlanetariaUI
import PlanetariaData

struct ObjectDetails: View {
    
    var object: Object
    
    var body: some View {
        #if os(macOS)
        ScrollView {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text(object.name)
                        .font(.system(.largeTitle, design: .default, weight: .bold))
                        .padding(.top, 10)
                    Text(subtitle)
                        .font(.system(.headline, design: .default, weight: .semibold))
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    Object3D(object: object)
                        .frame(maxWidth: 500, maxHeight: 500)
                        .aspectRatio(1.0, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .shadow(radius: 10)
                }
                .padding(.horizontal)
                properties
            }
        }
        .navigationTitle(object.name)
        #else
        VStack {
            HStack(spacing: 5) {
                ObjectIcon(object: object, size: 75)
                    .offset(y: 2)
                VStack(alignment: .leading) {
                    Text(object.name)
                        .font(.system(.title, design: .default, weight: .semibold))
                    Text(subtitle)
                        .font(.system(.headline, design: .default, weight: .semibold))
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                }
                Spacer(minLength: 0)
            }
            .padding(.leading, 5)
            .padding(.top, 10)
            .padding(.bottom, 5)
            
            ScrollView {
                properties
            }
        }
        .tint(object.color)
        #endif
    }
    
    @ViewBuilder
    private var properties: some View {
        if let properties = object.properties {
            VStack(alignment: .leading, spacing: 10) {
                
                if object.rank == .primary || object.rank == .secondary {
                    Text(LocalizedStringKey(stringLiteral: "\(object.name) Description"))
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 10)
                }
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    PropertyText(type: .large, name: "Luminosity", property: properties.luminosity)
                    PropertyText(type: .large, name: "Orbital Period", property: properties.orbitalPeriod?.dynamic())
                    PropertyText(type: .large, name: "Rotation Period", property: properties.rotationPeriod?.dynamic())
                    PropertyText(type: .large, name: "Orbital Distance", property: properties.semimajorAxis?.dynamicDistance(for: object.category))
                    PropertyText(type: .large, name: "Mass", property: properties.mass)
                    PropertyText(type: .large, name: "Radius", property: properties.radius)
                    PropertyText(type: .large, name: "Axial Tilt", property: properties.axialTilt?[.deg])
//                    PropertyText(type: .large, name: "Temperature", property: properties.temperature)
//                    PropertyText(type: .large, name: "Pressure", property: properties.pressure)
                }
                .padding(.bottom, 10)
                .padding(.horizontal, -2)
                
                if let discoverer = properties.discoverer, let discovered = properties.discovered {
                    Text("Discovered by \(discoverer) in \(String(discovered)).")
                        .foregroundColor(.gray)
                }
                if let namesake = properties.namesake {
                    Text("Named after \(namesake).")
                        .foregroundColor(.gray)
                }
                
                Footnote()
            }
            .padding(.horizontal)
        }
    }
    
    private var subtitle: String {
        if object.category == .planet, object.parent?.parent?.name == "Solar" {
            return "The \((object.id/100).ordinalString) Planet from the Sun"
        }
        else if object.category == .planet, object.parent?.name == "Solar" {
            return "The \(object.id.ordinalString) Planet from the Sun"
        }
        else if object.category == .moon, let host = object.hostNode {
            return "Moon of \(host.name)"
        }
        else if object.rank == .primary || object.rank == .secondary, object.category == .tno || object.category == .asteroid {
            return "Dwarf Planet"
        }
        else {
            return "\(object.category.text)"
        }
    }
}

