////
////  Planet.swift
////  Planetaria
////
////  Created by Joe Rupertus on 1/13/23.
////
//
//import Foundation
//
//class Planet: Object {
//    
//    // MARK: - Properties
//    
//    override var typeName: String {
//        return "Planet"
//    }
//    override var subtitle: String {
//        if system?.name == "Solar" {
//            return "The \(numberFromStar.ordinalString) Planet from the Sun"
//        } else {
//            return "Exoplanet in the \(system?.name ?? "") System"
//        }
//    }
//    
//    var isMajor: Bool {
//        return !isMinor
//    }
//    var isMinor: Bool {
//        return self is MinorPlanet || self is Comet
//    }
//    
//    // Relationships
//    
//    var system: System? {
//        return systems.filter({ $0.objects.first is Star }).first
//    }
//    var moonSystem: System? {
//        return systems.filter({ $0.objects.first == self }).first
//    }
//    
//    var star: Star {
//        return system!.stars.first!
//    }
//    override var orbiting: Object? {
//        return star
//    }
//    var numberFromStar: Int {
//        return (system?.planets.firstIndex(of: self) ?? -1) + 1
//    }
//    override var distance: Double {
//        return distance(to: star.position)
//    }
//    
//    var moons: [Moon] {
//        return moonSystem?.moons ?? []
//    }
//    
//    
//    // MARK: - Decoder
//    
//    required init(from decoder: Decoder) throws {
//        try super.init(from: decoder)
//    }
//    
////    init(from data: ExoplanetData) {
////        
////        let name = data.pl_name
////        let star = data.hostname
////        let discoveryYear = data.disc_year
////        let discoveryMethod = data.discoverymethod
////        let mass = data.pl_bmasse
////        let radius = data.pl_rade
////        let temperature = data.pl_eqt
////        let semimajorAxis = data.pl_orbsmax
////        let siderealPeriod = data.pl_orbper
////        let eccentricity = data.pl_orbeccen
////        let inclination = data.pl_orbincl
////        let argumentOfPeriapsis = data.pl_orblper
////        
////        self.semimajorAxis = Value(semimajorAxis ?? 0, .AU)
////        self.siderealPeriod = Value(siderealPeriod ?? 0, .days)
////        self.eccentricity = Value(eccentricity ?? 0)
////        self.inclination = Value(inclination, .deg)
////        self.argumentOfPeriapsis = Value(argumentOfPeriapsis, .deg)
////        
////        super.init(name: name, discoveryYear: discoveryYear, discoveryMethod: discoveryMethod, mass: Value(mass, .mE), radius: Value(radius, .rE), temperature: Value(temperature, .K), systemNames: [star])
////    }
//}
