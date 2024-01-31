//
//  ObjectNode.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/9/23.
//

import Foundation
import SwiftUI

public class ObjectNode: Node {
    
    public var properties: Properties?
    
    override public var system: SystemNode? {
        return parent?.object == self ? parent : nil
    }
    override public var object: ObjectNode? {
        return self
    }

    public var ringSize: Double
    override public var totalSize: Double {
        return size + ringSize
    }
    
    public var luminosity: Double
    public var intensity: Double {
        return luminosity / (4E6 * .pi * size * size)
    }
    
    private enum CodingKeys: String, CodingKey {
        case group, discovered, discoverer, namesake
        case mass, size, density, gravity, escapeVelocity, ringSize, luminosity, moons
        case semimajorAxis, eccentricity, inclination, orbitalPeriod
        case rotationRef, rotationRate, poleRA, poleDec, axialTilt
        case temperature, pressure
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let group = try? container.decode(String.self, forKey: .group)
        let discovered = try? container.decode(Int.self, forKey: .discovered)
        let discoverer = try? container.decode(String.self, forKey: .discoverer)
        let namesake = try? container.decode(String.self, forKey: .namesake)
        
        let mass = (try? container.decode(Double.self, forKey: .mass)) ?? 0
        let size = (try? container.decode(Double.self, forKey: .size)) ?? 0
        let density = try? container.decode(Double.self, forKey: .density)
        let gravity = try? container.decode(Double.self, forKey: .gravity)
        let escapeVelocity = try? container.decode(Double.self, forKey: .escapeVelocity)
        let ringSize = (try? container.decode(Double.self, forKey: .ringSize)) ?? 0
        let luminosity = try? container.decode(Double.self, forKey: .luminosity)
        let moons = try? container.decode(Int.self, forKey: .moons)
        
        let semimajorAxis = try? container.decode(Double.self, forKey: .semimajorAxis)
        let eccentricity = try? container.decode(Double.self, forKey: .eccentricity)
        let inclination = try? container.decode(Double.self, forKey: .inclination)
        let orbitalPeriod = try? container.decode(Double.self, forKey: .orbitalPeriod)
        
        let rotationRef = try? container.decode(Double.self, forKey: .rotationRef)
        let rotationRate = try? container.decode(Double.self, forKey: .rotationRate)
        let poleRA = try? container.decode(Double.self, forKey: .poleRA)
        let poleDec = try? container.decode(Double.self, forKey: .poleDec)
        let axialTilt = try? container.decode(Double.self, forKey: .axialTilt)
        
        let temperature = try? container.decode(Double.self, forKey: .temperature)
        let pressure = try? container.decode(Double.self, forKey: .pressure)
        
        self.ringSize = ringSize
        self.luminosity = luminosity ?? 0
        
        try super.init(from: decoder)
        
        self.rotation = Rotation(rotationRef: rotationRef, rotationRate: rotationRate, poleRA: poleRA, poleDec: poleDec)
        
        self.properties = Properties(category: category, group: group, discovered: discovered, discoverer: discoverer, namesake: namesake, moons: moons, mass: mass, radius: size, density: density, semimajorAxis: semimajorAxis, eccentricity: eccentricity, inclination: inclination, orbitalPeriod: orbitalPeriod, rotationRate: rotationRate, axialTilt: axialTilt, gravity: gravity, escapeVelocity: escapeVelocity, temperature: temperature, pressure: pressure, luminosity: luminosity)
        properties?.rotation = rotation
    }
    
    override public func set(state: StateVector) {
        super.set(state: state)
        if system == nil {
            properties?.orbit = orbit
        }
    }
}
