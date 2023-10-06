//
//  Unit.swift
//  Planetaria
//
//  Created by Joe Rupertus on 1/18/23.
//

import Foundation

public protocol Unit {
    var string: String { get }
    var relativeValue: Double { get }
    var otherUnits: [Self] { get }
    func name(plural: Bool) -> String
}

public extension Unit {
    func ratio(to otherUnit: Unit) -> Double {
        return self.relativeValue / otherUnit.relativeValue
    }
    var name: String {
        return name(plural: true)
    }
    static func *<OtherUnit: Unit>(lhs: Self, rhs: OtherUnit) -> Prod<Self, OtherUnit> {
        return Prod(lhs, rhs)
    }
    static func /<OtherUnit: Unit>(lhs: Self, rhs: OtherUnit) -> Frac<Self, OtherUnit> {
        return Frac(lhs, rhs)
    }
}

public protocol ScaleUnit: Unit {
    var offsetValue: Double { get }
    var secondaryOffsetValue: Double { get }
}

public extension ScaleUnit {
    func offset(to otherUnit: ScaleUnit) -> Double {
        return otherUnit.offsetValue - self.offsetValue
    }
    func secondaryOffset(to otherUnit: ScaleUnit) -> Double {
        return otherUnit.secondaryOffsetValue - self.secondaryOffsetValue
    }
}

public extension Double {
    func convert(from unit1: Unit, to unit2: Unit) -> Double {
        if let unit1 = unit1 as? ScaleUnit, let unit2 = unit2 as? ScaleUnit {
            return (self + unit2.offset(to: unit1)) * unit2.ratio(to: unit1) + unit2.secondaryOffset(to: unit1)
        } else {
            return self * unit2.ratio(to: unit1)
        }
    }
}

public struct Unitless: Unit {
    public var string: String {
        return ""
    }
    public var relativeValue: Double {
        return 0
    }
    public var otherUnits: [Unitless] {
        return [self]
    }
    public func name(plural: Bool) -> String {
        return "unitless"
    }
}

public struct Prod<Unit1: Unit, Unit2: Unit>: Unit {
    var factor1: Unit1
    var factor2: Unit2
    
    init(_ factor1: Unit1, _ factor2: Unit2) {
        self.factor1 = factor1
        self.factor2 = factor2
    }
    
    public var string: String {
        return factor1.string + "•" + (factor2.string.first == " " ? String(factor2.string.dropFirst()) : factor2.string)
    }
    public var relativeValue: Double {
        return factor1.relativeValue * factor2.relativeValue
    }
    public var otherUnits: [Prod<Unit1,Unit2>] {
        return factor1.otherUnits.map { Prod($0,factor2) }
    }
    public func name(plural: Bool = true) -> String {
        return "\(factor1.name(plural: false)) \(factor2.name(plural: plural))"
    }
}

public struct Frac<Unit1: Unit, Unit2: Unit>: Unit {
    var numerator: Unit1
    var denominator: Unit2
    
    init(_ numerator: Unit1, _ denominator: Unit2) {
        self.numerator = numerator
        self.denominator = denominator
    }
    
    public var string: String {
        return numerator.string + "/" + (denominator.string.first == " " ? String(denominator.string.dropFirst()) : denominator.string)
    }
    public var relativeValue: Double {
        return numerator.relativeValue / denominator.relativeValue
    }
    public var otherUnits: [Frac<Unit1,Unit2>] {
        if numerator is DistanceU && denominator is TimeU {
            let units: [Frac<DistanceU,TimeU>] = [.km / .s, .m / .s, .mi / .s, .ft / .s, .km / .hr, .mi / .hr]
            return units as! [Frac<Unit1, Unit2>]
        } else {
            return numerator.otherUnits.map { Frac($0,denominator) }
        }
    }
    public func name(plural: Bool = true) -> String {
        return "\(numerator.name(plural: plural)) per \(denominator.name(plural: false))"
    }
}

public struct Square<UnitType: Unit>: Unit {
    var unit: UnitType
    
    init(_ unit: UnitType) {
        self.unit = unit
    }
    
    public var string: String {
        return unit.string + "²"
    }
    public var relativeValue: Double {
        return pow(unit.relativeValue, 2)
    }
    public var otherUnits: [Square<UnitType>] {
        return unit.otherUnits.map { Square($0) }
    }
    public func name(plural: Bool = true) -> String {
        return "square \(unit.name(plural: plural))"
    }
}

public struct Cube<UnitType: Unit>: Unit {
    var unit: UnitType
    
    init(_ unit: UnitType) {
        self.unit = unit
    }
    
    public var string: String {
        return unit.string + "³"
    }
    public var relativeValue: Double {
        return pow(unit.relativeValue, 3)
    }
    public var otherUnits: [Cube<UnitType>] {
        return unit.otherUnits.map { Cube($0) }
    }
    public func name(plural: Bool = true) -> String {
        return "cubic \(unit.name(plural: plural))"
    }
}

public enum MassU: String, Unit, CaseIterable {
    case kg
    case g
    case mE = "M⊕"
    case mJ = "MJ"
    case mS = "M☉"
    
    public var string: String {
        return " "+self.rawValue
    }
    public var relativeValue: Double {
        switch self {
        case .kg: return 1
        case .g: return 1000
        case .mE: return 1/5.9722E+24
        case .mJ: return 1/1.89813E+27
        case .mS: return 1/1.98847E+30
        }
    }
    public var otherUnits: [MassU] {
        return MassU.allCases
    }
    public func name(plural: Bool = true) -> String {
        switch self {
        case .kg: return plural ? "kilograms" : "kilogram"
        case .g: return plural ? "grams" : "gram"
        case .mE: return plural ? "earth masses" : "earth mass"
        case .mJ: return plural ? "jovian masses" : "jovian mass"
        case .mS: return plural ? "solar masses" : "solar mass"
        }
    }
}

public enum DistanceU: String, Unit, CaseIterable {
    case km
    case m
    case cm
    case mi
    case ft
    case AU
    case rE = "R⊕"
    case rJ = "RJ"
    case rS = "R☉"
    
    public var string: String {
        return " "+self.rawValue
    }
    public var relativeValue: Double {
        switch self {
        case .km: return 1
        case .m: return 1000
        case .cm: return 1E+5
        case .mi: return 0.621371
        case .ft: return 3280.84
        case .AU: return 1/149597870.7
        case .rE: return 1/6371.0084
        case .rJ: return 1/69911
        case .rS: return 1/695700
        }
    }
    public var otherUnits: [DistanceU] {
        return DistanceU.allCases
    }
    public func name(plural: Bool = true) -> String {
        switch self {
        case .km: return plural ? "kilometers" : "kilometer"
        case .m: return plural ? "meters" : "meter"
        case .cm: return plural ? "centimeters" : "centimeter"
        case .mi: return plural ? "miles" : "mile"
        case .ft: return plural ? "feet" : "foot"
        case .AU: return plural ? "astronomical units" : "astronomical unit"
        case .rE: return plural ? "earth radii" : "earth radius"
        case .rJ: return plural ? "jovian radii" : "jovian radius"
        case .rS: return plural ? "solar radii" : "solar radius"
        }
    }
}

public typealias SpeedU = Frac<DistanceU, TimeU>
public typealias AccelerationU = Frac<DistanceU, Square<TimeU>>
public typealias AreaU = Square<DistanceU>
public typealias VolumeU = Cube<DistanceU>

public enum TimeU: String, Unit, CaseIterable {
    case s
    case min
    case hr
    case d
    case yr
    case centuries
    
    public var string: String {
        return " "+self.rawValue
    }
    public var relativeValue: Double {
        switch self {
        case .s: return 1
        case .min: return 1/60
        case .hr: return 1/3600
        case .d: return 1/86400
        case .yr: return 1/86400/365.25
        case .centuries: return 1/86400/36525
        }
    }
    public var otherUnits: [TimeU] {
        return TimeU.allCases.reversed()
    }
    public func name(plural: Bool = true) -> String {
        switch self {
        case .s: return plural ? "seconds" : "second"
        case .min: return plural ? "minutes" : "minute"
        case .hr: return plural ? "hours" : "hour"
        case .d: return plural ? "days" : "day"
        case .yr: return plural ? "years" : "year"
        case .centuries: return plural ? "centuries" : "century"
        }
    }
}

public enum TemperatureU: String, ScaleUnit, CaseIterable {
    case K
    case C
    case F
    
    public var string: String {
        switch self {
        case .K: return " K"
        case .C: return "ºC"
        case .F: return "ºF"
        }
    }
    public var relativeValue: Double {
        switch self {
        case .K: return 1
        case .C: return 1
        case .F: return 9/5
        }
    }
    public var offsetValue: Double {
        switch self {
        case .K: return 0
        case .C: return 273
        case .F: return 273
        }
    }
    public var secondaryOffsetValue: Double {
        switch self {
        case .K: return 0
        case .C: return 0
        case .F: return -32
        }
    }
    public var otherUnits: [TemperatureU] {
        return TemperatureU.allCases
    }
    public func name(plural: Bool = true) -> String {
        switch self {
        case .K: return "kelvin"
        case .C: return "celsius"
        case .F: return "farenheit"
        }
    }
}

public enum EnergyU: String, Unit, CaseIterable {
    case J
    
    public var string: String {
        return " "+self.rawValue
    }
    public var relativeValue: Double {
        switch self {
        case .J: return 1
        }
    }
    public var otherUnits: [EnergyU] {
        return EnergyU.allCases
    }
    public func name(plural: Bool = true) -> String {
        switch self {
        case .J: return plural ? "joules" : "joule"
        }
    }
}

public enum PowerU: String, Unit, CaseIterable {
    case W
    
    public var string: String {
        return " "+self.rawValue
    }
    public var relativeValue: Double {
        switch self {
        case .W: return 1
        }
    }
    public var otherUnits: [PowerU] {
        return PowerU.allCases
    }
    public func name(plural: Bool = true) -> String {
        switch self {
        case .W: return plural ? "watts" : "watt"
        }
    }
}

public enum PressureU: String, Unit, CaseIterable {
    case bars
    
    public var string: String {
        return " "+self.rawValue
    }
    public var relativeValue: Double {
        switch self {
        case .bars: return 1
        }
    }
    public var otherUnits: [PressureU] {
        return PressureU.allCases
    }
    public func name(plural: Bool = true) -> String {
        switch self {
        case .bars: return plural ? "bars" : "bar"
        }
    }
}

public enum AngleU: String, Unit, CaseIterable {
    case deg
    case rad
    
    public var string: String {
        switch self {
        case .deg: return "º"
        case .rad: return " rad"
        }
    }
    public var relativeValue: Double {
        switch self {
        case .deg: return 180
        case .rad: return .pi
        }
    }
    public var otherUnits: [AngleU] {
        return AngleU.allCases
    }
    public func name(plural: Bool = true) -> String {
        switch self {
        case .deg: return plural ? "degrees" : "degree"
        case .rad: return plural ? "radians" : "radian"
        }
    }
}

