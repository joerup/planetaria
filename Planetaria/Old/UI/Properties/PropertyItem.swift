//
//  PropertyItem.swift
//  Planetaria
//
//  Created by Joe Rupertus on 1/25/23.
//

import Foundation
import SwiftUI
import PlanetariaData

struct PropertyItem<ValueType: Equatable, UnitType: PlanetariaData.Unit> {
    var id = UUID()
    var name: String
    var value: (Node) -> (Property<ValueType, UnitType>?)
}

enum PropertyCategory: String, CaseIterable {

    case stellar = "Stellar"
    case orbit = "Orbit"
    case rotation = "Rotation"
    case structure = "Structure"
    case environment = "Environment"

    var title: String {
        return self.rawValue
    }

    var isExpandable: Bool {
        return true
    }

//    func satisfied(by object: Object) -> Bool {
//        switch self {
//        case .stellar: return object is Star
//        case .orbit: return object.semimajorAxis != nil && object.siderealPeriod != nil
//        case .rotation: return object.siderealRotation != nil
//        case .structure: return object.mass != nil || object.meanRadius != nil
//        case .environment: return object.temperature != nil || object.surfaceGravity != nil
//        }
//    }
}
