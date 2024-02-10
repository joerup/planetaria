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
    
    @ObservedObject private var simulation: Simulation

    public init(from simulation: Simulation) {
        self.simulation = simulation
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                if simulation.arMode {
                    RealityView(root: simulation.rootEntity, size: geometry.size, arMode: true, select: simulation.selectObject(_:))
                        .simultaneousGesture(halfPanGesture)
                        .simultaneousGesture(zoomGesture)
                } else {
                    RealityView(root: simulation.rootEntity, size: geometry.size, arMode: false, select: simulation.selectObject(_:))
                        .simultaneousGesture(fullPanGesture)
                        .simultaneousGesture(zoomGesture)
                }
            }
            .onAppear {
                simulation.setBounds(geometry.size)
            }
            .onChange(of: geometry.size) { size in
                simulation.setBounds(size)
            }
            .onChange(of: simulation.arMode) { mode in
                simulation.setBounds(geometry.size)
                simulation.resetPitch()
            }
        }
        .ignoresSafeArea()
    }
    
    private var fullPanGesture: some Gesture {
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
    
    private var halfPanGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                simulation.updateRotationGesture(with: value.translation.width)
            }
            .onEnded { value in
                simulation.completeRotationGesture(with: value.translation.width)
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
        arView.environment.lighting.resource = try? EnvironmentResource.load(named: "light")
        root.arView = arView
        anchor.addChild(root)
        
        anchor.orientation = arMode ? .init() : simd_quatf(angle: .pi/2, axis: SIMD3(1,0,0))
        anchor.position = arMode ? [0,-0.2,-1] : .zero
        anchor.scale = arMode ? .one : SIMD3(repeating: Float(2 * min(1, size.width/size.height)))
        
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
            
            if let entity = view.entity(at: tapLocation), let node = entity.parent?.component(SimulationComponent.self)?.node {
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
            
            if let entity = view.entity(at: tapLocation), let node = entity.parent?.component(SimulationComponent.self)?.node {
                select(node)
            } else {
                select(nil)
            }
        }
    }
}
#endif
