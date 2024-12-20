//
//  Property.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 1/20/23.
//

import Foundation

public typealias Value<UnitType: Unit> = Property<Double, UnitType>
public typealias IntValue = Property<Int, Unitless>
public typealias TextValue = Property<String?, Unitless>
public typealias BoolValue = Property<Bool?, Unitless>

public class Property<ValueType: Equatable, UnitType: Unit>: Equatable {

    public var value: ValueType
    public var unit: UnitType

    public init(_ value: ValueType) {
        self.value = value
        self.unit = Unitless() as! UnitType
    }
    public convenience init?(_ value: ValueType?) where UnitType == Unitless {
        guard let value else { return nil }
        self.init(value)
    }
    public init(_ value: ValueType, _ unit: UnitType) where ValueType == Double {
        self.value = value
        self.unit = unit
    }
    public convenience init?(_ value: ValueType?, _ unit: UnitType) where ValueType == Double {
        guard let value else { return nil }
        self.init(value, unit)
    }

    public var string: String {
        if let num = value as? Double {
            return num.string(unit)
        } else if let string = value as? String {
            return string
        } else if let int = value as? Int {
            return String(int)
        } else if let bool = value as? Bool {
            return bool ? "Yes" : "No"
        }
        return "Unknown"
    }
    public var scientificString: String {
        if let num = value as? Double {
            return num.scientificString
        } else if let string = value as? String {
            return string
        } else if let int = value as? Int {
            return String(int)
        } else if let bool = value as? Bool {
            return bool ? "Yes" : "No"
        }
        return "Unknown"
    }

    public subscript(unit: UnitType?) -> Property<ValueType, UnitType> where ValueType == Double {
        guard let unit else { return self }
        return converted(to: unit)
    }
    public subscript(unit: UnitType?) -> ValueType where ValueType == Double {
        guard let unit else { return value }
        return converted(to: unit).value
    }

    public func convert(to otherUnit: UnitType) where ValueType == Double {
        guard !(unit is Unitless) else { return }
        self.value = value.convert(from: unit, to: otherUnit)
        self.unit = otherUnit
    }
    public func converted(to otherUnit: UnitType) -> Property<ValueType, UnitType> where ValueType == Double {
        guard !(unit is Unitless) else { return self }
        return Property(value.convert(from: unit, to: otherUnit), otherUnit)
    }

    public var allUnits: [UnitType] {
        return unit.otherUnits
    }
    public func commonUnit() -> Double where ValueType == Double {
        if let unit = allUnits.first {
            return converted(to: unit).value
        } else {
            return value
        }
    }

    public func dynamic() -> Property<ValueType, UnitType> where ValueType == Double, UnitType == TimeU {
        if self[.s] < 60 {
            return self[.s]
        } else if self[.min] < 60 {
            return self[.min]
        } else if self[.hr] < 36 {
            return self[.hr]
        } else if self[.d] < 1000 {
            return self[.d]
        } else {
            return self[.yr]
        }
    }
    
    public func local() -> Property<ValueType, UnitType> where ValueType == Double, UnitType == DistanceU {
        return Locale.current.measurementSystem == .us ? self[.mi] : self[.km]
    }
    public func local() -> Property<ValueType, UnitType> where ValueType == Double, UnitType == SpeedU {
        return Locale.current.measurementSystem == .us ? self[.mi / .hr] : self[.km / .hr]
    }
    public func local() -> Property<ValueType, UnitType> where ValueType == Double, UnitType == TemperatureU {
        return Locale.current.measurementSystem == .us ? self[.F] : self[.C]
    }

    public func dynamicDistance(for category: Node.Category) -> Property<ValueType, UnitType> where ValueType == Double, UnitType == DistanceU {
        switch category {
        case .star, .planet, .asteroid, .tno, .system:
            return self[.AU]
        case .moon:
            return self[.km]
        }
    }

    public static func == (lhs: Property<ValueType, UnitType>, rhs: Property<ValueType, UnitType>) -> Bool {
        return lhs.value == rhs.value && lhs.unit.name == rhs.unit.name
    }

    public static func < (lhs: Property<ValueType, UnitType>, rhs: Property<ValueType, UnitType>) -> Bool where ValueType == Double {
        return lhs.converted(to: lhs.allUnits.first ?? lhs.unit).value < rhs.converted(to: rhs.allUnits.first ?? rhs.unit).value
    }
}
