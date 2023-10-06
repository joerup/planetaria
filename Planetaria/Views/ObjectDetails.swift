//
//  ObjectDetails.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/10/23.
//

import SwiftUI
import PlanetariaData

struct ObjectDetails: View {
    
    var object: ObjectNode
    var properties: Node.Properties
    
    init(object: ObjectNode) {
        self.object = object
        self.properties = Node.Properties(node: object)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    header(showModel: false).opacity(0)
                    
                    Text(String(format: NSLocalizedString("\(object.name) Description", comment: "")))
                        .padding(.bottom, 20)
                        .padding(.top, -10)
                    
                    VStack(spacing: 20) {
                        propertyBox {
                            PropertyText(name: "Current Distance", property: properties.currentDistance?.dynamicDistance(for: object.category))
                            ScaleView(minText: "Perihelion", maxText: "Aphelion", minValue: properties.perihelion?.dynamicDistance(for: object.category), maxValue: properties.aphelion?.dynamicDistance(for: object.category), currentValue: properties.currentDistance?.dynamicDistance(for: object.category), derivativeScale: sin(properties.trueAnomaly?[.deg] ?? 0), color: object.color)
                            PropertyText(name: "Current Speed", property: properties.currentSpeed)
                        }
                        
                        propertyBox("Dynamics") {
                            PropertyText(name: "Orbital Period", property: properties.orbitalPeriod?.dynamic())
                            PropertyText(name: "Semimajor Axis", property: properties.semimajorAxis?.dynamicDistance(for: object.category))
                            PropertyText(name: "Orbital Speed", property: properties.orbitalSpeed)
                            PropertyText(name: "Eccentricity", property: properties.eccentricity)
                            PropertyText(name: "Inclination", property: properties.inclination?[.deg])
                        }
                        propertyBox {
                            PropertyText(name: "Rotation Period", property: properties.rotationPeriod?.dynamic())
                            PropertyText(name: "Rotation Speed", property: properties.rotationSpeed?[.km / .s])
                            PropertyText(name: "Axial Tilt", property: properties.axialTilt?[.deg])
                        }
                        propertyBox("Structure") {
                            PropertyText(name: "Mass", property: properties.mass)
                            PropertyText(name: "Radius", property: properties.radius)
                        }
                    }
                    .padding(.horizontal, -2)
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            
            header()
                .background(Color.init(white: 0.1).opacity(0.97))
        }
        .background(Color.init(white: 0.1))
    }
    
    private func header(showModel: Bool = true) -> some View {
        HStack {
            if showModel {
                Object3D(object)
                    .frame(width: 60, height: 60)
            } else {
                Circle()
                    .fill(.gray)
                    .frame(width: 60, height: 60)
            }
            VStack(alignment: .leading) {
                Text(object.name)
                    .font(.system(.title, design: .rounded, weight: .semibold))
                Text(subtitle)
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.gray)
            }
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
            return "Moon of \(host.name)"
        }
        return "\(object.category.text)"
    }
    
    private func propertyBox<Content: View>(_ title: String? = nil, @ViewBuilder content: @escaping () -> Content) -> some View {
        VStack(alignment: .leading) {
            if let title {
                Text(title)
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .padding(.leading)
            }
            VStack(alignment: .leading, spacing: 10, content: content)
                .padding()
                .background(object.color.opacity(0.2).cornerRadius(20))
        }
    }
}

