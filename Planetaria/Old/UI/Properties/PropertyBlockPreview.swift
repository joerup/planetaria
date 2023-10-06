////
////  PropertyBlockPreview.swift
////  Planetaria
////
////  Created by Joe Rupertus on 1/25/23.
////
//
//import SwiftUI
//
//struct PropertyBlockPreview<ObjectType: Object, ValueType: Equatable, UnitType: Unit>: View {
//    
//    var object: ObjectType
//    var name: String
//    var text: String? = nil
//    var subtitleArg: ((ObjectType) -> String?)?
//    var units: [UnitType]? = nil
//    
//    var mainProperty: PropertyItem<ObjectType, ValueType, UnitType>
//    var otherProperties: [PropertyItem<ObjectType, ValueType, UnitType>] = []
//    
//    var properties: [PropertyItem<ObjectType, ValueType, UnitType>] {
//        [mainProperty] + otherProperties
//    }
//    
//
//    var body: some View {
//        Text("uh oh")
////        PropertyText(property: mainProperty.value(object), text: text ?? name, units: units, alignment: mainProperty.alignment)
//    }
//}
