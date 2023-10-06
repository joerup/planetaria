////
////  MinorPlanet.swift
////  Planetaria
////
////  Created by Joe Rupertus on 1/18/23.
////
//
//import Foundation
//
//class MinorPlanet: Planet {
//
//    // MARK: - Properties
//
//    var minorPlanetID: Int
//    var types: [ObjectType]
//
//    // Details
//
//    override var typeName: String {
//        return types.first?.rawValue ?? "Minor Planet"
//    }
//    override var subtitle: String {
//        return "\(typeName)"
//    }
//    override var idTitle: String? {
//        return "ID \(minorPlanetID)"
//    }
//
//
//    // MARK: - Coding
//
//    enum CodingKeys: String, CodingKey {
//        case minorPlanetID, types
//    }
//
//    required init(from decoder: Decoder) throws {
//
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        self.minorPlanetID = try container.decode(Int.self, forKey: .minorPlanetID)
//        self.types = try container.decode([ObjectType].self, forKey: .types)
//
//        try super.init(from: decoder)
//    }
//
//
//    enum ObjectType: String, Codable {
//        case dwarfPlanet = "Dwarf Planet"
//        case asteroid = "Asteroid"
//        case tno = "Trans-Neptunian Object"
//    }
//}
