//
//  ObjectNode+Properties.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/14/23.
//

import Foundation

extension ObjectNode {
    
    public class Properties {
        
        var orbit: Node.Orbit?
        var rotation: Node.Rotation?
        
        public var group: String?
        public var discovered: Int?
        public var discoverer: String?
        public var namesake: String?
        
        public var currentDistance: Value<DistanceU>? {
            Value(orbit?.position.magnitude, .km)
        }
        public var currentSpeed: Value<SpeedU>? {
            Value(orbit?.velocity.magnitude, .km / .s)
        }
        
        public var orbitalElementsAvailable: Bool {
            semimajorAxis != nil
        }
        public var structuralElementsAvailable: Bool {
            mass != nil || radius != nil
        }
        
        public var photos: [Photo] = []
        
        public var moons: IntValue?
        
        public var orbitalPeriod: Value<TimeU>?
        public var rotationPeriod: Value<TimeU>?
        public var axialTilt: Value<AngleU>?
        public var temperature: Value<TemperatureU>?
        
        public var semimajorAxis: Value<DistanceU>?
        public var periapsis: Value<DistanceU>?
        public var apoapsis: Value<DistanceU>?
        public var eccentricity: Value<Unitless>?
        public var inclination: Value<AngleU>?
        
        public var mass: Value<MassU>?
        public var radius: Value<DistanceU>?
        public var density: Value<Frac<MassU, VolumeU>>?
        public var gravity: Value<AccelerationU>?
        public var escapeVelocity: Value<SpeedU>?
        
        public var pressure: Value<PressureU>?
        public var luminosity: Value<PowerU>?
        
        public init(
            category: Node.Category,
            group: String?,
            discovered: Int?,
            discoverer: String?,
            namesake: String?,
            moons: Int?,
            mass: Double?,
            radius: Double?,
            density: Double?,
            semimajorAxis: Double?,
            eccentricity: Double?,
            inclination: Double?,
            orbitalPeriod: Double?,
            rotationRate: Double?,
            axialTilt: Double?,
            gravity: Double?,
            escapeVelocity: Double?,
            temperature: Double?,
            pressure: Double?,
            luminosity: Double?
        ) {
            self.group = group
            self.discovered = discovered
            self.discoverer = discoverer
            self.namesake = namesake
            
            self.moons = IntValue(moons)
            
            self.mass = Value(mass, .kg)
            self.radius = Value(radius, .km)
            self.density = Value(density, .g / Cube(.cm))
            self.gravity = Value(gravity, .m / Square(.s))
            self.escapeVelocity = Value(escapeVelocity, .km / .s)
            
            self.orbitalPeriod = Value(orbitalPeriod, .d)?.dynamic()
            
            self.semimajorAxis = Value(semimajorAxis, .km)?.dynamicDistance(for: category)
            self.eccentricity = Value(eccentricity)
            self.inclination = Value(inclination, .deg)
            
            if let semimajorAxis, let eccentricity {
                self.periapsis = Value(semimajorAxis * (1 - eccentricity), .km)?.dynamicDistance(for: category)
                self.apoapsis = Value(semimajorAxis * (1 + eccentricity), .km)?.dynamicDistance(for: category)
            }
            
            if let rotationRate {
                let rotationPeriod = abs(360 / rotationRate)
                self.rotationPeriod = Value(rotationPeriod, .d)?.dynamic()
            }
            self.axialTilt = Value(axialTilt, .deg)
            
            if axialTilt != nil {
                self.temperature = Value(temperature, .C)?.local()
                self.pressure = Value(pressure, .bars)
            }
            
            self.luminosity = Value(luminosity, .W)
        }
    }
}
