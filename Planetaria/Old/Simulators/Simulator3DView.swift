////
////  SceneSimulator.swift
////  Planetaria
////
////  Created by Joe Rupertus on 1/8/23.
////
//
//import SwiftUI
//import SceneKit
//
//struct Simulator3DView: View {
//    
//    private var objects: [Object] {
//        return selectedSystem?.primaryObjects ?? []
//    }
//    
//    // Center the simulation on the first object
//    private var centerPosition: [Double] {
//        return objects.first?.position ?? [0,0,0]
//    }
//    
//    private let scaleFactor = 1E+7
//    
//    @Binding var selectedSystem: System?
//    @Binding var selectedObject: Object?
//    
//    private var fullSimulation: Bool
//    private var backgroundColor: UIColor
//    
//    private var scene: SCNScene?
//    private var camera: SCNNode?
//    
//    init(selectedSystem: Binding<System?>, selectedObject: Binding<Object?>, backgroundColor: UIColor = .black) {
//        self._selectedSystem = selectedSystem
//        self._selectedObject = selectedObject
//        self.fullSimulation = true
//        self.backgroundColor = backgroundColor
//        self.scene = makeScene()
//        self.camera = setUpCamera()
//    }
//    init(object: Object, backgroundColor: UIColor = .black) {
//        self._selectedSystem = .constant(object.soloSystem)
//        self._selectedObject = .constant(object)
//        self.fullSimulation = false
//        self.backgroundColor = backgroundColor
//        self.scene = makeScene()
//        self.camera = setUpCamera()
//    }
//    
//    
//    var body: some View {
//        Text("no")
////        Object3DView(scene!)
//    }
//    
//    private func makeScene() -> SCNScene {
//        let scene = SCNScene()
//    
//        // Sky
//        if fullSimulation {
//            let skyboxImages = (1...6).map { UIImage(named: "skybox\($0)") }
//            scene.background.contents = skyboxImages
//        } 
//        
//        // Objects
//        for object in objects {
//            makeObjectNodes(for: object).forEach { scene.rootNode.addChildNode($0) }
//        }
//        
//        return scene
//    }
//    
//    private func setUpCamera() -> SCNNode {
//        
//        // Set up the camera
//        let camera = SCNNode()
//        camera.camera = SCNCamera()
//        camera.camera?.automaticallyAdjustsZRange = true
//        camera.camera?.zFar = 5000
//        
//        if let selectedObject, objects.count == 1 {
//            let distance: Double = -sizeScale(for: selectedObject) * selectedObject.safeDistance * 2
//            let scale: Double = fullSimulation ? 5 : 2
//            camera.position = SCNVector3(scale*distance, scale, 0)
//            camera.eulerAngles = SCNVector3(atan(1/Float(distance)), -Float.pi/2, 0)
//            camera.camera?.fieldOfView = 30
//        } else {
//            camera.position = SCNVector3(0, 250, 0)
//            camera.eulerAngles = SCNVector3(-Float.pi/2, 0, 0)
//        }
//        
//        // Add the camera to the scene
//        scene?.rootNode.addChildNode(camera)
//        
//        return camera
//    }
//    
//    private func onTapGesture(_ node: SCNNode?) throws {
//        
//        try withAnimation {
//            
//            for node in (scene?.rootNode.childNodes(passingTest: { node, _ in node.name?.contains("Orbital Path") ?? false }) ?? []) {
//                node.geometry?.firstMaterial?.diffuse.contents = UIColor(.init(white: 0.3))
//            }
//            
//            guard let node, let object = objects.first(where: { $0.name == node.name }), fullSimulation else {
//                selectedObject = nil
//                throw SceneError.notObject
//            }
//            
//            if selectedObject == object {
//                selectedObject = nil
//            } else {
//                selectedObject = object
//                if let node = scene?.rootNode.childNode(withName: "\(object.name) Orbital Path", recursively: false) {
//                    node.geometry?.firstMaterial?.diffuse.contents = UIColor(object.associatedColor)
//                }
//            }
//            
//            print("\(object.name) has been tapped!")
//        }
//    }
//    
//    private func makeObjectNodes(for object: Object) -> [SCNNode] {
//        
//        let nodes: [SCNNode] = []
//        
////        // Visuals
////        for visual in object.allVisuals {
////
////            let scale = sizeScale(for: object)
////
////            // Shape
////            var geometry: SCNGeometry
////            switch visual.shape {
////            case .sphere(let radius):
////                let sphere = SCNSphere(radius: radius*scale)
////                sphere.segmentCount = 96
////                geometry = sphere
////            case .ball(let meanRadius, _):
////                let sphere = SCNSphere(radius: meanRadius*scale)
////                sphere.segmentCount = 96
////                geometry = sphere
////            case .ellipsoid(let rx, _, let rz):
////                geometry = SCNCapsule(capRadius: rx*scale, height: 2*rz*scale)
////            case .ring(let innerRadius, let outerRadius, let thickness):
////                geometry = SCNTube(innerRadius: innerRadius*scale, outerRadius: outerRadius*scale, height: thickness*scale)
////            }
////
////            // Texture
////            var texture: Any?
////            switch visual.texture {
////            case .image(let name):
////                texture = UIImage(named: name)
////            case .solidColor(let rgb):
////                texture = UIColor(red: rgb[0], green: rgb[1], blue: rgb[2], alpha: rgb.count > 3 ? rgb[3] : 1)
////            }
////            geometry.firstMaterial?.diffuse.contents = texture
////
////            // Node
////            let node = SCNNode(geometry: geometry)
////            node.name = visual.name
////            node.position = self.position(for: object)
////            nodes.append(node)
////        }
////
////        // Orbital Path
////        if fullSimulation {
////
////            // Path Shape
////            let geometry = SCNTube(innerRadius: object.distance(to: centerPosition) / scaleFactor, outerRadius: object.distance(to: centerPosition) / scaleFactor + 1, height: 1)
////            geometry.firstMaterial?.diffuse.contents = UIColor(selectedObject == object ? object.associatedColor : .init(white: 0.3))
////            geometry.radialSegmentCount = 96
////
////            // Node
////            let node = SCNNode(geometry: geometry)
////            node.name = "\(object.name) Orbital Path"
////            node.position = SCNVector3(0,0,0)
////            nodes.append(node)
////        }
//            
//        return nodes
//    }
//    
//    private let scale: Double = 10
//    
//    private func position(for object: Object) -> SCNVector3 {
//        return ((object.position - centerPosition) / scaleFactor).scnVector()
////        let position = object.position - centerPosition
////        let unitVector = position.reduceDim.unitVector
////        guard !unitVector.isNan else { return SCNVector3(0,0,0) }
////        let newVector = unitVector * orbitalRadius(for: object)
////        return newVector.scnVector()
//    }
//    
//    private func sizeScale(for object: Object) -> Double {
//        scale
//    }
//    
//    
//    enum SceneError: Error {
//        case notObject
//    }
//}
