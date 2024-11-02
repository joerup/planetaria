//
//  Simulator2D.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 1/7/24.
//

import SwiftUI
import RealityKit

#if os(iOS) || os(macOS)
public struct Simulator: View {
    
    @Environment(\.scenePhase) var scenePhase
    
    @ObservedObject private var simulation: Simulation

    public init(for simulation: Simulation) {
        self.simulation = simulation
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                switch simulation.viewType {
                case .fixed:
                    RealityView(root: simulation.rootEntity, size: geometry.size, arMode: false, select: simulation.selectObject(_:))
                        .simultaneousGesture(panGesture)
                        .simultaneousGesture(zoomGesture)
                case .augmented:
                    RealityView(root: simulation.rootEntity, size: geometry.size, arMode: true, select: simulation.selectObject(_:))
                        .simultaneousGesture(panGesture)
                        .simultaneousGesture(zoomGesture)
                case .immersive:
                    EmptyView()
                }
            }
            .onAppear {
                simulation.rootEntity.setSizes(geometry.size)
            }
            .onChange(of: geometry.size) { size in
                simulation.rootEntity.setSizes(size)
            }
            .onChange(of: simulation.viewType) { mode in
                simulation.rootEntity.setSizes(geometry.size)
                simulation.resetPitch()
            }
            .onChange(of: scenePhase) { _ in
                Entity.registerAll()
            }
        }
        .ignoresSafeArea()
    }
    
    private let translationAngleFactor: CGFloat = .pi / 400
    private var panGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                simulation.updateRotationGesture(with: .radians(-value.translation.width * translationAngleFactor))
                simulation.updatePitchGesture(with: .radians(value.translation.height * translationAngleFactor))
            }
            .onEnded { value in
                simulation.completeRotationGesture(with: .radians(-value.translation.width * translationAngleFactor))
                simulation.completePitchGesture(with: .radians(value.translation.height * translationAngleFactor))
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

#if os(iOS)
private struct RealityView: UIViewRepresentable {
    
    let anchor = AnchorEntity()
    var root: SimulationRootEntity
    
    var size: CGSize
    var arMode: Bool
    var select: (Node?) -> Void
    
    private var mode: ARView.CameraMode {
        return arMode ? .ar : .nonAR
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: mode, automaticallyConfigureSession: true)
        root.arView = arView
        anchor.addChild(root)
        
        anchor.orientation = arMode ? .identity : simd_quatf(angle: .pi/2, axis: SIMD3(1,0,0))
        anchor.position = arMode ? [0,-0.2,-1] : .zero
        anchor.scale = arMode ? .one : SIMD3(repeating: Float(2 * min(1, size.width/size.height)))
        
        context.coordinator.view = arView
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap)))
        
        arView.scene.anchors.append(anchor)
        
        if root.debugMode {
            arView.debugOptions.insert(.showStatistics)
        }
        
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
            
            if let entity = view.entity(at: tapLocation), let node = entity.component(InteractionComponent.self)?.node {
                select(node)
            }
        }
    }
}
#elseif os(macOS)
private struct RealityView: NSViewRepresentable {
    
    let anchor = AnchorEntity()
    var root: SimulationRootEntity
    
    var size: CGSize
    var arMode: Bool
    var select: (Node?) -> Void
    
    func makeNSView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.environment.lighting.resource = try! EnvironmentResource.load(named: "light")
        root.arView = arView
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
            
            if let entity = view.entity(at: tapLocation), let node = entity.component(InteractionComponent.self)?.node {
                select(node)
            }
        }
    }
}
#endif
