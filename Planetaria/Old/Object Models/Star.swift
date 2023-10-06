////
////  Star.swift
////  Planetaria
////
////  Created by Joe Rupertus on 1/13/23.
////
//
//import Foundation
//
//class Star: Object {
//    
//    // MARK: - Properties
//    
//    // Stellar Properties
//    
//    var spectralType: String
//    var luminosity: Value<PowerU>
//    var visualMagnitude: Value<Unitless>
//    var absoluteMagnitude: Value<Unitless>
//    
//    // Other
//    
//    var systemVelocity: Value<SpeedU>?
//    var massConversionRate: Value<Frac<MassU, TimeU>>?
//    
//    // Details
//    
//    override var typeName: String {
//        return "Star"
//    }
//    override var subtitle: String {
//        return "Star"
//    }
//    
//    // Relationships
//    
//    var planets: [Planet] {
//        return systems.reduce([], { $0 + $1.planets })
//    }
//    
//    
//    // MARK: - Decoder
//    
//    enum CodingKeys: String, CodingKey {
//        case spectralType, luminosity, visualMagnitude, absoluteMagnitude, systemVelocity, massConversionRate
//    }
//    
//    required init(from decoder: Decoder) throws {
//        
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        
//        self.spectralType = try container.decode(String.self, forKey: .spectralType)
//        
//        let luminosity = try container.decode(Double.self, forKey: .luminosity)
//        let visualMagnitude = try container.decode(Double.self, forKey: .visualMagnitude)
//        let absoluteMagnitude = try container.decode(Double.self, forKey: .absoluteMagnitude)
//        
//        self.luminosity = Value(luminosity, .W)
//        self.visualMagnitude = Value(visualMagnitude)
//        self.absoluteMagnitude = Value(absoluteMagnitude)
//        
//        let systemVelocity = try? container.decode(Double.self, forKey: .systemVelocity)
//        let massConversionRate = try? container.decode(Double.self, forKey: .massConversionRate)
//        
//        self.systemVelocity = Value(systemVelocity, .km / .s)
//        self.massConversionRate = Value(massConversionRate, .kg / .s)
//        
//        try super.init(from: decoder)
//    }
//}
