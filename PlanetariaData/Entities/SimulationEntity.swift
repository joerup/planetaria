//
//  
// SimulationEntity.swift
//
//
//  Created by Joe Rupertus on 1/5/24.
//

import Foundation
import RealityKit
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

class SimulationEntity: Entity {
    
    private(set) var node: Node?
    
    private(set) var body: Entity?
    private(set) var text: Entity?
    private(set) var orbit: Entity?
    
    private var coordinates: Vector = .zero
    private var totalSize: Double = 1.0
    
    @MainActor required init() { }
    
    init(node: Node, size: Double) async {
        self.node = node
        
        super.init()
        
        self.coordinates = node.globalPosition / size
        self.totalSize = 2 * node.totalSize / size
        
        self.name = "\(node.id)"
        
        if node is Object {
            let radius: Float = node.system != nil ? 0.004 : 0.003
            let sphere = MeshResource.generateSphere(radius: radius)
            let collisionShape = ShapeResource.generateSphere(radius: 5 * radius)
            #if os(macOS)
            let material = UnlitMaterial(color: NSColor(node.color ?? .gray))
            #else
            let material = UnlitMaterial(color: UIColor(node.color ?? .gray))
            #endif
            
            self.components.set(ModelComponent(mesh: sphere, materials: [material]))
            self.components.set(CollisionComponent(shapes: [collisionShape]))
            #if os(visionOS)
            self.components.set(InputTargetComponent())
            #endif
        }
        
        self.position = coordinates.simdf
        
        // Create the body
        if let body = node as? Object, let bodyEntity = try? ModelEntity.load(named: body.name) {
            
            let collisionShape = ShapeResource.generateSphere(radius: bodyEntity.visualBounds(relativeTo: bodyEntity).boundingRadius/2)
            
            bodyEntity.components.set(CollisionComponent(shapes: [collisionShape]))
            #if os(visionOS)
            bodyEntity.components.set(InputTargetComponent())
            #endif
            bodyEntity.orientation = orientation(body.rotation)
            bodyEntity.scale = SIMD3(repeating: Float(totalSize))
            
            self.body = bodyEntity
            addChild(bodyEntity)
        }
        
        // Create the orbit
        if let orbit = OrbitEntity(node: node, size: size) {
            self.orbit = orbit
            addChild(orbit)
        }
        
        
//        // Create the text entity
//        let text = MeshResource.generateText(node.name, extrusionDepth: 0, font: .systemFont(ofSize: 0.025), containerFrame: CGRect.zero, alignment: .center, lineBreakMode: .byClipping)
//        let textEntity = Entity()
//        textEntity.components.set(ModelComponent(mesh: text, materials: [UnlitMaterial(color: .white)]))
//        textEntity.position = [0,-0.05,0]
//        textEntity.orientation = simd_quatf(angle: -.pi/2, axis: [1,0,0])
//        
//        self.text = textEntity
//        addChild(textEntity)
    }
    
    func update(scale: Double, offset: Vector, duration: Double) {
        self.animate(position: (coordinates - offset) * scale, duration: duration)
        body?.animate(position: .zero, scale: totalSize * scale, duration: duration)
        orbit?.animateScale(scale: scale, duration: duration)
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
        let q2 = simd_quatf(angle: Float(primeMeridian.signedAngle(with: equator, around: axis, clockwise: true) + angle), axis: axis.simdf)

        return q2 * q1
    }
}


extension Entity {
    
    func animate(position: Vector? = nil, scale: Double? = nil, duration: Double) {
        
        let newPosition = position?.simdf ?? self.position
        let newScale = if let scale { Float(scale) } else { self.scale.max() }
        
        if duration == 0 {
            self.position = newPosition
            self.scale = SIMD3(repeating: newScale)
        } else {
            let transform = Transform(scale: SIMD3(repeating: newScale / self.scale.max()), translation: newPosition - self.position)
            move(to: transform, relativeTo: self, duration: duration, timingFunction: .easeInOut)
        }
    }
    
    func animateScale(scale: Double, duration: Double) {
        
        if duration == 0 {
            self.position = .zero
            self.scale = [Float(scale), 1, Float(scale)]
        } else {
            let transform = Transform(scale: [Float(scale) / self.scale.x, 1, Float(scale) / self.scale.z])
            move(to: transform, relativeTo: self, duration: duration, timingFunction: .easeInOut)
        }
    }
}
