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
        case asteroid
        case tno
        case moon
        
        public static var allCases: [Self] {
            return [.star, .planet, .asteroid, .tno, .moon]
        }
        
        public var text: String {
            switch self {
            case .system:
                return "System"
            case .star:
                return "Star"
            case .planet:
                return "Planet"
            case .moon:
                return "Moon"
            case .asteroid:
                return "Asteroid"
            case .tno:
                return "Trans-Neptunian Object"
            }
        }
        
        public var orbiterCategory: Category {
            switch self {
            case .system:
                return .star
            case .star:
                return .planet
            case .planet, .asteroid, .tno, .moon:
                return .moon
            }
        }
        
        private var id: Int {
            switch self {
            case .system:   0
            case .star:     1
            case .planet:   2
            case .asteroid: 3
            case .tno:      4
            case .moon:     5
            }
        }
        
        public static func == (lhs: Category, rhs: Category) -> Bool {
            lhs.rawValue == rhs.rawValue
        }
        public static func < (lhs: Category, rhs: Category) -> Bool {
            return lhs.id < rhs.id
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
            return lhs.priorityValue == rhs.priorityValue
        }
        public static func < (lhs: Rank, rhs: Rank) -> Bool {
            return lhs.priorityValue > rhs.priorityValue
        }
        // 1 is highest, 4 is lowest
    }
}
