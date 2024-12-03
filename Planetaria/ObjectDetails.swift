//
//  ObjectDetails.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/10/23.
//

import SwiftUI
import PlanetariaData

struct ObjectDetails: View {
    
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    @EnvironmentObject var simulation: Simulation
    
    var object: ObjectNode
    
    private var cutoffWidth: CGFloat = 450
    
    @Binding var isActive: Bool
    
    init(object: ObjectNode, isActive: Binding<Bool>) {
        self.object = object
        self._isActive = isActive
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollSheet(title: object.name, subtitle: object.subtitle, icon: object.name, isActive: $isActive) {
                page(size: geometry.size)
            }
            .fontDesign(.rounded)
        }
    }
    
    @ViewBuilder
    private func page(size: CGSize) -> some View {
        let large = size.width > cutoffWidth
        if let properties = object.properties {
            VStack(alignment: .leading, spacing: 15) {
                Divider()
                description(properties: properties)
                majorProperties(properties: properties, large: large)
                otherProperties(properties: properties, large: large)
                Footnote()
            }
            .padding(.bottom)
            .tint(object.color)
        }
    }
    
    @ViewBuilder 
    private func description(properties: ObjectNode.Properties) -> some View {
        if object.rank == .primary || object.rank == .secondary {
            Text(NSLocalizedString(object.name, tableName: "\(simulation.fileName)-descriptions", comment: ""))
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
    }
    
    @ViewBuilder
    private func majorProperties(properties: ObjectNode.Properties, large: Bool = false) -> some View {
        let columns = (dynamicTypeSize >= .xxLarge ? 1 : 2) + (large ? 1 : 0)
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: columns), spacing: 15) {
            PropertyText(type: .large, name: "Orbital Period", property: properties.orbitalPeriod)
            PropertyText(type: .large, name: "Rotation Period", property: properties.rotationPeriod)
            PropertyText(type: .large, name: "Distance to \((object.system ?? object).hostNode?.name ?? "Host")", property: properties.semimajorAxis?.local())
            PropertyText(type: .large, name: "Average Speed", property: properties.averageSpeed?.local())
            PropertyText(type: .large, name: "Axial Tilt", property: properties.axialTilt)
            PropertyText(type: .large, name: "Temperature", property: properties.temperature)
        }
        .padding(.horizontal, -2)
        Divider()
    }
    
    @ViewBuilder
    private func otherProperties(properties: ObjectNode.Properties, large: Bool = false) -> some View {
        if large && dynamicTypeSize < .xxLarge {
            HStack(alignment: .top, spacing: 25) {
                if properties.orbitalElementsAvailable {
                    orbitalProperties(properties: properties)
                }
                if properties.structuralElementsAvailable {
                    structuralProperties(properties: properties)
                }
            }
            if properties.orbitalElementsAvailable || properties.structuralElementsAvailable {
                Divider()
            }
        } else {
            if properties.orbitalElementsAvailable {
                orbitalProperties(properties: properties)
                Divider()
            }
            if properties.structuralElementsAvailable {
                structuralProperties(properties: properties)
                Divider()
            }
        }
    }
    
    @ViewBuilder
    private func orbitalProperties(properties: ObjectNode.Properties) -> some View {
        VStack(alignment: .leading) {
            Text("Orbital Elements")
                .font(.system(.headline, weight: .bold))
                .padding(.vertical, 5)
            PropertyText(type: .row, name: "Semimajor Axis", property: properties.semimajorAxis)
            PropertyText(type: .row, name: periapsisName, property: properties.periapsis)
            PropertyText(type: .row, name: apoapsisName, property: properties.apoapsis)
            PropertyText(type: .row, name: "Eccentricity", property: properties.eccentricity)
            PropertyText(type: .row, name: "Inclination", property: properties.inclination)
        }
    }
    
    @ViewBuilder
    private func structuralProperties(properties: ObjectNode.Properties) -> some View {
        VStack(alignment: .leading) {
            Text("Structural Elements")
                .font(.system(.headline, weight: .bold))
                .padding(.vertical, 5)
            PropertyText(type: .row, name: "Mass", property: properties.mass)
            PropertyText(type: .row, name: "Radius", property: properties.radius)
            PropertyText(type: .row, name: "Density", property: properties.density)
            PropertyText(type: .row, name: "Surface Gravity", property: properties.gravity)
            PropertyText(type: .row, name: "Escape Velocity", property: properties.escapeVelocity)
        }
    }
    
    @ViewBuilder
    private func photoRow(photos: [Photo]) -> some View {
        if !photos.isEmpty {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(photos, id: \.name) { photo in
                        PhotoView(photo: photo)
                    }
                }
                .padding(.vertical, 5)
                .padding(.horizontal, -1)
            }
            .frame(height: 125)
            Divider()
        }
    }
    
    @ViewBuilder
    private func orbiterRow(properties: ObjectNode.Properties) -> some View {
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
                                simulation.selectObject(object)
                            } label: {
                                SelectionCard(name: object.name)
                            }
                        }
                    }
                }
                .tint(nil)
            }
        }
    }
    
    private var periapsisName: String {
        switch (object.system ?? object).hostNode?.name {
        case "Sun": return "Perihelion"
        case "Earth": return "Perigee"
        default: return "Periapsis"
        }
    }
    private var apoapsisName: String {
        switch (object.system ?? object).hostNode?.name {
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


