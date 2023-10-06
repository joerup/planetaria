//
//  Object3D.swift
//  Planetaria
//
//  Created by Joe Rupertus on 1/15/23.
//

import SwiftUI
import SceneKit
import PlanetariaData

struct Object3D: UIViewRepresentable {

    var scene: SCNScene
    var view = SCNView()

    var viewPitch: Angle
    var viewRotation: Angle

    var object: ObjectNode

    var simulation: Bool

    let distance: CGFloat = 10

    // Static Model
    init(_ object: ObjectNode) {
        self.scene = object.staticModel.scene
        self.viewPitch = .degrees(-70)
        self.viewRotation = .degrees(0)
        self.object = object
        self.simulation = false
    }
    // Dynamic Model
    init(_ object: ObjectNode, pitch: Angle, rotation: Angle) {
        self.scene = object.dynamicModel.scene
        self.viewPitch = pitch
        self.viewRotation = rotation
        self.object = object
        self.simulation = true
    }
//    init(_ scene: SCNScene) {
//        self.scene = scene
//        self.viewPitch = .zero
//        self.viewRotation = .zero
//        self.object = Spacetime.shared.systems.first!.firstObject
//        self.simulation = true
//    }

    func makeUIView(context: Context) -> SCNView {

        // Camera
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, distance * 1.2, 0)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        camera.fieldOfView = atan(1/distance) * 360 / .pi

        scene.rootNode.addChildNode(cameraNode)
        view.pointOfView = cameraNode

//        // Lighting
//        if simulation {
//
//            // Create the light node
//            let light = SCNLight()
//            let lightNode = SCNNode()
//            lightNode.name = "light"
//            lightNode.light = light
//            light.intensity = 5E+6
//
//            // Create the ambient light node
//            let ambientLight = SCNLight()
//            let ambientNode = SCNNode()
//            ambientNode.name = "ambient"
//            ambientNode.light = ambientLight
//            ambientLight.intensity = 20
//            ambientLight.type = .ambient
//
//            scene.rootNode.addChildNode(lightNode)
//            scene.rootNode.addChildNode(ambientNode)
//
//        }
//        else {
//
//            // Use default lighting
            view.autoenablesDefaultLighting = true
//        }

        // Alignment Lines
//        if let node = scene.rootNode.childNode(withName: "body", recursively: true) {
//            node.addChildNode(createAlignmentLine(.z, positive: true, color: .blue))
//            node.addChildNode(createAlignmentLine(.z, positive: false, color: .cyan))
//            node.addChildNode(createAlignmentLine(.x, positive: true, color: .red))
//            node.addChildNode(createAlignmentLine(.x, positive: false, color: .magenta))
//            node.addChildNode(createAlignmentLine(.y, positive: true, color: .gray))
//            node.addChildNode(createAlignmentLine(.y, positive: false, color: .gray))
//        }

        // Scene
        scene.rotateBody(object, viewRotation: viewRotation, viewPitch: viewPitch)

        view.backgroundColor = UIColor.clear
        view.scene = scene

        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        guard simulation, let scene = uiView.scene else { return }

        scene.rotateBody(object, viewRotation: viewRotation, viewPitch: viewPitch)
        scene.setLightPosition(object, viewRotation: viewRotation, viewPitch: viewPitch)
    }

    func createAlignmentLine(_ side: Side, positive: Bool?, color: UIColor, name: String? = nil) -> SCNNode {
        let geometry = SCNBox(width: side == .y ? 1200 : 2, height: side == .z ? 1200 : 2, length: side == .x ? 1200 : 2, chamferRadius: 0)
        geometry.firstMaterial?.diffuse.contents = color
        let axis = SCNNode(geometry: geometry)
        let offset: Float = positive == nil ? 0 : positive! ? 500 : -500
        axis.position = SCNVector3(x: side == .y ? offset : 0, y: side == .z ? offset : 0, z: side == .x ? -offset : 0)
        axis.name = name ?? "\((positive ?? true) ? "+" : "-")\(side.rawValue)"
        return axis
    }
    enum Side: String {
        case x
        case y
        case z
    }
}

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
//            print("\(object.name) \((90+(object.poleRA?[.deg] ?? 0)).truncatingRemainder(dividingBy: 360)) \(primeMeridian.signedAngle(with: Vector.vernalEquinox, around: Vector.celestialPole, clockwise: false).truncatingRemainder(dividingBy: 2 * .pi) * 180 / .pi) \(equator.angle(with: object.rotationAxisDirection)) \(primeMeridian.angle(with: object.rotationAxisDirection))")

            // Rotate about the rotational axis by the current rotation angle
            node.rotate(by: -.radians(object.rotation), around: vector(coordinates: object.poleDirection))

            // Rotate by the view angles
            node.rotate(by: viewRotation, around: vector(coordinates: Vector.referencePlane))
            node.rotate(by: -viewPitch, around: vector(coordinates: Vector.vernalEquinox))
        }
    }
    
    func setLightPosition(_ object: ObjectNode, viewRotation: Angle, viewPitch: Angle) {
//        if let node = rootNode.childNode(withName: "light", recursively: true) {
//            node.position = vector(coordinates: 1000 * object.position.unitVector.negative.rotated(by: -viewRotation.radians, about: Vector.vernalEquinox).rotated(by: viewPitch.radians, about: Vector.referencePlane))
//        }
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
    func rotate(by angle: Angle, around axis: SCNVector3) {
        let rotation = SCNMatrix4MakeRotation(Float(-angle.radians), axis.x, axis.y, axis.z)
        let rotatedTransform = SCNMatrix4Mult(self.transform, rotation)
        self.transform = rotatedTransform
    }
}
