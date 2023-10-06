//
//  ObjectBody.swift
//  Planetaria
//
//  Created by Joe Rupertus on 1/15/23.
//

import SwiftUI
#if os(macOS)
import AppKit
#endif
import SceneKit
import PlanetariaData

#if os(macOS)
struct ObjectBody: NSViewRepresentable {
    
    var scene: SCNScene
    var view = SCNView()

    var viewPitch: Angle
    var viewRotation: Angle

    var object: ObjectNode

    var simulation: Bool

    init(object: ObjectNode, pitch: Angle, rotation: Angle, simulation: Bool) {
        self.scene = simulation ? object.dynamicModel.scene : object.staticModel.scene
        self.viewPitch = pitch
        self.viewRotation = rotation
        self.object = object
        self.simulation = simulation
    }

    func makeNSView(context: Context) -> SCNView {
        let camera = SCNNode.cameraNode
        scene.rootNode.addChildNode(camera)
        view.pointOfView = camera
        view.autoenablesDefaultLighting = true
        view.backgroundColor = NSColor.clear
        scene.rotateBody(object, viewRotation: viewRotation, viewPitch: viewPitch)
        view.scene = scene
        return view
    }

    func updateNSView(_ nsView: SCNView, context: Context) {
        guard simulation, let scene = nsView.scene else { return }
        scene.rotateBody(object, viewRotation: viewRotation, viewPitch: viewPitch)
        scene.setLightPosition(object, viewRotation: viewRotation, viewPitch: viewPitch)
    }
}
#elseif os(iOS) || os(tvOS)
struct ObjectBody: UIViewRepresentable {

    var scene: SCNScene
    var view = SCNView()

    var viewPitch: Angle = .zero
    var viewRotation: Angle = .zero

    var object: ObjectNode
    
    var simulation: Bool

    init(object: ObjectNode, pitch: Angle, rotation: Angle, simulation: Bool) {
        self.scene = simulation ? object.dynamicModel.scene : object.staticModel.scene
        self.viewPitch = pitch
        self.viewRotation = rotation
        self.object = object
        self.simulation = simulation
    }

    func makeUIView(context: Context) -> SCNView {
        let camera = SCNNode.cameraNode
        scene.rootNode.addChildNode(camera)
        view.pointOfView = camera
        if simulation {
            scene.rootNode.addChildNode(SCNNode.lightNode)
            scene.rootNode.addChildNode(SCNNode.ambientLightNode)
        } else {
            view.autoenablesDefaultLighting = true
        }
        view.backgroundColor = UIColor.clear
        view.scene = scene
        if simulation {
            scene.rotateBody(object, viewRotation: viewRotation, viewPitch: viewPitch)
            scene.setLightPosition(object, viewRotation: viewRotation, viewPitch: viewPitch)
        } else {
            scene.rotatePreview(object)
        }
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        guard simulation, let scene = uiView.scene else { return }
        scene.rotateBody(object, viewRotation: viewRotation, viewPitch: viewPitch)
        scene.setLightPosition(object, viewRotation: viewRotation, viewPitch: viewPitch)
    }
}
#endif

extension SCNScene {

    func rotateBody(_ object: ObjectNode, viewRotation: Angle, viewPitch: Angle) {
        if let node = rootNode.childNode(withName: "body", recursively: true) {

            // Reset the rotation
            node.rotation = .init()

            // Tilt the object to its correct rotational axis
            let tilt = object.poleDirection.angle(with: Vector.referencePlane)
            node.rotate(by: .radians(tilt), around: vector(coordinates: object.poleDirection.cross(Vector.referencePlane).unitVector))

            // Align the lat/lon surface origin (0,0) vectors
            let equator = Vector.vernalEquinox.rotated(by: -tilt, about: object.poleDirection.cross(Vector.referencePlane).unitVector)
            let primeMeridian = Vector.vernalEquinox.rotated(by: Double.pi/2 + object.poleRA, about: Vector.celestialPole)
            node.rotate(by: .radians(primeMeridian.signedAngle(with: equator, around: object.poleDirection, clockwise: true)), around: vector(coordinates: object.poleDirection))

            // Rotate about the rotational axis by the current rotation angle
            node.rotate(by: -.radians(object.rotation), around: vector(coordinates: object.poleDirection))

            // Rotate by the view angles
            node.rotate(by: viewRotation, around: vector(coordinates: Vector.referencePlane))
            node.rotate(by: -viewPitch, around: vector(coordinates: Vector.vernalEquinox))
        }
    }
    
    func rotatePreview(_ object: ObjectNode) {
        if let node = rootNode.childNode(withName: "body", recursively: true) {
            
            // Reset the rotation
            node.rotation = .init()
            
            // Rotate to the front of the object
            node.rotate(by: .degrees(75), around: vector(coordinates: .e1))
        }
    }
    
    func setLightPosition(_ object: ObjectNode, viewRotation: Angle, viewPitch: Angle) {
        if let node = rootNode.childNode(withName: "light", recursively: true) {
            node.position = vector(coordinates: 10 * object.globalPosition.unitVector.negative.rotated(by: -viewRotation.radians, about: .e3).rotated(by: viewPitch.radians, about: .e1))
        }
    }

    // Helper Methods

    func vector(coordinates: [Double]) -> SCNVector3 {
        return SCNVector3(-coordinates.y, coordinates.z, -coordinates.x)
    }
    func orientation(rotation: Angle, pitch: Angle) -> SCNVector3 {
        return SCNVector3(0, -rotation.radians, -pitch.radians)
    }
}

extension SCNNode {
    
    static var cameraNode: SCNNode {
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 10 * 1.2, 0)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        camera.fieldOfView = atan(1/10) * 360 / .pi
        return cameraNode
    }
    static var lightNode: SCNNode {
        let light = SCNLight()
        let lightNode = SCNNode()
        lightNode.name = "light"
        lightNode.light = light
        light.intensity = 300
        return lightNode
    }
    static var ambientLightNode: SCNNode {
        let light = SCNLight()
        let lightNode = SCNNode()
        lightNode.name = "ambientLight"
        lightNode.light = light
        light.type = .ambient
        light.intensity = 50
        return lightNode
    }
    
    func rotate(by angle: Angle, around axis: SCNVector3) {
        #if os(macOS)
        let rotation = SCNMatrix4MakeRotation(CGFloat(-angle.radians), axis.x, axis.y, axis.z)
        #else
        let rotation = SCNMatrix4MakeRotation(Float(-angle.radians), axis.x, axis.y, axis.z)
        #endif
        let rotatedTransform = SCNMatrix4Mult(self.transform, rotation)
        self.transform = rotatedTransform
    }
}
