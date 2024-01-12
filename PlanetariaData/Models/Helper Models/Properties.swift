//
//  Properties.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/14/23.
//

import Foundation

public class Properties {
    
    public var orbit: Orbit?
    public var rotation: Rotation?
    
    public var group: String?
    public var discovered: Int?
    public var discoverer: String?
    public var namesake: String?
    
    public var mass: Value<MassU>?
    public var radius: Value<DistanceU>?
    
    public var orbitalPeriod: Value<TimeU>?
    
    public var semimajorAxis: Value<DistanceU>?
    public var eccentricity: Value<Unitless>?
    public var inclination: Value<AngleU>?
    public var longitudeOfPeriapsis: Value<AngleU>?
    public var longitudeOfAscendingNode: Value<AngleU>?
    public var meanAnomaly: Value<AngleU>?
    
    public var perihelionDistance: Value<DistanceU>?
    public var aphelionDistance: Value<DistanceU>?
    
    public var rotationPeriod: Value<TimeU>?
    
    public var temperature: Value<TemperatureU>?
    public var pressure: Value<PressureU>?
    
    public var luminosity: Value<PowerU>?
    
    public init(
        group: String?,
        discovered: Int?,
        discoverer: String?,
        namesake: String?,
        mass: Double?,
        radius: Double?,
        semimajorAxis: Double?,
        eccentricity: Double?,
        inclination: Double?,
        longitudeOfPeriapsis: Double?,
        longitudeOfAscendingNode: Double?,
        meanAnomaly: Double?,
        orbitalPeriod: Double?,
        rotationRate: Double?,
        temperature: Double?,
        pressure: Double?,
        luminosity: Double?
    ) {
        self.group = group
        self.discovered = discovered
        self.discoverer = discoverer
        self.namesake = namesake
        
        self.mass = Value(mass, .kg)
        self.radius = Value(radius, .km)
        
        self.semimajorAxis = Value(semimajorAxis, .km)
        self.eccentricity = Value(eccentricity)
        self.inclination = Value(inclination, .deg)
        self.longitudeOfPeriapsis = Value(longitudeOfPeriapsis, .deg)
        self.longitudeOfAscendingNode = Value(longitudeOfAscendingNode, .deg)
        self.meanAnomaly = Value(meanAnomaly, .deg)
        self.orbitalPeriod = Value(orbitalPeriod, .d)
        
        if let semimajorAxis, let eccentricity {
            let perihelion = semimajorAxis * (1 - eccentricity)
            let aphelion = semimajorAxis * (1 + eccentricity)
            self.perihelionDistance = Value(perihelion, .km)
            self.aphelionDistance = Value(aphelion, .km)
        }
        
        if let rotationRate {
            let rotationPeriod = abs(360 / rotationRate)
            self.rotationPeriod = Value(rotationPeriod, .d)
        }
        
        self.temperature = Value(temperature, .C)
        self.pressure = Value(pressure, .bars)
        
        self.luminosity = Value(luminosity, .W)
    }
}
