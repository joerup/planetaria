//
//  Node+Types.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 1/12/24.
//

import Foundation

extension Node {
    
    public enum Category: String, Codable, Equatable, Comparable {
        case system
        case star
        case planet
        case minor
        case moon
        
        public static var allCases: [Self] {
            return [.star, .planet, .minor, .moon]
        }
        
        public var text: String {
            switch self {
            case .system:
                "System"
            case .star:
                "Star"
            case .planet:
                "Planet"
            case .moon:
                "Moon"
            case .minor:
                "Minor Planet"
            }
        }
        
        public var orbiterCategory: Category {
            switch self {
            case .system: .star
            case .star: .planet
            default: .moon
            }
        }
        
        private var id: Int {
            switch self {
            case .system:   0
            case .star:     1
            case .planet:   2
            case .minor:    3
            case .moon:     4
            }
        }
        
        public static func == (lhs: Category, rhs: Category) -> Bool {
            lhs.rawValue == rhs.rawValue
        }
        public static func < (lhs: Category, rhs: Category) -> Bool {
            lhs.id < rhs.id
        }
    }
    
    public enum MinorCategory: String, Codable, Equatable {
        case asteroid
        case tno
        case centaur
        case jupiterTrojan
        
        public var text: String {
            switch self {
            case .asteroid:
                "Asteroid"
            case .tno:
                "Trans-Neptunian Object"
            case .centaur:
                "Centaur"
            case .jupiterTrojan:
                "Jupiter Trojan"
            }
        }
        
        public static func minorCategory(from iauCode: String) -> MinorCategory? {
            switch iauCode.uppercased() {
            case "MBA", "OMB":
                return .asteroid
            case "TNO":
                return .tno
            case "CEN":
                return .centaur
            case "TJN":
                return .jupiterTrojan
            default:
                return nil
            }
        }
    }

    public enum Rank: String, Codable, CaseIterable, Equatable, Comparable {
        case primary
        case secondary
        case tertiary
        case quaternary
        
        var priorityValue: Int {
            switch self {
            case .primary:
                return 1
            case .secondary:
                return 2
            case .tertiary:
                return 3
            case .quaternary:
                return 4
            }
        }
        
        public static func == (lhs: Rank, rhs: Rank) -> Bool {
            lhs.priorityValue == rhs.priorityValue
        }
        public static func < (lhs: Rank, rhs: Rank) -> Bool {
            lhs.priorityValue > rhs.priorityValue
        }
        // 1 is highest, 4 is lowest
    }
}
