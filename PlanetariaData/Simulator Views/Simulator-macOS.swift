//
//  Simulator-macOS.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 1/6/25.
//

#if os(macOS)
import SwiftUI
import RealityKit
import AppKit

public struct Simulator: View {
    
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    @ObservedObject private var simulation: Simulation
    
    @State private var gestureOffset: CGSize = .zero
    @State private var gestureScale: Double = 1.0
    
    @State private var introDarkness: Double = 1.0
    
    public init(for simulation: Simulation) {
        self.simulation = simulation
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                switch simulation.viewType {
                case .fixed, .augmented:
                    RealityView(
                        root: simulation.rootEntity,
                        size: geometry.size,
                        select: simulation.selectObject(_:),
                        onScrollZoom: { scaleDelta in
                            handleScrollZoom(scaleDelta)
                        },
                        onDrag: { delta in
                            handleDrag(delta)
                        },
                        onMagnification: { scaleFactor in
                            handleMagnification(scaleFactor)
                        }
                    )
                case .immersive:
                    EmptyView()
                }
            }
            .onAppear {
                handleChange(size: geometry.size, dynamicTypeSize: dynamicTypeSize, fadeIn: true)
            }
            .onChange(of: geometry.size) { size in
                handleChange(size: size, dynamicTypeSize: dynamicTypeSize, fadeIn: simulation.viewType == .fixed)
            }
            .onChange(of: dynamicTypeSize) { dynamicTypeSize in
                handleChange(size: geometry.size, dynamicTypeSize: dynamicTypeSize, fadeIn: false)
            }
            .onChange(of: simulation.viewType) { _ in
                handleChange(size: geometry.size, dynamicTypeSize: dynamicTypeSize, fadeIn: true, resetPitch: true)
            }
            .onChange(of: scenePhase) { _ in
                Entity.registerAll()
            }
        }
        .ignoresSafeArea()
        .overlay {
            Color.black
                .opacity(introDarkness)
                .ignoresSafeArea()
        }
    }
    
    // MARK: - Private Helpers
    
    private let translationAngleFactor: CGFloat = .pi / 400
    
    private func handleDrag(_ translation: CGSize) {
        simulation.completeRotationGesture(with: .radians(-translation.width * translationAngleFactor))
        simulation.completePitchGesture(with: .radians(-translation.height * translationAngleFactor))
    }
    
    private func handleScrollZoom(_ scaleFactor: CGFloat) {
        simulation.completeScaleGesture(to: scaleFactor)
    }
    
    private func handleMagnification(_ scaleFactor: CGFloat) {
        simulation.completeScaleGesture(to: scaleFactor)
    }
    
    private func handleChange(size: CGSize, dynamicTypeSize: DynamicTypeSize, fadeIn: Bool, resetPitch: Bool = false) {
        if fadeIn {
            introDarkness = 1.0
            withAnimation(.default.delay(0.4)) {
                introDarkness = 0.0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            simulation.rootEntity.setSizes(size, dynamicTypeSize)
            if resetPitch {
                simulation.resetPitch()
            }
            updateAnchorScale(size)
        }
    }
    
    private func updateAnchorScale(_ size: CGSize) {
        if let anchor = simulation.rootEntity.arView?.scene.anchors.first {
            anchor.scale = simulation.viewType == .augmented
                ? .one
                : SIMD3(repeating: Float(2 * min(1, size.width / size.height)))
        }
    }
}

private struct RealityView: NSViewRepresentable {
    
    let anchor = AnchorEntity()
    var root: SimulationRootEntity
    
    var size: CGSize
    var select: (Node?) -> Void
    
    // Gesture callback closures
    var onScrollZoom: (CGFloat) -> Void
    var onDrag: (CGSize) -> Void
    var onMagnification: (CGFloat) -> Void
    
    func makeNSView(context: Context) -> CustomARView {
        let arView = CustomARView()
        root.arView = arView
        anchor.addChild(root)
        
        // Adjust anchor orientation if needed
        anchor.orientation = simd_quatf(angle: .pi/2, axis: SIMD3(1, 0, 0))
        
        context.coordinator.view = arView
        
        // Add Click Gesture Recognizer
        let clickRecognizer = NSClickGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleClick)
        )
        arView.addGestureRecognizer(clickRecognizer)
        
        // Assign Gesture Callbacks
        arView.onScrollZoom = onScrollZoom
        arView.onDrag = onDrag
        arView.onMagnification = onMagnification
        
        arView.scene.anchors.append(anchor)
        
        return arView
    }
    
    func updateNSView(_ nsView: CustomARView, context: Context) {
        // Handle any updates to the ARView if necessary
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator { origin, direction in
            if let node = root.queryTap(origin: origin, direction: direction) {
                select(node)
            }
        }
    }
    
    class Coordinator: NSObject {
        
        weak var view: ARView?
        var select: (_ origin: SIMD3<Float>, _ direction: SIMD3<Float>) -> Void
        
        init(select: @escaping (_ origin: SIMD3<Float>, _ direction: SIMD3<Float>) -> Void) {
            self.select = select
        }
        
        @objc func handleClick(_ recognizer: NSClickGestureRecognizer) {
            guard let view = self.view as? CustomARView else { return }
            
            let tapLocation = recognizer.location(in: view)
            
            if let (origin, direction) = view.ray(through: tapLocation) {
                select(origin, direction)
            }
        }
    }

    // MARK: - CustomARView Class
    
    class CustomARView: ARView {
        
        // MARK: - Callback Closures
        
        /// Called when a scroll wheel event for zooming is detected.
        var onScrollZoom: ((CGFloat) -> Void)?
        
        /// Called when a drag event occurs. Provides the translation delta.
        var onDrag: ((CGSize) -> Void)?
        
        /// Called when a magnification gesture is detected.
        var onMagnification: ((CGFloat) -> Void)?
        
        // MARK: - Properties for Drag Handling
        
        private var lastDragLocation: CGPoint?
        
        // MARK: - Initializer
        
        required init(frame frameRect: CGRect) {
            super.init(frame: frameRect)
            setupGestureRecognizers()
        }
        
        @objc required dynamic init?(coder decoder: NSCoder) {
            super.init(coder: decoder)
            setupGestureRecognizers()
        }
        
        // MARK: - Gesture Recognizers Setup
        
        private func setupGestureRecognizers() {
            // Magnification Gesture Recognizer
            let magnificationRecognizer = NSMagnificationGestureRecognizer(target: self, action: #selector(handleMagnification(_:)))
            self.addGestureRecognizer(magnificationRecognizer)
        }
        
        // MARK: - Scroll Wheel Handling
        
        override func scrollWheel(with event: NSEvent) {
            super.scrollWheel(with: event)
            
            // Use scrollingDeltaY for vertical scrolling
            let delta = event.scrollingDeltaY
            
            // Determine the scale delta based on scroll direction
            // Adjust the sensitivity as needed
            let scaleDelta: CGFloat
            if delta > 0 {
                scaleDelta = 1.05
            } else {
                scaleDelta = 0.95
            }
            
            // Call back to SwiftUI
            onScrollZoom?(scaleDelta)
        }
        
        // MARK: - Mouse Events for Drag Handling
        
        override func mouseDown(with event: NSEvent) {
            super.mouseDown(with: event)
            lastDragLocation = event.locationInWindow
        }
        
        override func mouseDragged(with event: NSEvent) {
            super.mouseDragged(with: event)
            
            guard let lastLocation = lastDragLocation else { return }
            let currentLocation = event.locationInWindow
            let deltaX = currentLocation.x - lastLocation.x
            let deltaY = currentLocation.y - lastLocation.y
            let delta = CGSize(width: deltaX, height: deltaY)
            
            // Update the last location
            lastDragLocation = currentLocation
            
            // Call back to SwiftUI
            onDrag?(delta)
        }
        
        override func mouseUp(with event: NSEvent) {
            super.mouseUp(with: event)
            lastDragLocation = nil
        }
        
        // MARK: - Magnification Gesture Handling
        
        @objc private func handleMagnification(_ sender: NSMagnificationGestureRecognizer) {
            switch sender.state {
            case .began, .changed:
                let magnification = sender.magnification
                let scaleDelta: CGFloat
                if magnification > 0 {
                    scaleDelta = 1.05
                } else {
                    scaleDelta = 0.95
                }
                onMagnification?(CGFloat(scaleDelta))
            default:
                break
            }
        }
    }
}

#endif
