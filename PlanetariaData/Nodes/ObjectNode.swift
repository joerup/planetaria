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
        case mass, size, ringSize, luminosity
        case semimajorAxis, eccentricity, inclination, longitudeOfPeriapsis, longitudeOfAscendingNode, meanAnomaly, orbitalPeriod
        case rotationRef, rotationRate, poleRARef, poleRARate, poleDecRef, poleDecRate
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
        
        self.ringSize = ringSize
        self.luminosity = luminosity
        
        try super.init(from: decoder)
        
        self.rotation = Rotation(rotationRef: rotationRef, rotationRate: rotationRate, poleRARef: poleRARef, poleRARate: poleRARate, poleDecRef: poleDecRef, poleDecRate: poleDecRate)
        
        self.properties = Properties(group: group, discovered: discovered, discoverer: discoverer, namesake: namesake, mass: mass, radius: size, semimajorAxis: semimajorAxis, eccentricity: eccentricity, inclination: inclination, longitudeOfPeriapsis: longitudeOfPeriapsis, longitudeOfAscendingNode: longitudeOfAscendingNode, meanAnomaly: meanAnomaly, orbitalPeriod: orbitalPeriod, rotationRate: rotationRate, temperature: temperature, pressure: pressure, luminosity: luminosity)
        properties?.rotation = rotation
    }
}
