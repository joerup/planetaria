////
////  System.swift
////  Planetaria
////
////  Created by Joe Rupertus on 1/13/23.
////
//
//import Foundation
//
//struct System: Identifiable, Hashable, Equatable {
//
//    var id: Int
//    var name: String
//    var objects: [Object]
//    var ephemerisSet: Bool = false
//
//    init(id: Int, name: String, objects: [Object]) {
//        self.id = id
//        self.name = name
//        self.objects = objects
//    }
//
//    var firstObject: Object {
//        return objects.first!
//    }
//    var primaryObjects: [Object] {
//        guard objects.count >= 10 else { return objects }
//        let objects = stars + majorPlanets + majorMoons
//        return objects.sorted(by: { $0.distance(to: firstObject.position) < $1.distance(to: firstObject.position) })
//    }
//    var secondaryObjects: [Object] {
//        guard objects.count >= 10 else { return [] }
//        return objects.filter { !primaryObjects.contains($0) }.sorted(by: { $0.distance(to: firstObject.position) < $1.distance(to: firstObject.position) })
//    }
//
//    var primaryType: SystemType {
//        if firstObject is Star {
//            return .star
//        } else if firstObject is Planet && !(firstObject is MinorPlanet) {
//            return .planet
//        }
//        return .minor
//    }
//    var secondaryType: SystemType {
//        if firstObject is Star {
//            return .planet
//        } else if firstObject is Planet && !(firstObject is MinorPlanet) {
//            return .moon
//        }
//        return .minor
//    }
//
//    var fullName: String {
//        return "\(name) System"
//    }
//    var subtitle: String {
//        return "\(firstObject.sentenceName) and its \(secondaryType.rawValue)\(objects.count > 2 ? "s" : "")"
//    }
//
//    var stars: [Star] {
//        objects.filter { $0 is Star }.map { $0 as! Star }
//    }
//    var planets: [Planet] {
//        objects.filter { $0 is Planet }.map { $0 as! Planet }
//    }
//    var moons: [Moon] {
//        objects.filter { $0 is Moon }.map { $0 as! Moon }
//    }
//
//    var majorPlanets: [Planet] {
//        planets.filter { $0.isMajor }
//    }
//    var minorPlanets: [MinorPlanet] {
//        planets.filter { $0 is MinorPlanet }.map { $0 as! MinorPlanet }
//    }
//    var comets: [Comet] {
//        planets.filter { $0 is Comet }.map { $0 as! Comet }
//    }
//
//    var dwarfPlanets: [MinorPlanet] {
//        minorPlanets.filter { $0.types.contains(.dwarfPlanet) }
//    }
//    var asteroids: [MinorPlanet] {
//        minorPlanets.filter { $0.types.contains(.asteroid) }
//    }
//
//    var majorMoons: [Moon] {
//        if moons.count < 4 { return moons }
//        return moons.filter { $0.isMajor }
//    }
//    var minorMoons: [Moon] {
//        if moons.count < 4 { return [] }
//        return moons.filter { $0.isMinor }
//    }
//
//    var maxDistance: Double {
//        return primaryObjects.last?.distance ?? 1E+9
//    }
//
//    var relatedSystems: [System] {
//        var systems: [System] = []
//        objects.forEach { $0.systems.forEach { system in
//            if system != self && !systems.contains(system) {
//                systems.append(system)
//            }
//        }}
//        return systems
//    }
//
//    var parentSystem: System? {
//        if firstObject.mainSystem != self {
//            return firstObject.mainSystem
//        }
//        return nil
//    }
//
//    var moonSystems: [System] {
//        guard !stars.isEmpty else { return [] }
//        var systems: [System] = []
//        majorPlanets.forEach { $0.systems.forEach { system in
//            if system != self && !systems.contains(system) {
//                systems.append(system)
//            }
//        }}
//        var minorSystem = System(id: -1, name: "Other", objects: [])
//        minorSystem.objects += minorPlanets.filter { !$0.moons.isEmpty }
//        minorSystem.objects += minorPlanets.reduce([], { $0 + $1.moons })
//        return systems + [minorSystem]
//    }
//
//    static func == (lhs: System, rhs: System) -> Bool {
//        return lhs.objects == rhs.objects
//    }
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//
//    func loadPrimaryEphemerides() async {
//        for object in primaryObjects {
//            await object.loadEphemeris()
//            print("Loaded \(object.name)")
//        }
//    }
//    func loadSecondaryEphemerides() async {
//        for object in secondaryObjects {
//            await object.loadEphemeris()
//            await MainActor.run {
////                Spacetime.shared.selectedSystem = self
//                print("Loaded \(object.name)")
//            }
//        }
//    }
//
//    enum SystemType: String {
//        case star = "Star"
//        case planet = "Planet"
//        case moon = "Moon"
//        case minor = "Minor"
//    }
//}
//
//
//
//
//
//
