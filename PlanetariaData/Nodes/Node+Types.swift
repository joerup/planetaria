//
//  Node+Types.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 1/12/24.
//

import Foundation

extension Node {
    
    public enum Category: String, Codable {
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
    }

    public enum Rank: String, Codable, CaseIterable {
        case primary
        case secondary
        case tertiary
        case quaternary
    }
}
