////
////  ARViewContainer.swift
////  Planetaria
////
////  Created by Joe Rupertus on 1/10/23.
////
//
//import Foundation
//import SwiftUI
//import RealityKit
//
//struct ARViewContainer: UIViewRepresentable {
//    
//    var objects: [Object]
//    var createEntity: (Object) -> [Entity]
//
//    func makeUIView(context: Context) -> ARView {
//        ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: true)
//    }
//
//    func updateUIView(_ uiView: ARView, context: Context) {
//        updateAR(uiView: uiView)
//    }
//    
//    private func updateAR(uiView: ARView) {
//        
//        uiView.scene.anchors.removeAll()
//        
//        for object in objects {
//            uiView.scene.addAnchor(createAnchor(for: object))
//        }
//    }
//    
//    private func createAnchor(for object: Object) -> AnchorEntity {
//        
//        let anchor = AnchorEntity(world: .zero)
//        
//        for entity in createEntity(object) {
//            anchor.addChild(entity)
//        }
//
//        return anchor
//    }
//}
//
////struct ARViewContainer: UIViewRepresentable {
////
////    var view = ARView()
////
////    var objects: [Object]
////
////    var createEntity: (Object) -> [Entity]
////    var frame: CGSize
////    var onTapGesture: ((Entity) -> ())? = nil
////
////    func makeUIView(context: Context) -> ARView {
////
////        // Add gesture recognizer
////        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
////        view.addGestureRecognizer(tapGesture)
////
////        view.frame = CGRect(origin: .zero, size: frame)
////        return view
////    }
////
////    func updateUIView(_ uiView: ARView, context: Context) {
////        updateAR(uiView: uiView)
////    }
////
////    private func updateAR(uiView: ARView) {
////
////        uiView.scene.anchors.removeAll()
////
////        for object in objects {
////            uiView.scene.addAnchor(createAnchor(for: object))
////        }
////    }
////
////    func makeCoordinator() -> Coordinator {
////        Coordinator(view, onTapGesture)
////    }
////
////    private func createAnchor(for object: Object) -> AnchorEntity {
////
////        let anchor = AnchorEntity(world: .zero)
////
////        for entity in createEntity(object) {
////            anchor.addChild(entity)
////        }
////
////        if object is Star {
////            let light = PointLightComponent(color: .white)
////            anchor.components.set(light)
////        }
////
////        return anchor
////    }
////
////    class Coordinator: NSObject {
////
////        private let view: ARView
////
////        private let onTapGesture: ((Entity) -> ())?
////
////        init(_ view: ARView, _ onTapGesture: ((Entity) -> ())?) {
////            self.view = view
////            self.onTapGesture = onTapGesture
////            super.init()
////        }
////
////        @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
////
////            guard let onTapGesture else { return }
////
////            // Find where was tapped
////            let location = gestureRecognize.location(in: view)
////            let hitResults = view.hitTest(location)
////
////            // Found a hit
////            if let result = hitResults.first {
////
////                // Handle the tap gesture
////                onTapGesture(result.entity)
////            }
////        }
////    }
////}
