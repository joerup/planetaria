//
//  
// SimulationEntity.swift
//
//
//  Created by Joe Rupertus on 1/5/24.
//

import Foundation
import RealityKit
import UIKit

public class SimulationEntity: Entity {
    
    public private(set) var body: Entity?
    
    @MainActor required init() {
        super.init()
    }
    
    public init(node: Node) async {
        super.init()
        
        self.name = "\(node.id)"
        
        let sphere = MeshResource.generateSphere(radius: 0.005)
        let collisionShape = ShapeResource.generateSphere(radius: 0.005)
        let material = UnlitMaterial(color: UIColor(node.color ?? .gray))
        
        self.components.set(ModelComponent(mesh: sphere, materials: [material]))
        self.components.set(CollisionComponent(shapes: [collisionShape]))
        self.components.set(InputTargetComponent())
        
        // Create the body entity
        if let body = node as? Object, let bodyEntity = try? await ModelEntity(named: body.name) {
            
            let collisionShape = ShapeResource.generateSphere(radius: bodyEntity.visualBounds(relativeTo: bodyEntity).boundingRadius/2)
            
            bodyEntity.components.set(CollisionComponent(shapes: [collisionShape]))
            bodyEntity.components.set(InputTargetComponent())
            bodyEntity.orientation = orientation(body.rotation)
            bodyEntity.name = body.name
            
            await MainActor.run {
                self.body = bodyEntity
            }
        }
    }
    
    public func showBody() {
        if let body, body.parent != self {
            print("loading \(name) body")
            addChild(body)
        }
    }
    
    public func hideBody() {
        if let body, body.parent == self {
            print("hiding \(name) body")
            removeChild(body)
        }
    }
    
    
    // Set a body's default orientation
    
    private func orientation(_ rotation: Rotation?) -> simd_quatf {
        let angle = rotation?.angle ?? .zero
        let axis = rotation?.axis ?? .referencePlane
        let tilt = axis.angle(with: .referencePlane)

        // Tilt the object to its correct rotational axis
        let q1 = simd_quatf(angle: Float(-tilt), axis: axis.cross(.referencePlane).unitVector.simdf)

        // Align the lat/lon surface origin (0,0) vectors
        let equator = Vector.vernalEquinox.rotated(by: -tilt, about: axis.cross(.referencePlane).unitVector)
        let primeMeridian = Vector.vernalEquinox.rotated(by: .pi/2 + axis.ra, about: .celestialPole)
        let q2 = simd_quatf(angle: Float(primeMeridian.signedAngle(with: equator, around: axis, clockwise: true)), axis: axis.simdf)

        // Rotate about the rotational axis by the current rotation angle
        let q3 = simd_quatf(angle: Float(angle), axis: axis.simdf)

        return q1
    }
}
