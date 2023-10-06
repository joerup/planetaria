////
////  PropertyBlock.swift
////  Planetaria
////
////  Created by Joe Rupertus on 1/26/23.
////
//
//import SwiftUI
//
//struct PropertyBlock: View {
//    
//    var object: Object
//    var category: PropertyCategory
//    var type: BlockType
//    
//    init(object: Object, category: PropertyCategory, type: BlockType) {
//        self.object = object
//        self.category = category
//        self.type = type
//    }
//    
//    var body: some View {
//        switch category {
//        case .stellar:
//            stellar
//        case .orbit:
//            orbit
//        case .rotation:
//            rotation
//        case .structure:
//            structure
//        case .environment:
//            environment
//        }
//    }
//    
//    @ViewBuilder
//    private var stellar: some View {
//        block(name: "Spectral Type", mainProperty: PropertyItem(name: "Spectral Type") { TextValue(($0 as? Star)?.spectralType) })
//        block(name: "Luminosity", mainProperty: PropertyItem(name: "Luminosity") { ($0 as? Star)?.luminosity })
//    }
//    
//    @ViewBuilder
//    private var orbit: some View {
//        let distanceUnit: DistanceU = object is Moon ? .km : .AU
//        
//        block(name: "Orbital Period", subtitleArg: { $0.orbiting?.name },
//              mainProperty:
//                PropertyItem(name: "Sidereal Period") { $0.siderealPeriod?.dynamic() },
//              otherProperties: [
//                PropertyItem(name: "Synodic Period") { $0.synodicPeriod?.dynamic() },
//                PropertyItem(name: "Tropical Period") { $0.tropicalPeriod?.dynamic() }
//              ]
//        )
//        block(name: "Orbital Radius", subtitleArg: { $0.orbiting?.name }, units: [.AU, .km, .mi],
//              mainProperty:
//                PropertyItem(name: "Semi-Major Axis") { $0.semimajorAxis?[distanceUnit] },
//              otherProperties: [
//                PropertyItem(name: apsisString(.periapsis, for: object.orbiting)) { $0.perihelion?[distanceUnit] },
//                PropertyItem(name: apsisString(.apoapsis, for: object.orbiting)) { $0.aphelion?[distanceUnit] }
//              ]
//        )
//        block(name: "Orbital Velocity",
//              mainProperty:
//                PropertyItem(name: "Average Velocity") { $0.averageVelocity },
//              otherProperties: [
//                PropertyItem(name: "Maximum Velocity") { $0.maxVelocity },
//                PropertyItem(name: "Minimum Velocity") { $0.minVelocity }
//              ]
//        )
//        block(name: "Orbital Eccentricity", text: "Eccentricity", mainProperty: PropertyItem(name: "Eccentricity") { $0.eccentricity })
//        block(name: "Orbital Inclination", text: "Inclination",
//              subtitleArg: { $0.inclinationReference },
//              mainProperty: PropertyItem(name: "Inclination") { $0.inclination }
//        )
//        block(name: "Orbit Direction", text: "Direction", subtitleArg: { $0.orbiting?.sentenceName }, mainProperty: PropertyItem(name: "Orbit Direction") { $0.orbitDirection })
//    }
//    
//    @ViewBuilder
//    private var rotation: some View {
//        block(name: "Rotational Period",
//              mainProperty:
//                PropertyItem(name: "Sidereal Rotation") { $0.siderealRotation?.dynamic() },
//              otherProperties: [
//                PropertyItem(name: "Synodic Rotation") { $0.synodicRotation?.dynamic() }
//              ]
//        )
//        block(name: "Rotational Velocity", mainProperty: PropertyItem(name: "Rotational Velocity") { $0.rotationalVelocity?[.km / .hr] })
//        block(name: "Axial Tilt", mainProperty: PropertyItem(name: "Axial Tilt") { $0.axialTilt })
//        block(name: "Rotation Direction", text: "Direction", mainProperty: PropertyItem(name: "Rotation Direction") { $0.rotationDirection })
//    }
//    
//    @ViewBuilder
//    private var structure: some View {
//        block(name: "Radius",
//              units: [.km, .m, .mi, .ft, .rE, .rJ, .rS],
//              mainProperty:
//                PropertyItem(name: "Mean Radius") { $0.meanRadius },
//              otherProperties: [
//                PropertyItem(name: "Equatorial Radius") { $0.equatorialRadius },
//                PropertyItem(name: "Polar Radius") { $0.polarRadius }
//              ]
//        )
//        block(name: "Mass", mainProperty: PropertyItem(name: "Mass") { $0.mass })
//        block(name: "Density", units: [.g / Cube(.cm), .kg / Cube(.m)], mainProperty: PropertyItem(name: "Mean Density") { $0.meanDensity?[.g / Cube(.cm)] })
//        block(name: "Flattening", mainProperty: PropertyItem(name: "Flattening") { $0.flattening })
//        block(name: "Volume", units: [Cube(.km),Cube(.m),Cube(.mi)], mainProperty: PropertyItem(name: "Volume") { $0.volume?[Cube(.km)] })
//        block(name: "Surface Area", units: [Square(.km),Square(.m),Square(.mi)], mainProperty: PropertyItem(name: "Surface Area") { $0.surfaceArea?[Square(.km)] })
//    }
//    
//    
//    @ViewBuilder
//    private var environment: some View {
//        block(name: "Temperature", mainProperty: PropertyItem(name: "Temperature") { $0.temperature })
//        block(name: "Pressure", mainProperty: PropertyItem(name: "Pressure") { $0.pressure })
//        block(name: "Surface Gravity", text: "Gravity", units: [.m / Square(.s), .ft / Square(.s)], mainProperty: PropertyItem(name: "Surface Gravity") { $0.surfaceGravity })
//        block(name: "Escape Velocity", mainProperty: PropertyItem(name: "Escape Velocity") { $0.escapeVelocity?[.km / .s] })
//        block(name: "Magnetic Field", mainProperty: PropertyItem(name: "Magnetic Field") { $0.hasMagneticField != nil ? BoolValue($0.hasMagneticField) : nil })
//    }
//}
//
//
//
//extension PropertyBlock {
//    
//    @ViewBuilder
//    private func block<ValueType: Equatable, UnitType: Unit>(name: String, text: String? = nil, subtitleArg: ((Object) -> String?)? = nil, units: [UnitType]? = nil, mainProperty: PropertyItem<Object, ValueType, UnitType>, otherProperties: [PropertyItem<Object, ValueType, UnitType>] = []) -> some View {
//        switch type {
//        case .preview:
//            PropertyBlockPreview(object: object, name: name, text: text, subtitleArg: subtitleArg, units: units, mainProperty: mainProperty, otherProperties: otherProperties)
//        case .detail:
//            PropertyBlockDetails(object: object, name: name, category: category, subtitleArg: subtitleArg, units: units, properties: [mainProperty] + otherProperties)
//        case .comparison:
//            EmptyView()
//        }
//    }
//    
//    private func apsisString(_ type: ApsisType, for body: Object?) -> String {
//        guard let body else { return "" }
//        if body.name == "Sun" {
//            switch type {
//            case .periapsis: return "Perihelion"
//            case .apoapsis: return "Aphelion"
//            }
//        } else if body.name == "Earth" {
//            switch type {
//            case .periapsis: return "Perigee"
//            case .apoapsis: return "Apogee"
//            }
//        } else if body is Star {
//            switch type {
//            case .periapsis: return "Periastron"
//            case .apoapsis: return "Apastron"
//            }
//        } else {
//            switch type {
//            case .periapsis: return "Periapsis"
//            case .apoapsis: return "Apoapsis"
//            }
//        }
//    }
//    
//    private enum ApsisType {
//        case periapsis
//        case apoapsis
//    }
//    
//    enum BlockType {
//        case preview
//        case detail
//        case comparison
//    }
//}
