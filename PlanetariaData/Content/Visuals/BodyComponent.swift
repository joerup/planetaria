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
    
    private let name: String
    private let node: Node
    private let diameter: Double
    private let rotation: Node.Rotation?
    
    private var light: Entity?
    private var lightEnabled: Bool = true
    static let intensity: Float = 5E4
    static let attenuationRadius: Float = 1E+20
    
    private static let defaultModel = makeDefaultModel()
    
    init?(node: Node, size: Double) {
        guard let body = node as? ObjectNode else { return nil }
        
        self.name = node.name
        self.node = node
        
        // Get the usdz filename to load from
        let fileName: String =
        if #available(iOS 18.0, macOS 15.0, visionOS 2.0, *) {
            node.name
        } else {
            // use old Earth model for older versions
            node.name == "Earth" ? node.name+"-old" : node.name
        }
        
        var bodyEntity: Entity
        if let entity = try? ModelEntity.load(named: fileName) {
            bodyEntity = entity
        } else {
            bodyEntity = ModelEntity(components: [Self.defaultModel])
        }
        self.model = bodyEntity
        
        self.diameter = (body.size == 0 ? 100 : 2 * body.totalSize) / size
        self.rotation = body.rotation
        
        // Light it up
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
        guard isEnabled else { return }
        
        let bodyOrientation = self.orientation(rotation)
        
        model.scale = SIMD3(repeating: Float(diameter * scale))
        model.orientation = orientation * bodyOrientation
        
        #if os(visionOS)
        if self.lightEnabled != lightEnabled {
            setLighting(enabled: lightEnabled)
        }
        #endif
        if #available(iOS 18.0, macOS 15.0, visionOS 2.0, *), name == "Earth", let system = node.system {
            if lightEnabled {
                let totalRotation = simd_quatf(angle: .pi/2, axis: [0,1,0]) * bodyOrientation.inverse
                model.setSunPosition(totalRotation.act(system.position.unitVector.toFloat()))
            } else {
                model.setSunPosition(.zero)
            }
        }
    }
    
    private func orientation(_ rotation: Node.Rotation?) -> simd_quatf {
        guard let rotation else { return .identity }
        
        let angle = rotation.angle.truncatingRemainder(dividingBy: 2 * .pi)
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
    
    private static func makeDefaultModel() -> ModelComponent {
        let mesh = MeshResource.generateSphere(radius: 0.5)
        let material = SimpleMaterial(color: ColorType(.init(white: 0.2)), roughness: .float(1), isMetallic: false)
        return ModelComponent(mesh: mesh, materials: [material])
    }
    
    #if os(visionOS)
    private func setLighting(enabled: Bool) {
        lightEnabled = enabled
        light?.isEnabled = enabled
        
        // Flood lights
        if !enabled {
            Task {
                var lightResource = Self.lightResource
                if lightResource == nil {
                    lightResource = await Self.getEnvironmentResource()
                }
                guard let lightResource else { return }
                await model.components.set(ImageBasedLightComponent(source: .single(lightResource), intensityExponent: 0))
                await model.components.set(ImageBasedLightReceiverComponent(imageBasedLight: model))
            }
        } else {
            model.components.remove(ImageBasedLightComponent.self)
            model.components.remove(ImageBasedLightReceiverComponent.self)
        }
    }
    private static let lightResource: EnvironmentResource? = nil
    private static func getEnvironmentResource() async -> EnvironmentResource? {
        return try? await EnvironmentResource(named: "light")
    }
    #endif
}
