//
//  ObjectBodyAR.swift
//  
//
//  Created by Joe Rupertus on 8/16/23.
//

import SwiftUI
#if canImport(RealityKit)
import RealityKit
#endif
import PlanetariaData

#if os(iOS)
struct ObjectBodyAR: UIViewRepresentable {
    
    var object: Object
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .init(x: 1, y: 1, width: 1, height: 1))
        
        arView.environment.background = .color(.clear)
        
        let anchor = AnchorEntity()
        
//        let sphere = MeshResource.generateSphere(radius: 1)
//        let material = SimpleMaterial(color: .blue, isMetallic: false)
//        let sphereEntity = ModelEntity(mesh: sphere, materials: [material])
//        anchor.addChild(sphereEntity)
//        arView.scene.anchors.append(anchor)
        
        // Load and display the USDZ model
        if let modelEntity = try? ModelEntity.load(named: "\(object.name).usdz") {
            anchor.addChild(modelEntity)
            arView.scene.anchors.append(anchor)
            
            let cameraAnchor = AnchorEntity(.camera)
            cameraAnchor.addChild(modelEntity)
            arView.scene.addAnchor(cameraAnchor)
            
            modelEntity.transform.scale = SIMD3(repeating: 7 * 0.001)
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
        print("hey guys were updating the model")
    }
}
#endif
