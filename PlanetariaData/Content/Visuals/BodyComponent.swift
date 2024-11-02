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
    
    private var light: Entity?
    private var lightResource: EnvironmentResource?
    private var lightEnabled: Bool = true
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
        #if os(visionOS)
        Task {
            self.lightResource = try? await EnvironmentResource(named: "light")
        }
        #endif
        if #available(iOS 18.0, macOS 15.0, visionOS 2.0, *) {
            if body.luminosity > 0 {
                let lightComponent = PointLightComponent(color: .white, intensity: Self.intensity, attenuationRadius: Self.attenuationRadius, attenuationFalloffExponent: 0)
                let light = Entity()
                self.light = light
                light.components.set(lightComponent)
                model.addChild(light)
            }
        }
    }
    
    func update(isEnabled: Bool, scale: Double, orientation: simd_quatf, lightEnabled: Bool) {
        model.isEnabled = isEnabled
        model.scale = SIMD3(repeating: Float(diameter * scale))
        model.orientation = orientation * self.orientation(rotation)
        if self.lightEnabled != lightEnabled {
            setLighting(enabled: lightEnabled)
        }
    }
    
    private func orientation(_ rotation: Node.Rotation?) -> simd_quatf {
        guard let rotation else { return .identity }
        
        let angle = rotation.angle
        if let axis = rotation.axis {
            
            let tilt = axis.angle(with: .referencePlane)
            
            // Tilt the object to its correct rotational axis
            let q1 = simd_quatf(angle: Float(-tilt), axis: cross(axis, .referencePlane).unitVector.toFloat())
            
            // Rotate about the rotational axis to align the lat/lon surface origin (0,0) vectors
            let equator = Vector3.vernalEquinox.rotated(by: -tilt, about: cross(axis, .referencePlane).unitVector)
            let primeMeridian = Vector3.vernalEquinox.rotated(by: axis.ra, about: .celestialPole)
            let q2 = simd_quatf(angle: Float(primeMeridian.signedAngle(with: equator, around: axis, clockwise: true) + angle), axis: axis.toFloat())
            
            return q2 * q1
            
        } else {
            
            // Rotate about the reference plane
            return simd_quatf(angle: Float(angle), axis: Vector3.referencePlane.toFloat())
            
        }
    }
    
    private func setLighting(enabled: Bool) {
        lightEnabled = enabled
        light?.isEnabled = enabled
        
        // Flood lights
        #if os(visionOS)
        if !enabled {
            Task {
                guard let lightResource else { return }
                await model.components.set(ImageBasedLightComponent(source: .single(lightResource), intensityExponent: 0))
                await model.components.set(ImageBasedLightReceiverComponent(imageBasedLight: model))
            }
        } else {
            model.components.remove(ImageBasedLightComponent.self)
            model.components.remove(ImageBasedLightReceiverComponent.self)
        }
        #endif
    }
}
