//
//  BodyComponent.swift
//  
//
//  Created by Joe Rupertus on 1/9/24.
//

import RealityKit

class BodyComponent: Component {
    
    var model: Entity
    
    private var diameter: Double
    
    init?(node: Node, size: Double) {
        guard let body = node as? Object, let bodyEntity = try? ModelEntity.load(named: node.name) else { return nil }
        
        self.model = bodyEntity
        self.diameter = 2 * body.totalSize / size
            
        let collisionShape = ShapeResource.generateSphere(radius: bodyEntity.visualBounds(relativeTo: bodyEntity).boundingRadius/2)
        bodyEntity.components.set(CollisionComponent(shapes: [collisionShape]))
        #if os(visionOS)
        bodyEntity.components.set(InputTargetComponent())
        #endif
        bodyEntity.scale = SIMD3(repeating: Float(size))
        bodyEntity.orientation = orientation(body.rotation)
    }
    
    func update(scale: Double, duration: Double) {
        let scale = SIMD3(repeating: Float(diameter * scale))
        
        if duration == 0 {
            model.position = .zero
            model.scale = scale
        } else {
            let transform = Transform(scale: scale, rotation: model.orientation, translation: model.position)
            model.move(to: transform, relativeTo: model.parent, duration: duration, timingFunction: .easeInOut)
        }
    }
    
    private func orientation(_ rotation: Rotation?) -> simd_quatf {
        let angle = rotation?.angle ?? .zero
        let axis = rotation?.axis ?? .referencePlane
        let tilt = axis.angle(with: .referencePlane)

        // Tilt the object to its correct rotational axis
        let q1 = simd_quatf(angle: Float(-tilt), axis: axis.cross(.referencePlane).unitVector.simdf)

        // Align the lat/lon surface origin (0,0) vectors
        let equator = Vector.vernalEquinox.rotated(by: -tilt, about: axis.cross(.referencePlane).unitVector)
        let primeMeridian = Vector.vernalEquinox.rotated(by: .pi/2 + axis.ra, about: .celestialPole)
        let q2 = simd_quatf(angle: Float(primeMeridian.signedAngle(with: equator, around: axis, clockwise: true) + angle), axis: axis.simdf)

        return q2 * q1
    }
}
