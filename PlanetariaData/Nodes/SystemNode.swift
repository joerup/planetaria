//
//  SystemNode.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 8/9/23.
//

import Foundation
import SwiftUI

public class SystemNode: Node {
    
    public let childSystems: [SystemNode]
    public let childObjects: [ObjectNode]
    public let children: [Node]
    
    public var tree: [Node] {
        [self] + subtree
    }
    private var subtree: [Node] {
        children + childSystems.map(\.subtree).reduce([], +)
    }
    
    override public var system: SystemNode? {
        self
    }
    override public var object: ObjectNode? {
        childObjects.first
    }
    
    public private(set) var primaryCategory: Node.Category?
    public private(set) var secondaryCategory: Node.Category?
    
    public func children(type: Category?) -> [ObjectNode] {
        guard let type else { return [] }
        return children.compactMap(\.object).filter { $0.category == type }
    }
    public func children(types: [Category]) -> [ObjectNode] {
        return children.compactMap(\.object).filter { types.contains($0.category) }
    }
    
    public var hasCentralObject: Bool {
        (object?.size ?? 0) > (object?.position.magnitude ?? 0)
    }
    
    public var centerOfMass: Vector3 {
        return children.map({ $0.mass * $0.position }).reduce(.zero, +) / mass
    }
    public var centerOfMassVelocity: Vector3 {
        return children.map({ $0.mass * $0.velocity }).reduce(.zero, +) / mass
    }
    
    private(set) var systemTimeStep: Double = 1.0
    
    override public var color: Color? {
        get { return object?.color } set { }
    }
    
    public var scaleDistance: Double {
        guard let child = children.max(by: { $0.position.magnitude < $1.position.magnitude }) else { return 0 }
        return child.position.magnitude
    }
    public var primaryScaleDistance: Double {
        guard let child = children.filter({ $0.rank == .primary }).max(by: { $0.position.magnitude < $1.position.magnitude }) else { return 0 }
        return child.position.magnitude
    }
    
    private enum CodingKeys: String, CodingKey {
        case systems, objects
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.childSystems = (try? container.decode([SystemNode].self, forKey: .systems)) ?? []
        self.childObjects = (try? container.decode([ObjectNode].self, forKey: .objects)) ?? []
        self.children = childSystems + childObjects
        
        try super.init(from: decoder)
        
        self.primaryCategory = childObjects.first?.category
        self.secondaryCategory = childObjects.map(\.category).first(where: { $0 != primaryCategory })
        
        self.mass = children.map(\.mass).reduce(0, +)
        self.size = 0
        
        for child in children {
            child.parent = self
        }
        for child in children {
            if child == object {
                child.hostNode = childObjects.filter({ $0 != child && $0.mass >= 0.01 * child.mass }).max(by: { $0.mass < $1.mass })
            } else {
                child.hostNode = object
            }
        }
    }
    
    override internal func setOrbitAndRotation(time: Date) {
        super.setOrbitAndRotation(time: time)
        object?.properties?.orbit = orbit
    }
    
    internal func setStep() {
        // find the min timestep in the system
        var minStep = children.filter({ $0 != object }).compactMap(\.timeStep).min() ?? 1.0
        
        // set the host object's timestep since it wasn't able to set before this
        if let object, object.timeStep == 0 {
            object.timeStep = minStep
            object.period = minStep / Self.timeStepFraction
        }
        
        // decrease timesteps for binary systems because they are prone to larger error
        if children.contains(where: { object?.hostNode == $0 }) {
            minStep /= 10
            for child in children {
                child.timeStep /= 10
            }
        }
        
        // set the system timestep and recursively set for sub-systems
        systemTimeStep = minStep
        for system in childSystems {
            system.setStep()
        }
    }
    
    public var totalEnergy: Double {
        return childSystems.map(\.totalEnergy).reduce(0, +) + childObjects.map(objectEnergy(_:)).reduce(0, +)
    }
    private func objectEnergy(_ object: ObjectNode) -> Double {
        1/2 * object.mass * pow(object.velocity.magnitude, 2) - G * (object.hostNode?.mass ?? 1) * object.mass / object.position.magnitude
    }
}
