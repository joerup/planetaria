//
//  BodyComponent.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 1/9/24.
//

import RealityKit
import SwiftUI

// The physical body of an object
class BodyComponent: Component {
    
    var model: Entity
    
    private var diameter: Double
    private var rotation: Node.Rotation?
    
    static let intensity: Float = 7E4
    static let attenuationRadius: Float = 1E+20
    
    init?(node: Node, size: Double) {
        guard let body = node as? ObjectNode else { return nil }
        
        var bodyEntity: Entity
        if let entity = try? ModelEntity.load(named: node.name) {
            bodyEntity = entity
        } else {
            let mesh = MeshResource.generateSphere(radius: 0.5)
            let material = UnlitMaterial(color: ColorType(node.color ?? .gray))
            bodyEntity = ModelEntity(mesh: mesh, materials: [material])
        }
        
        self.model = bodyEntity
        self.diameter = 2 * body.totalSize / size
        self.rotation = body.rotation
        
        // Light it up
        if #available(iOS 18.0, macOS 15.0, visionOS 2.0, *), body.luminosity > 0 {
            let light = PointLightComponent(color: .white, intensity: Self.intensity, attenuationRadius: Self.attenuationRadius, attenuationFalloffExponent: 0)
            model.components.set(light)
        }
    }
    
    func update(isEnabled: Bool, scale: Double, orientation: simd_quatf) {
        model.isEnabled = isEnabled
        model.scale = SIMD3(repeating: Float(diameter * scale))
        model.orientation = orientation * self.orientation(rotation)
    }
    
    private func orientation(_ rotation: Node.Rotation?) -> simd_quatf {
        guard let rotation else { return .identity }
        
        let angle = rotation.angle
        let axis = rotation.axis ?? .referencePlane
        let tilt = axis.angle(with: .referencePlane)
        
        // Tilt the object to its correct rotational axis
        let q1 = simd_quatf(angle: Float(-tilt), axis: cross(axis, .referencePlane).unitVector.toFloat())
        
        // Rotate about the rotational axis to align the lat/lon surface origin (0,0) vectors
        let equator = Vector3.vernalEquinox.rotated(by: -tilt, about: cross(axis, .referencePlane).unitVector)
        let primeMeridian = Vector3.vernalEquinox.rotated(by: axis.ra, about: .celestialPole)
        let q2 = simd_quatf(angle: Float(primeMeridian.signedAngle(with: equator, around: axis, clockwise: true) + angle), axis: axis.toFloat())
        
        return q2 * q1
    }
}
