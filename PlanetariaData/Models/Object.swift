//
//  Object.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/9/23.
//

import Foundation
import SwiftUI
import RealityKit

public class Object: Node, Equatable, Identifiable, Hashable {
    
    public var id: Int
    public var name: String
    
    public var parent: System?
    public var children: [Node] = []
    
    public var category: Category
    public var rank: Rank
    public var color: Color?
    
    public var position: Vector = .zero
    public var velocity: Vector = .zero
    
    public var mass: Double
    public var size: Double
    public var luminosity: Double
    
    public var intensity: Double {
        return luminosity / (4E6 * .pi * size * size)
    }
    
    public var ringSize: Double
    public var totalSize: Double {
        return size + ringSize
    }
    
    public var orbit: Orbit?
    public var rotation: Rotation?
    
    public var properties: Properties?
    
    public var system: System? {
        return parent?.object == self ? parent : nil
    }
    public var object: Object? {
        return self
    }
    
    public var isSet: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case id, name, category, rank, color
        case group, discovered, discoverer, namesake
        case mass, size, ringSize
        case semimajorAxis, eccentricity, inclination, longitudeOfPeriapsis, longitudeOfAscendingNode, meanAnomaly, orbitalPeriod
        case rotationRef, rotationRate, poleRARef, poleRARate, poleDecRef, poleDecRate
        case temperature, pressure
        case luminosity
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        
        self.category = try container.decode(Category.self, forKey: .category)
        self.rank = try container.decode(Rank.self, forKey: .rank)
        if let hex = try? container.decode(String.self, forKey: .color) {
            self.color = Color(hex: hex)
        }
        
        let group = try? container.decode(String.self, forKey: .group)
        let discovered = try? container.decode(Int.self, forKey: .discovered)
        let discoverer = try? container.decode(String.self, forKey: .discoverer)
        let namesake = try? container.decode(String.self, forKey: .namesake)
        
        let mass = (try? container.decode(Double.self, forKey: .mass)) ?? 0
        let size = (try? container.decode(Double.self, forKey: .size)) ?? 0
        let luminosity = (try? container.decode(Double.self, forKey: .luminosity)) ?? 0
        let ringSize = (try? container.decode(Double.self, forKey: .ringSize)) ?? 0
        
        let semimajorAxis = try? container.decode(Double.self, forKey: .semimajorAxis)
        let eccentricity = try? container.decode(Double.self, forKey: .eccentricity)
        let inclination = try? container.decode(Double.self, forKey: .inclination)
        let longitudeOfPeriapsis = try? container.decode(Double.self, forKey: .longitudeOfPeriapsis)
        let longitudeOfAscendingNode = try? container.decode(Double.self, forKey: .longitudeOfAscendingNode)
        let meanAnomaly = try? container.decode(Double.self, forKey: .meanAnomaly)
        let orbitalPeriod = try? container.decode(Double.self, forKey: .orbitalPeriod)
        
        let rotationRef = try? container.decode(Double.self, forKey: .rotationRef)
        let rotationRate = try? container.decode(Double.self, forKey: .rotationRate)
        let poleRARef = try? container.decode(Double.self, forKey: .poleRARef)
        let poleRARate = try? container.decode(Double.self, forKey: .poleRARate)
        let poleDecRef = try? container.decode(Double.self, forKey: .poleDecRef)
        let poleDecRate = try? container.decode(Double.self, forKey: .poleDecRate)
        
        let temperature = try? container.decode(Double.self, forKey: .temperature)
        let pressure = try? container.decode(Double.self, forKey: .pressure)
        
        self.mass = mass
        self.size = size
        self.luminosity = luminosity
        self.ringSize = ringSize
        
        self.rotation = Rotation(rotationRef: rotationRef, rotationRate: rotationRate, poleRARef: poleRARef, poleRARate: poleRARate, poleDecRef: poleDecRef, poleDecRate: poleDecRate)
        
        self.properties = Properties(group: group, discovered: discovered, discoverer: discoverer, namesake: namesake, mass: mass, radius: size, semimajorAxis: semimajorAxis, eccentricity: eccentricity, inclination: inclination, longitudeOfPeriapsis: longitudeOfPeriapsis, longitudeOfAscendingNode: longitudeOfAscendingNode, meanAnomaly: meanAnomaly, orbitalPeriod: orbitalPeriod, rotationRate: rotationRate, temperature: temperature, pressure: pressure, luminosity: luminosity)
        properties?.rotation = rotation
    }
    
    public func set(position: Vector, velocity: Vector) {
        self.position = position
        self.velocity = velocity
        self.isSet = true
        
        self.orbit = Orbit(position: position, velocity: velocity, mass: mass, size: size, hostNode: hostNode)
        properties?.orbit = system?.orbit ?? orbit
    }
    
    public static func == (lhs: Object, rhs: Object) -> Bool {
        return lhs.id == rhs.id && lhs.position == rhs.position
    }
    public static func == (lhs: Object, rhs: Node) -> Bool {
        return lhs.id == rhs.id && lhs.position == rhs.position
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
