//
//  Simulator2D.swift
//
//
//  Created by Joe Rupertus on 1/7/24.
//

#if os(iOS) || os(macOS) || os(tvOS)
import SwiftUI
import RealityKit

public struct Simulator2D: View {
    
    @ObservedObject private var simulation: Simulation

    public init(from simulation: Simulation) {
        self.simulation = simulation
    }
    
    public var body: some View {
        GeometryReader { geometry in
            RealityView(root: simulation.rootEntity, size: geometry.size, arMode: simulation.arMode, select: simulation.select(_:))
                .simultaneousGesture(panGesture)
                .simultaneousGesture(zoomGesture)
                .ignoresSafeArea()
                .id(simulation.arMode)
        }
    }
    
    private var panGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                simulation.updateRotationGesture(with: value.translation.width)
                simulation.updatePitchGesture(with: value.translation.height)
            }
            .onEnded { value in
                simulation.completeRotationGesture(with: value.translation.width)
                simulation.completePitchGesture(with: value.translation.height)
            }
    }
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                simulation.updateScaleGesture(to: value)
            }
            .onEnded { value in
                simulation.completeScaleGesture(to: value)
            }
    }
}
#endif

#if os(iOS) || os(tvOS)
private struct RealityView: UIViewRepresentable {
    
    let anchor = AnchorEntity()
    var root: Entity
    
    var size: CGSize
    var arMode: Bool
    var select: (Node?) -> Void
    
    private var mode: ARView.CameraMode {
        return arMode ? .ar : .nonAR
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: mode, automaticallyConfigureSession: true)
//        arView.environment.background = .color(.black)
        
        anchor.addChild(root)
        
        anchor.orientation = simd_quatf(angle: .pi/2, axis: SIMD3(1,0,0))
        anchor.scale = [2,2,2] * Float(min(size.width, size.height) / max(size.width, size.height))
        
        context.coordinator.view = arView
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap)))
        
        arView.scene.anchors.append(anchor)
        return arView
    }
    
    func updateUIView(_ arView: ARView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(select: select)
    }
    
    class Coordinator: NSObject {
        
        weak var view: ARView?
        var select: (Node?) -> Void
        
        init(view: ARView? = nil, select: @escaping (Node?) -> Void) {
            self.view = view
            self.select = select
        }
        
        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let view = self.view else { return }
            
            let tapLocation = recognizer.location(in: view)
            
            if let entity = view.entity(at: tapLocation), let entity = entity as? SimulationEntity ?? entity.parent as? SimulationEntity, let node = entity.node {
                select(node)
            } else {
                select(nil)
            }
        }
    }
}
#elseif os(macOS)
private struct RealityView: NSViewRepresentable {
    
    let anchor = AnchorEntity()
    var root: Entity
    
    var size: CGSize
    var arMode: Bool
    var select: (Node?) -> Void
    
    func makeNSView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.environment.background = .color(.black)
        
        anchor.addChild(root)
        
        anchor.orientation = simd_quatf(angle: .pi/2, axis: SIMD3(1,0,0))
        anchor.scale = [2,2,2] * Float(min(size.width, size.height) / max(size.width, size.height))
        
        context.coordinator.view = arView
        arView.addGestureRecognizer(NSClickGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleClick)))
        
        arView.scene.anchors.append(anchor)
        return arView
    }
    
    func updateNSView(_ arView: ARView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(select: select)
    }
    
    class Coordinator: NSObject {
        
        weak var view: ARView?
        var select: (Node?) -> Void
        
        init(view: ARView? = nil, select: @escaping (Node?) -> Void) {
            self.view = view
            self.select = select
        }
        
        @objc func handleClick(_ recognizer: NSClickGestureRecognizer) {
            guard let view = self.view else { return }
            
            let tapLocation = recognizer.location(in: view)
            
            if let entity = view.entity(at: tapLocation), let entity = entity as? SimulationEntity ?? entity.parent as? SimulationEntity, let node = entity.node {
                select(node)
            } else {
                select(nil)
            }
        }
    }
}
#endif

//let camera = PerspectiveCamera()
//camera.camera.fieldOfViewInDegrees = 60
//
//let cameraAnchor = AnchorEntity(world: .zero)
//cameraAnchor.addChild(camera)
//
//arView.scene.addAnchor(cameraAnchor)
//
//let cameraDistance: Float = 3
//var currentCameraRotation: Float = 0
//let cameraRotationSpeed: Float = 0.01
//
//sceneEventsUpdateSubscription = arView.scene.subscribe(to: SceneEvents.Update.self) { _ in
//    let x = sin(currentCameraRotation) * cameraDistance
//    let z = cos(currentCameraRotation) * cameraDistance
//    
//    let cameraTranslation = SIMD3<Float>(x, 0, z)
//    let cameraTransform = Transform(scale: .one,
//                                    rotation: simd_quatf(),
//                                    translation: cameraTranslation)
//    
//    camera.transform = cameraTransform
//    camera.look(at: .zero, from: cameraTranslation, relativeTo: nil)
//
//    currentCameraRotation += cameraRotationSpeed
//}
