//
//  ObjectDetails.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/10/23.
//

import SwiftUI
import PlanetariaData

struct ObjectDetails: View {
    
    @EnvironmentObject var simulation: Simulation
    
    var object: ObjectNode
    
    var body: some View {
        NavigationSheet {
            header
        } content: {
            properties
        }
        .tint(object.color)
    }
    
    private var header: some View {
        VStack(alignment: .leading) {
            Text(object.name)
                .font(.system(.title, design: .default, weight: .semibold))
            Text(subtitle)
                .font(.system(.headline, design: .default, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding()
    }
    
    @ViewBuilder
    private var properties: some View {
        if let properties = object.properties {
            VStack(alignment: .leading, spacing: 15) {
                
                if !properties.photos.isEmpty {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(properties.photos, id: \.name) { photo in
                                PhotoView(photo: photo)
                            }
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, -1)
                    }
                    .frame(height: 125)
                }
                
                if object.rank == .primary || object.rank == .secondary {
                    Text(NSLocalizedString(object.name, tableName: "Descriptions", comment: ""))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                if let discoverer = properties.discoverer, let discovered = properties.discovered {
                    Text("Discovered by \(discoverer) in \(String(discovered)).")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if let namesake = properties.namesake {
                    Text("Named after \(namesake).")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Divider()
                
//                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
//                    PropertyText(type: .large, name: "Luminosity", property: properties.luminosity)
//                    PropertyText(type: .large, name: "Orbital Period", property: properties.orbitalPeriod?.dynamic())
//                    PropertyText(type: .large, name: "Rotation Period", property: properties.rotationPeriod?.dynamic())
//                    PropertyText(type: .large, name: "Distance to \((object.system ?? object).hostNode?.name ?? "Host")", property: properties.currentDistance?.local(), units: [.km, .mi])
//                    PropertyText(type: .large, name: "Current Speed", property: properties.currentSpeed?.local(), units: [.km / .hr, .mi / .hr])
//                    PropertyText(type: .large, name: "Axial Tilt", property: properties.axialTilt)
//                    PropertyText(type: .large, name: "Temperature", property: properties.temperature?.local(), units: [.F, .C, .K])
//                }
//                .padding(.horizontal, -2)
//                
//                Divider()
//                
//                if properties.orbitalElementsAvailable {
//                    VStack(alignment: .leading) {
//                        Text("Orbital Elements")
//                            .font(.system(.headline, weight: .bold))
//                            .padding(.vertical, 5)
//                        PropertyText(type: .row, name: "Semimajor Axis", property: properties.semimajorAxis?.dynamicDistance(for: object.category), units: [.AU, .km, .mi])
//                        PropertyText(type: .row, name: periapsisName, property: properties.periapsis?.dynamicDistance(for: object.category), units: [.AU, .km, .mi])
//                        PropertyText(type: .row, name: apoapsisName, property: properties.apoapsis?.dynamicDistance(for: object.category), units: [.AU, .km, .mi])
//                        PropertyText(type: .row, name: "Eccentricity", property: properties.eccentricity)
//                        PropertyText(type: .row, name: "Inclination", property: properties.inclination)
//                    }
//                    Divider()
//                }
//                
//                if properties.structuralElementsAvailable {
//                    VStack(alignment: .leading) {
//                        Text("Structural Elements")
//                            .font(.system(.headline, weight: .bold))
//                            .padding(.vertical, 5)
//                        PropertyText(type: .row, name: "Mass", property: properties.mass, units: [.kg])
//                        PropertyText(type: .row, name: "Radius", property: properties.radius, units: [.km, .mi])
//                        PropertyText(type: .row, name: "Density", property: properties.density, units: [.g / Cube(.cm), .kg / Cube(.m)])
//                        PropertyText(type: .row, name: "Surface Gravity", property: properties.gravity, units: [.m / Square(.s)])
//                        PropertyText(type: .row, name: "Escape Velocity", property: properties.escapeVelocity, units: [.km / .s])
//                    }
//                    Divider()
//                }
                
                if !orbiters.isEmpty {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(object.category.orbiterCategory.text)s")
                                .font(.system(.headline, weight: .bold))
                            Spacer()
                            Text("\(properties.moons?.value ?? orbiters.count)")
                                .foregroundStyle(.secondary)
                                .font(.system(.headline, weight: .bold))
                        }
                        .padding(.vertical, 5)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(orbiters) { object in
                                    Button {
                                        simulation.select(object)
                                    } label: {
                                        ObjectCard(object: object)
                                    }
                                }
                            }
                        }
                    }
                    Divider()
                }
                
                Footnote()
            }
            .safeAreaPadding(.horizontal)
            .padding(.bottom)
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
    
    private var periapsisName: String {
        switch object.hostNode?.name {
        case "Sun": return "Perihelion"
        case "Earth": return "Perigee"
        default: return "Periapsis"
        }
    }
    private var apoapsisName: String {
        switch object.hostNode?.name {
        case "Sun": return "Aphelion"
        case "Earth": return "Apogee"
        default: return "Apoapsis"
        }
    }
    
    private var orbiters: [ObjectNode] {
        let orbiterCategory = object.category.orbiterCategory
        guard let system = object.system else { return [] }
        return system.children.compactMap(\.object).filter({ $0.category == orbiterCategory }).sorted(by: { $0.id < $1.id })
    }
}


