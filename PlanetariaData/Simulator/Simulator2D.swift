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
    
    @State private var ar: Bool = false

    public init(from simulation: Simulation) {
        self.simulation = simulation
    }
    
    public var body: some View {
        GeometryReader { geometry in
            RealityView(rootEntity: simulation.rootEntity, size: geometry.size, ar: ar, select: simulation.select(_:))
                .simultaneousGesture(panGesture)
                .simultaneousGesture(zoomGesture)
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
    
    var rootEntity: Entity
    var size: CGSize
    var ar: Bool
    var select: (Node?) -> Void
    
    private var mode: ARView.CameraMode {
        return ar ? .ar : .nonAR
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: mode, automaticallyConfigureSession: true)
        
        if let resource = try? EnvironmentResource.load(named: "Starfield") {
            arView.environment.background = .skybox(resource)
        }
        
        let anchor = AnchorEntity()
        anchor.addChild(rootEntity)
        
        anchor.orientation = simd_quatf(angle: .pi/2, axis: SIMD3(1,0,0))
        anchor.scale = [2,2,2]
        
        context.coordinator.view = arView
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap)))
        
        arView.scene.anchors.append(anchor)
        return arView
    }
    
    func updateUIView(_ arView: ARView, context: Context) {
        arView.cameraMode = mode
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
    
    var rootEntity: Entity
    var ar: Bool
    var select: (Node?) -> Void
    
    func makeNSView(context: Context) -> ARView {
        let arView = ARView(frame: .init(x: 1, y: 1, width: 1, height: 1))
        
        let anchor = AnchorEntity()
        anchor.addChild(rootEntity)
        
        anchor.orientation = simd_quatf(angle: .pi/2, axis: SIMD3(1,0,0))
        
//        context.coordinator.view = arView
//        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap)))
        
        arView.scene.anchors.append(anchor)
        return arView
    }
    
    func updateNSView(_ arView: ARView, context: Context) {
        
    }
    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(select: select)
//    }
//    
//    class Coordinator: NSObject {
//        
//        weak var view: ARView?
//        var select: (Node?) -> Void
//        
//        init(view: ARView? = nil, select: @escaping (Node?) -> Void) {
//            self.view = view
//            self.select = select
//        }
//        
//        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
//            guard let view = self.view else { return }
//            
//            let tapLocation = recognizer.location(in: view)
//            
//            if let entity = view.entity(at: tapLocation), let entity = entity as? SimulationEntity ?? entity.parent as? SimulationEntity, let node = entity.node {
//                select(node)
//            } else {
//                select(nil)
//            }
//        }
//    }
}
#endif
