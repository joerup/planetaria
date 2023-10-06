//
//  ObjectNode.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/9/23.
//

import Foundation

public class ObjectNode: Node {

    public var visual: Visual
    public var staticModel: Model
    public var dynamicModel: Model
    
    public var rotation: Double
    public var poleDirection: Vector
    public var poleRA: Double
    public var poleDec: Double
    public var axialTilt: Double?
    
    internal var rotationRef: Double?
    internal var rotationRate: Double?
    internal var rotationPeriod: Double?
    internal var rotationSpeed: Double?
    
    internal var poleRARef: Double?
    internal var poleRARate: Double?
    internal var poleDecRef: Double?
    internal var poleDecRate: Double?

    public override var object: ObjectNode? {
        return self
    }

    public override var children: [Node] {
        get { return [] }
        set { }
    }

    public override var scaleDistance: Double? {
        return size
    }
    
    public var rotationalElementsAvailable: Bool {
        return rotationRef != nil
    }

    enum CodingKeys: String, CodingKey {
        case name
        case mass
        case size
        case rotationRef
        case rotationRate
        case poleRARef
        case poleRARate
        case poleDecRef
        case poleDecRate
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)

        self.visual = Visual.usdz(name: name)
        self.staticModel = Model(visual: visual)
        self.dynamicModel = Model(visual: visual)
        
        self.rotation = 0
        self.poleDirection = .zero
        self.poleRA = 0
        self.poleDec = 0
        
        self.rotationRef = try? container.decode(Double.self, forKey: .rotationRef)
        self.rotationRate = try? container.decode(Double.self, forKey: .rotationRate)
        self.poleRARef = try? container.decode(Double.self, forKey: .poleRARef)
        self.poleRARate = try? container.decode(Double.self, forKey: .poleRARate)
        self.poleDecRef = try? container.decode(Double.self, forKey: .poleDecRef)
        self.poleDecRate = try? container.decode(Double.self, forKey: .poleDecRate)
        
        try super.init(from: decoder)
        
        self.mass = (try? container.decode(Double.self, forKey: .mass)) ?? 0
        self.size = (try? container.decode(Double.self, forKey: .size)) ?? 1
    }
}
