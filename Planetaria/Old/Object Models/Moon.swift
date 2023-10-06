////
////  Moon.swift
////  Planetaria
////
////  Created by Joe Rupertus on 1/13/23.
////
//
//import Foundation
//
//class Moon: Object {
//
//    // MARK: - Properties
//
//    var moonID: Int?
//
//    // Details
//
//    override var typeName: String {
//        return "Moon"
//    }
//    override var subtitle: String {
//        return "Moon of \(planet.name)"
//    }
//    override var idTitle: String? {
//        if let romanNumeral = moonID?.romanNumeral {
//            return "\(planet.name) \(romanNumeral)"
//        }
//        return nil
//    }
//
//    var isMajor: Bool {
//        return hasModel
//    }
//    var isMinor: Bool {
//        return !isMajor
//    }
//
//    // Relationships
//
//    var system: System? {
//        return systems.filter({ $0.objects.first is Planet }).first
//    }
//    var planet: Planet {
//        return system!.planets.first!
//    }
//    override var orbiting: Object? {
//        return planet
//    }
//    override var distance: Double {
//        return distance(to: planet.position)
//    }
//
//
//    // MARK: - Coding
//
//    enum CodingKeys: String, CodingKey {
//        case moonID
//    }
//
//    required init(from decoder: Decoder) throws {
//
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        self.moonID = try? container.decode(Int.self, forKey: .moonID)
//
//        try super.init(from: decoder)
//    }
//}
