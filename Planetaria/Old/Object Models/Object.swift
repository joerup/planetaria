////
////  Object.swift
////  Planetaria
////
////  Created by Joe Rupertus on 1/9/23.
////
//
//import Foundation
//import SwiftUI
//
//class Object: Codable, Identifiable, Equatable, Hashable {
//    
//    // MARK: - Properties
//    
//    var id: UUID
//    var name: String
//    var type: ObjectType
//    
//    var discoveredBy: String?
//    var discoveryYear: Int?
//    var discoveryMethod: String?
//    
//    var namesake: String?
//    
//    
//    // MARK: - Orbit
//    
//    var semimajorAxis: Value<DistanceU>?
//    var siderealPeriod: Value<TimeU>?
//    var synodicPeriod: Value<TimeU>?
//    var tropicalPeriod: Value<TimeU>?
//    var eccentricity: Value<Unitless>?
//    var inclination: Value<AngleU>?
//    var argumentOfPeriapsis: Value<AngleU>?
//    var longitudeOfAscendingNode: Value<AngleU>?
//    
//    var orbiting: Object? {
//        return nil
//    }
//    var orbitDirection: DirectionValue? {
//        guard let inclination else { return nil }
//        let direction: Object.Direction? = inclination[.deg] <= 90 ? .prograde : .retrograde
//        return Property(direction)
//    }
//    var barycenter: [Double]? {
//        guard let orbiting = orbiting, let mass = mass, let orbitingMass = orbiting.mass else { return nil }
//        return (position * mass[.kg] + orbiting.position * orbitingMass[.kg]) / (mass[.kg] + orbitingMass[.kg])
//    }
//    var comVelocity: [Double]? {
//        guard let orbiting = orbiting, let mass = mass, let orbitingMass = orbiting.mass else { return nil }
//        return (velocity * mass[.kg] + orbiting.velocity * orbitingMass[.kg]) / (mass[.kg] + orbitingMass[.kg])
//    }
//    var totalMass: Value<MassU>? {
//        guard let orbitingMass = orbiting?.mass else { return nil }
//        guard let mass = mass else { return orbitingMass }
//        return Value(mass[.kg] + orbitingMass[.kg], .kg)
//    }
//    
//    var perihelion: Value<DistanceU>? {
//        guard let semimajorAxis, let eccentricity else { return nil }
//        let perihelion = semimajorAxis[.km] * (1 - eccentricity.value)
//        return Value(perihelion, .km)
//    }
//    var aphelion: Value<DistanceU>? {
//        guard let semimajorAxis, let eccentricity else { return nil }
//        let aphelion = semimajorAxis[.km] * (1 + eccentricity.value)
//        return Value(aphelion, .km)
//    }
//    
//    func velocity(at radius: Value<DistanceU>) -> Value<SpeedU>? {
//        guard let orbiting, let semimajorAxis, let mass = orbiting.mass else { return nil }
//        let velocity = sqrt( G * mass[.kg] * ( 2/radius[.m] - 1/semimajorAxis[.m] ) )
//        return Value(velocity, .m / .s).converted(to: .km / .s)
//    }
//    var averageVelocity: Value<SpeedU>? {
//        guard let semimajorAxis, let siderealPeriod, let eccentricity else { return nil }
//        let averageVelocity = 2 * .pi * semimajorAxis[.km] / siderealPeriod[.s] * (1 - 1/4*pow(eccentricity.value,2) - 3/64*pow(eccentricity.value,4) - 5/256*pow(eccentricity.value,6) - 175/16384*pow(eccentricity.value,8) )
//        return Value(averageVelocity, .km / .s)
//    }
//    var maxVelocity: Value<SpeedU>? {
//        guard let perihelion else { return nil }
//        return velocity(at: perihelion)
//    }
//    var minVelocity: Value<SpeedU>? {
//        guard let aphelion else { return nil }
//        return velocity(at: aphelion)
//    }
//    
//    var inclinationReference: String? {
//        guard let orbiting else { return nil }
//        if orbiting.name == "Sun" || orbiting.name == "Earth" { return "the ecliptic" }
//        if self is Moon { return "\(orbiting.name)'s equator" }
//        return nil
//    }
//    
//    
//    
//    // MARK: - Rotation
//    
//    var siderealRotation: Value<TimeU>?
//    var synodicRotation: Value<TimeU>?
//    
//    var axialTilt: Value<AngleU>?
//    
//    var poleRAReference: Value<AngleU>?
//    var poleDecReference: Value<AngleU>?
//    var poleRAPrecession: Value<Frac<AngleU, TimeU>>?
//    var poleDecPrecession: Value<Frac<AngleU, TimeU>>?
//    var poleRA: Value<AngleU>? {
//        guard let poleRAReference else { return nil }
//        let poleRA = poleRAReference[.deg] + (poleRAPrecession?[.deg / .days] ?? 0) * Date().j2000Date
//        return Value(poleRA, .deg)
//    }
//    var poleDec: Value<AngleU>? {
//        guard let poleDecReference else { return nil }
//        let poleDec = poleDecReference[.deg] + (poleDecPrecession?[.deg / .days] ?? 0) * Date().j2000Date
//        return Value(poleDec, .deg)
//    }
//    
//    var rotationReferenceAngle: Value<AngleU>?
//    var rotationRate: Value<Frac<AngleU, TimeU>>?
//    var rotationAngle: Value<AngleU>? {
//        guard let rotationReferenceAngle else { return nil }
//        let rotationAngle = rotationReferenceAngle[.deg] + (rotationRate?[.deg / .days] ?? 0) * Spacetime.shared.currentDate.j2000Date
//        return Value(rotationAngle, .deg)
//    }
//    
//    var rotationDirection: DirectionValue? {
//        guard let axialTilt else { return nil }
//        let direction: Object.Direction? = axialTilt[.deg] <= 90 ? .prograde : .retrograde
//        return Property(direction)
//    }
//    var rotationAxisDirection: [Double] {
//        guard let ra = poleRA?[.rad] as Double?, let dec = poleDec?[.rad] as Double? else { return [0,0,1] }
//        let relativeDirection = [cos(ra) * cos(dec), sin(ra) * cos(dec), sin(dec)]
//        return relativeDirection.rotated(by: -23.44 * .pi/180, about: [1,0,0])
//    }
//    
//    var angularVelocity: Value<Frac<AngleU, TimeU>>? {
//        guard let siderealRotation else { return nil }
//        let angularVelocity = 2 * .pi / siderealRotation[.s]
//        return Value(angularVelocity, .rad / .s)
//    }
//    var rotationalVelocity: Value<SpeedU>? {
//        guard let angularVelocity, let radius = equatorialRadius ?? meanRadius else { return nil }
//        let rotationVelocity = angularVelocity[.rad / .s] * radius[.km]
//        return Value(rotationVelocity, .km / .s)
//    }
//    var momentOfInertia: Value<Prod<MassU, Square<DistanceU>>>? {
//        guard let radius = equatorialRadius ?? meanRadius, let mass else { return nil }
//        let momentOfInertia = 2/5 * mass[.kg] * pow(radius[.m], 2)
//        return Value(momentOfInertia, .kg * Square(.m))
//    }
//    
//    
//    // MARK: - Structure
//    
//    var meanRadius: Value<DistanceU>?
//    var equatorialRadius: Value<DistanceU>?
//    
//    var mass: Value<MassU>?
//    
//    var hasMagneticField: Bool?
//    var hasRings: Bool?
//    
//    var polarRadius: Value<DistanceU>? {
//        if let meanRadius, let equatorialRadius {
//            let polarRadius = 3*meanRadius[.km] - 2*equatorialRadius[.km]
//            return Value(polarRadius, .km)
//        }
//        return nil
//    }
//    
//    var volume: Value<VolumeU>? {
//        if let equatorialRadius, let polarRadius {
//            let volume = 4/3 * .pi * pow(equatorialRadius[.m], 2) * polarRadius[.m]
//            return Value(volume, Cube(.m))
//        } else if let meanRadius {
//            let volume = 4/3 * .pi * pow(meanRadius[.m], 3)
//            return Value(volume, Cube(.m))
//        }
//        return nil
//    }
//    var surfaceArea: Value<AreaU>? {
//        if let equatorialRadius, let polarRadius {
//            let area = 4 * .pi * pow( ( pow(equatorialRadius[.m], 3.2) + 2*pow(equatorialRadius[.m]*polarRadius[.m], 1.6) ) / 3, 1/1.6)
//            return Value(area, Square(.m))
//        } else if let meanRadius {
//            let area = 4 * .pi * pow(meanRadius[.m], 2)
//            return Value(area, Square(.m))
//        }
//        return nil
//    }
//    var flattening: Value<Unitless>? {
//        guard let equatorialRadius, let polarRadius else { return nil }
//        let flattening = (equatorialRadius[.km] - polarRadius[.km]) / equatorialRadius[.km]
//        return Value(flattening)
//    }
//    
//    var meanDensity: Value<Frac<MassU,VolumeU>>? {
//        guard let volume, let mass else { return nil }
//        let density = mass[.g] / volume[Cube(.m)]
//        return Value(density, .g / Cube(.m))
//    }
//    
//    
//    // MARK: - Environment
//    
//    var temperature: Value<TemperatureU>?
//    var pressure: Value<PressureU>?
//    
//    var surfaceGravity: Value<AccelerationU>? {
//        guard let meanRadius, let mass else { return nil }
//        let gravity = G * mass[.kg] / pow(meanRadius[.m], 2)
//        return Value(gravity, .m / Square(.s))
//    }
//    var escapeVelocity: Value<SpeedU>? {
//        guard let meanRadius, let mass else { return nil }
//        let escape = sqrt(2 * G * mass[.kg] / meanRadius[.m])
//        return Value(escape, .m / .s)
//    }
//    
//    
//    // MARK: - Models
//    
//    var visual: Visual?
//    var staticModel: Model
//    var dynamicModel: Model
//    
//    
//    // MARK: - Live Data
//    
//    var ephemerisID: Int? = nil
//    var ephemerisSet: Bool = false
//    
//    var position: [Double]
//    var velocity: [Double]
//    
//    var distance: Double {
//        return position.magnitude
//    }
//    var distanceToEarth: Double? {
//        return name != "Earth" ? distance(to: Spacetime.shared.objects.first(where: { $0.name == "Earth" })!.position) : nil
//    }
//    var speed: Double {
//        return velocity.magnitude
//    }
//    var radialVelocity: [Double] {
//        return velocity.proj(vector: position)
//    }
//    var tangentialVelocity: [Double] {
//        return velocity - radialVelocity
//    }
//    
//    func position(relativeTo position: [Double]) -> [Double] {
//        return self.position - position
//    }
//    func distance(to position: [Double]) -> Double {
//        return (position - self.position).magnitude
//    }
//    func distance(to object: Object) -> Double {
//        return distance(to: object.position)
//    }
//    func direction(toward position: [Double]) -> [Double] {
//        return (position - self.position) / (position - self.position).magnitude
//    }
//    func direction(toward object: Object) -> [Double] {
//        return direction(toward: object.position)
//    }
//    
//    func velocity(relativeTo velocity: [Double]) -> [Double] {
//        return self.velocity - velocity
//    }
//    
//    var displacementFromCOM: [Double]? {
//        guard let barycenter else { return position }
//        return position(relativeTo: barycenter)
//    }
//    var distanceFromCOM: Double? {
//        return displacementFromCOM?.magnitude
//    }
//    var velocityFromCOM: [Double]? {
//        guard let comVelocity else { return velocity }
//        return velocity(relativeTo: comVelocity)
//    }
//    var speedFromCOM: Double? {
//        return velocityFromCOM?.magnitude
//    }
//    
//    var trueAnomaly: Double {
//        guard let displacementFromCOM, let velocityFromCOM else { return 0 }
//        return displacementFromCOM.signedAngle(with: eccentricityVector, around: displacementFromCOM.cross(velocityFromCOM).unitVector, clockwise: false)
//    }
//    
//    func changeReferenceFrame(to relativePosition: [Double]) {
//        position = position - relativePosition
//    }
//    
//    var maxDistance: Double {
//        return aphelion?[.km] as Double? ?? 0
//    }
//    
//    var orbitalPlane: [Double] {
//        guard let mass = totalMass, let radius = ephemerisSet ? displacementFromCOM : Optional(position), let velocity = ephemerisSet ? velocityFromCOM : Optional(velocity) else { return [0,0,0] }
//        
//        let μ = G * mass[.kg]
//        let r = radius * 1000
//        let v = velocity * 1000 * (ephemerisSet ? 1 : sqrt(μ / r.magnitude)/1000)
//        
//        return r.cross(v).unitVector
//    }
//    
//    var semimajorAxisLength: Double {
//        guard let mass = totalMass, let radius = ephemerisSet ? displacementFromCOM : Optional(position), let velocity = ephemerisSet ? velocityFromCOM : Optional(velocity) else { return 0 }
//        
//        let μ = G * mass[.kg]
//        let r = radius * 1000
//        let v = velocity * 1000 * (ephemerisSet ? 1 : sqrt(μ / r.magnitude)/1000)
//        
//        return μ / (2 * μ / r.magnitude - pow(v.magnitude, 2)) / 1000
//    }
//    
//    var eccentricityVector: [Double] {
//        guard let mass = totalMass, let radius = ephemerisSet ? displacementFromCOM : Optional(position), let velocity = ephemerisSet ? velocityFromCOM : Optional(velocity) else { return [0,0,0] }
//        
//        let μ = G * mass[.kg]
//        let r = radius * 1000
//        let v = velocity * 1000 * (ephemerisSet ? 1 : sqrt(μ / r.magnitude)/1000)
//        
//        return (pow(v.magnitude, 2) / μ - 1 / r.magnitude) * r - (r.dot(v) / μ) * v
//    }
//    
//    var orbitalInclination: Double {
//        var referencePlane: [Double] = [0,0,1]
//        if let earth = Spacetime.shared.objects.first(where: { $0.name == "Earth" }), let earthRadius = earth.displacementFromCOM, let earthVelocity = earth.velocityFromCOM {
//            referencePlane = earthRadius.unitVector.cross(earthVelocity.unitVector).unitVector
//        }
//        let inclination = orbitalPlane.angle(with: referencePlane)
//        guard !inclination.isNaN else { return 0 }
//        return inclination
//    }
//    
//    var longitudeAscendingNode: Double {
//        return atan2(orbitalPlane.x, -orbitalPlane.y)
//    }
//    
//    var lineOfNodes: [Double] {
//        return [cos(longitudeAscendingNode), sin(longitudeAscendingNode), 0]
//    }
//    
//    var longitudePeriapsis: Double {
//        return ephemerisSet ? eccentricityVector.rotated(by: -orbitalInclination, about: lineOfNodes).angle : 1/2 * .pi
//    }
//    
//    var majorAxisLength: Double {
//        return 2 * semimajorAxisLength
//    }
//    
//    var orbitalPath: (Angle) -> [Double] {
//
//        guard let mass = totalMass, let radius = ephemerisSet ? displacementFromCOM : Optional(position), let velocity = ephemerisSet ? velocityFromCOM : Optional(velocity) else { return { _ in [0,0,0] } }
//
//        // Generate the current parameters
//        let μ = G * mass[.kg]
//        let r = radius * 1000
//        let v = velocity * 1000 * (ephemerisSet ? 1 : sqrt(μ / r.magnitude)/1000)
//
//        // Calculate the eccentricity and periapsis
//        let eccentricityVector = (pow(v.magnitude, 2) / μ - 1 / r.magnitude) * r - (r.dot(v) / μ) * v
//        let semimajorAxis = μ / (2 * μ / r.magnitude - pow(v.magnitude, 2))
//        let eccentricity = eccentricityVector.magnitude
//
//        return { theta in
//            let distance = semimajorAxis * (1 - pow(eccentricity, 2)) / (1 + eccentricity * cos(theta.radians))
//            return distance * [cos(theta.radians), sin(theta.radians), 0] / 1000
//        }
//    }
//    
//    var orbitalPathFunction: (Angle) -> [Double] {
//
//        guard let mass = totalMass, let radius = ephemerisSet ? displacementFromCOM : Optional(position), let velocity = ephemerisSet ? velocityFromCOM : Optional(velocity) else { return { _ in [0,0,0] } }
//
//        // Generate the current parameters
//        let μ = G * mass[.kg]
//        let r = radius * 1000
//        let v = velocity * 1000 * (ephemerisSet ? 1 : sqrt(μ / r.magnitude)/1000)
//
//        // Calculate the plane equations
//        let orbitalPlane = r.cross(v).unitVector
//        var referencePlane: [Double] = [0,0,1]
//        if let earth = Spacetime.shared.objects.first(where: { $0.name == "Earth" }), let earthRadius = earth.displacementFromCOM, let earthVelocity = earth.velocityFromCOM {
//            referencePlane = earthRadius.unitVector.cross(earthVelocity.unitVector).unitVector
//        }
//
//        // Calculate the inclination and line of nodes
//        var inclination = orbitalPlane.angle(with: referencePlane)
//        var longitudeOfAscendingNode = atan2(orbitalPlane.x, -orbitalPlane.y)
//        if inclination.isNaN || longitudeOfAscendingNode.isNaN {
//            inclination = 0
//            longitudeOfAscendingNode = 0
//        }
//        let lineOfNodes = [cos(longitudeOfAscendingNode), sin(longitudeOfAscendingNode), 0]
//
//        // Calculate the eccentricity and periapsis
//        let eccentricityVector = (pow(v.magnitude, 2) / μ - 1 / r.magnitude) * r - (r.dot(v) / μ) * v
//        let longitudeOfPerihelion = ephemerisSet ? eccentricityVector.rotated(by: -inclination, about: lineOfNodes).angle : 1/2 * .pi
//        let semimajorAxis = μ / (2 * μ / r.magnitude - pow(v.magnitude, 2))
//        let eccentricity = eccentricityVector.magnitude
//
//        return { theta in
//            let distance = semimajorAxis * (1 - pow(eccentricity, 2)) / (1 + eccentricity * cos(theta.radians))
//            var orbitalPosition = distance * [cos(theta.radians), sin(theta.radians), 0] / 1000
//
//            // Rotate the orbital path by the longitude of perihelion
//            orbitalPosition = orbitalPosition.rotated(by: longitudeOfPerihelion, about: [0,0,1])
//
//            // Tilt the orbital path by the inclination
//            orbitalPosition = orbitalPosition.rotated(by: inclination, about: lineOfNodes)
//
//            return orbitalPosition
//        }
//    }
//    
//    
//    // MARK: - Relationships
//    
//    var systemNames: [String]
//    
//    var systems: [System] {
//        return Spacetime.shared.systems.filter { $0.objects.contains(where: { self == $0 }) }
//    }
//    var mainSystem: System {
//        return systems.first!
//    }
//    var orbitSystem: System? {
//        return systems.first(where: { $0.firstObject != self })
//    }
//    var hostSystem: System? {
//        return systems.first(where: { $0.firstObject == self })
//    }
//    var soloSystem: System {
//        return System(id: -1, name: name, objects: [self])
//    }
//    
//    var referenceObject: Object {
//        return Spacetime.shared.objects.first(where: { $0.name == "Earth" })!
//    }
//    var matchingObjects: [Object] {
//        return mainSystem.objects.filter { Swift.type(of: self) == Swift.type(of: $0) }
//    }
//    var allMatchingObjects: [Object] {
//        return Spacetime.shared.objects.filter { Swift.type(of: self) == Swift.type(of: $0) }
//    }
//    var similarObjects: [Object] {
//        return mainSystem.objects.filter { self.type == $0.type }
//    }
//    var allSimilarObjects: [Object] {
//        return Spacetime.shared.objects.filter { self.type == $0.type }
//    }
//    var allObjects: [Object] {
//        return Spacetime.shared.objects
//    }
//    
//    
//    // MARK: - Details
//    
//    var associatedColor: Color
//    var backgroundColor: Color { associatedColor.opacity(0.1) }
//    
//    var typeName: String {
//        return "Object"
//    }
//    var sentenceTypeName: String {
//        return typeName.lowercased()
//    }
//    var sentenceName: String {
//        switch name {
//        case "Sun": return "the Sun"
//        case "Moon": return "the Moon"
//        default: return name
//        }
//    }
//    var subtitle: String {
//        return typeName
//    }
//    var idTitle: String? {
//        return nil
//    }
//    
//    
//    // MARK: - Coding
//    
//    enum CodingKeys: String, CodingKey {
//        case id, name, type, color, discoveredBy, discoveryYear, discoveryMethod, namesake, systems, visual, size
//        case meanRadius, equaRadius, mass, temperature, pressure, hasMagneticField, hasRings
//        case semimajorAxis, siderealPeriod, synodicPeriod, tropicalPeriod, inclination, eccentricity, argumentOfPeriapsis, longitudeOfAscendingNode
//        case siderealRotation, synodicRotation, axialTilt, poleRAReference, poleDecReference, poleRAPrecession, poleDecPrecession, rotationReferenceAngle, rotationRate
//        case visualMagnitude, geometricAlbedo
//    }
//    
//    required init(from decoder: Decoder) throws {
//        
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        
//        self.id = UUID()
//        let name = try container.decode(String.self, forKey: .name)
//        self.name = name
//        self.type = try container.decode(ObjectType.self, forKey: .type)
//        if let rgb = try? container.decode([Double].self, forKey: .color) {
//            self.associatedColor = Color(red: rgb[0]/255, green: rgb[1]/255, blue: rgb[2]/255)
//        } else {
//            self.associatedColor = Color.init(white: 0.7)
//        }
//        
//        self.ephemerisID = try? container.decode(Int.self, forKey: .id)
//        
//        self.discoveredBy = try? container.decode(String.self, forKey: .discoveredBy)
//        self.discoveryYear = try? container.decode(Int.self, forKey: .discoveryYear)
//        self.discoveryMethod = try? container.decode(String.self, forKey: .discoveryMethod)
//        self.namesake = try? container.decode(String.self, forKey: .namesake)
//        self.systemNames = try container.decode([String].self, forKey: .systems)
//        
//        // Structural
//        
//        let meanRadius = try? container.decode(Double.self, forKey: .meanRadius)
//        let equatorialRadius = try? container.decode(Double.self, forKey: .equaRadius)
//        let mass = try? container.decode(Double.self, forKey: .mass)
//        let temperature = try? container.decode(Double.self, forKey: .temperature)
//        let pressure = try? container.decode(Double.self, forKey: .pressure)
//        
//        self.meanRadius = Value(meanRadius, .km)
//        self.equatorialRadius = Value(equatorialRadius, .km)
//        self.mass = Value(mass, .kg)
//        self.temperature = Value(temperature, .C)
//        self.pressure = Value(pressure, .bars)
//        
//        self.hasMagneticField = try? container.decode(Bool.self, forKey: .hasMagneticField)
//        self.hasRings = try? container.decode(Bool.self, forKey: .hasRings)
//        
//        // Orbit
//        
//        let semimajorAxis = try? container.decode(Double.self, forKey: .semimajorAxis)
//        let siderealPeriod = try? container.decode(Double.self, forKey: .siderealPeriod)
//        let synodicPeriod = try? container.decode(Double.self, forKey: .synodicPeriod)
//        let tropicalPeriod = try? container.decode(Double.self, forKey: .tropicalPeriod)
//        let eccentricity = try? container.decode(Double.self, forKey: .eccentricity)
//        let inclination = try? container.decode(Double.self, forKey: .inclination)
//        let argumentOfPeriapsis = try? container.decode(Double.self, forKey: .argumentOfPeriapsis)
//        let longitudeOfAscendingNode = try? container.decode(Double.self, forKey: .longitudeOfAscendingNode)
//        
//        self.semimajorAxis = Value(semimajorAxis, type == .moon ? .km : .AU)
//        self.siderealPeriod = Value(siderealPeriod, .days)
//        self.synodicPeriod = Value(synodicPeriod, .days)
//        self.tropicalPeriod = Value(tropicalPeriod, .days)
//        self.eccentricity = Value(eccentricity)
//        self.inclination = Value(inclination, .deg)
//        self.argumentOfPeriapsis = Value(argumentOfPeriapsis, .deg)
//        self.longitudeOfAscendingNode = Value(longitudeOfAscendingNode, .deg)
//        
//        // Rotation
//        
//        let siderealRotation = try? container.decode(Double.self, forKey: .siderealRotation)
//        let synodicRotation = try? container.decode(Double.self, forKey: .synodicRotation)
//        let axialTilt = try? container.decode(Double.self, forKey: .axialTilt)
//        let poleRAReference = try? container.decode(Double.self, forKey: .poleRAReference)
//        let poleDecReference = try? container.decode(Double.self, forKey: .poleDecReference)
//        let poleRAPrecession = try? container.decode(Double.self, forKey: .poleRAPrecession)
//        let poleDecPrecession = try? container.decode(Double.self, forKey: .poleDecPrecession)
//        let rotationReferenceAngle = try? container.decode(Double.self, forKey: .rotationReferenceAngle)
//        let rotationRate = try? container.decode(Double.self, forKey: .rotationRate)
//        
//        self.siderealRotation = Value(siderealRotation, .hr)
//        self.synodicRotation = Value(synodicRotation, .hr)
//        self.axialTilt = Value(axialTilt, .deg)
//        self.poleRAReference = Value(poleRAReference, .deg)
//        self.poleDecReference = Value(poleDecReference, .deg)
//        self.poleRAPrecession = Value(poleRAPrecession, .deg / .centuries)
//        self.poleDecPrecession = Value(poleDecPrecession, .deg / .centuries)
//        self.rotationReferenceAngle = Value(rotationReferenceAngle, .deg)
//        self.rotationRate = Value(rotationRate, .deg / .days)
//        
//        
//        // Position
//        
//        self.position = []
//        self.velocity = []
//        
//        // Models
//        
//        if let visual = try? container.decode(Visual.self, forKey: .visual) {
//            self.visual = visual
//            self.staticModel = Model(visual: visual)
//            self.dynamicModel = Model(visual: visual)
//        } else {
//            self.visual = nil
//            self.staticModel = Model()
//            self.dynamicModel = Model()
//        }
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(name, forKey: .name)
//    }
//    
//    static func == (lhs: Object, rhs: Object) -> Bool {
//        return lhs.id == rhs.id && lhs.position == rhs.position
//    }
//    
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//    
//    // MARK: - Enums
//    
//    enum Direction: String {
//        case prograde = "Prograde"
//        case retrograde = "Retrograde"
//    }
//    
//    enum ObjectType: String, Codable {
//        case star
//        case planet
//        case moon
//    }
//}
//
//
