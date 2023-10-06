//
//  Planetarium.swift
//  Planetaria
//
//  Created by Joe Rupertus on 6/9/23.
//

import SwiftUI
import PlanetariaData

public struct Planetarium: View {
    
    var root: Node?
    
    @Binding var reference: Node?
    @Binding var system: SystemNode?
    @Binding var object: ObjectNode?
    
    @Binding var focusTrigger: Bool?
    @Binding var backTrigger: Bool?
    
    @State private var nodes: [Node] = []
    
    @State private var defaultScaleRatio: Double = 1E+7
    
    private var totalScale: Double {
        scale / defaultScaleRatio
    }
    
    // Offset
    @State private var offsetAmount: Double = 1.0
    private var offset: Vector {
        guard let reference else { return .zero }
        return (reference.parent?.globalPosition ?? .zero) + reference.position * offsetAmount
    }
    
    // Scale
    @State private var steadyScale: CGFloat = 1.0
    @State private var gestureScale: CGFloat = 1.0
    private var scale: CGFloat {
        steadyScale * gestureScale
    }
    
    // Rotation
    @State private var steadyRotation: Angle = .zero
    @State private var gestureRotation: Angle = .zero
    private var rotation: Angle {
        steadyRotation + gestureRotation
    }
    
    // Pitch
    @State private var steadyPitch: Angle = .zero
    @State private var gesturePitch: Angle = .zero
    private var pitch: Angle {
        steadyPitch + gesturePitch
    }
    
    @State private var grayscale: Double = 0
    @State private var introScale: Double = 1E-3
    
    public init(
        root: Node?,
        reference: Binding<Node?>,
        system: Binding<SystemNode?>,
        object: Binding<ObjectNode?>,
        focusTrigger: Binding<Bool?>,
        backTrigger: Binding<Bool?>
    ) {
        self.root = root
        self._reference = reference
        self._system = system
        self._object = object
        self._focusTrigger = focusTrigger
        self._backTrigger = backTrigger
    }
    
    public var body: some View {
        
        GeometryReader { geometry in
            
            ZStack {
                if let system {
                    if reference == system {
                        Circle()
                            .foregroundColor(.init(white: 0.2))
                            .frame(width: 4)
                            .position(position(for: system, size: geometry.size))
                    }
                    ForEach(self.nodes) { node in
                        if system.contains(node) {
                            trail(for: node, size: geometry.size)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                            visual(for: node, size: geometry.size)
                                .onTapGesture {
                                    withAnimation {
                                        select(node, size: geometry.size)
                                    }
                                }
                            text(for: node, size: geometry.size)
                        }
                    }
                }
            }
            .background(Color.black)
            .scaleEffect(introScale)
            #if os(iOS) || os(macOS)
            .simultaneousGesture(zoomGesture(size: geometry.size))
            .simultaneousGesture(panGesture(size: geometry.size))
            #elseif os(watchOS)
            .focusable(true)
            .digitalCrownRotation(Binding(get: {
                log(steadyScale)/log(2)
            }, set: { newValue in
                steadyScale = pow(2, newValue)
                print(steadyScale)
            }), from: -10, through: 10, by: 0.01, sensitivity: .low, isContinuous: true, isHapticFeedbackEnabled: true)
            #endif
            .onTapGesture {
                withAnimation {
                    object = nil
                }
            }
            .onChange(of: reference) { system in
                changeReference(node: system)
            }
            .onChange(of: system) { system in
                changeSystem(system: system)
            }
            .onChange(of: object) { object in
                changeObject(object: object, size: geometry.size)
            }
            .onChange(of: focusTrigger) { trigger in
                changeFocus(trigger: trigger, size: geometry.size)
            }
            .onChange(of: backTrigger) { trigger in
                goBack(trigger: trigger, size: geometry.size)
            }
            .onAppear {
                guard let root else { return }
                nodes = [root] + root.relatedNodes
                defaultScaleRatio = 1.2E+10 / min(geometry.size.width, geometry.size.height)
                runIntro()
            }
        }
    }
    
    
    
    // MARK: - Gestures
    
    #if os(iOS) || os(macOS)
    private func zoomGesture(size: CGSize) -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                gestureScale = value
                updateView(size: size)
                
                if let reference, 2.2 * applyScale(reference.size) > min(size.width, size.height) {
                    gestureScale *= min(size.width, size.height) / (2.2 * applyScale(reference.size))
                }
            }
            .onEnded { value in
                steadyScale *= value
                gestureScale = 1.0
                updateView(size: size)
                
                if let reference, 2.2 * applyScale(reference.size) > min(size.width, size.height) {
                    steadyScale *= min(size.width, size.height) / (2.2 * applyScale(reference.size))
                }
            }
    }
    
    private func panGesture(size: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                gestureRotation = .radians(-value.translation.width * Double.pi / 500)
                gesturePitch = .radians(value.translation.height * Double.pi / 500)
                
                if steadyPitch + gesturePitch > .zero {
                    gesturePitch = -steadyPitch
                }
                if steadyPitch + gesturePitch < -.radians(.pi) {
                    gesturePitch = -steadyPitch - .radians(.pi)
                }
            }
            .onEnded { value in
                steadyRotation += .radians(-value.translation.width * Double.pi / 500)
                steadyPitch += .radians(value.translation.height * Double.pi / 500)
                gestureRotation = .zero
                gesturePitch = .zero
                
                if steadyPitch > .zero {
                    steadyPitch = .zero
                }
                if steadyPitch < -.radians(.pi) {
                    steadyPitch = -.radians(.pi)
                }
            }
    }
    #endif
    
    
    // MARK: - Components
    
    @ViewBuilder
    private func visual(for node: Node, size: CGSize) -> some View {
        ZStack {
            let modelSize: CGFloat = 2 * applyScale(node.size)
            let dotSize: CGFloat = node.object == object ? 8 : node.rank == .primary ? 7 : 6

            // Tap Area
            Circle()
                .fill(.black.opacity(0.01))
                .frame(width: dotSize * 3)

            // Dot
            Circle()
                .fill(node.color)
                .opacity(object == nil || node.object == object ? 1 : 0.6)
                .opacity(node.rank == .primary || node.object == object ? 1 : node.rank == .secondary ? 0.8 : 0.5)
                .opacity(cbrt(dotSize/modelSize-1.0))
                .frame(width: dotSize)
                .shadow(color: .white.opacity(node.object == object ? 1 : node.rank == .primary ? 0.6 : 0.2), radius: 5)

            // Target
            if node.object == object && dotSize > modelSize {
                Circle()
                    .stroke(Color.init(white: grayscale), lineWidth: 1)
                    .opacity(grayscale)
                    .frame(width: dotSize * 2)
                    .transition(.identity)
                    .onAppear {
                        self.grayscale = 0
                        withAnimation(.easeIn(duration: 1.5).repeatForever(autoreverses: true)) {
                            self.grayscale = 1
                        }
                    }
            }

            // 3D Model
            #if os(iOS) || os(macOS) || os(tvOS)
            if let object = node as? ObjectNode, showModel(node, size: size, modelSize: modelSize) {
                Object3D(object: object, pitch: pitch, rotation: rotation)
                    .frame(width: 1.2 * modelSize, height: 1.2 * modelSize)
            }
            #endif
        }
        .position(position(for: node, size: size))
        .transition(.opacity)
    }
    
    @ViewBuilder
    private func text(for node: Node, size: CGSize) -> some View {
        if showText(node, size: size) {
            Text(node.object?.name ?? node.name)
                .font(.system(node.rank == .primary || node.object == object ? .caption : .caption2, design: .rounded))
                .foregroundColor(.white)
                .opacity(node.rank == .primary || node.object == object ? 0.7 : node.rank == .secondary ? 0.5 : 0)
                .opacity(node.object == object ? 1.0 : object == nil ? 1.0 : 0.6)
                .position(position(for: node, size: size))
                .offset(y: 12)
        }
    }
    
    @ViewBuilder
    private func trail(for node: Node, size: CGSize) -> some View {
        if showTrail(node, size: size) {
            let width: CGFloat = size.width
            let height: CGFloat = size.width * sqrt(1 - pow(node.eccentricity, 2))
            let offset: CGFloat = size.width * -node.eccentricity/2
            let trailScale: CGFloat = applyBaseScale(2 * node.semimajorAxis)/width
            let lineWidth: CGFloat = 4/(trailScale * scale)
            let totalWidth: CGFloat = width + lineWidth
            let totalHeight: CGFloat = height + lineWidth
            
            if totalWidth > 0, totalWidth.isFinite, totalHeight > 0, totalHeight.isFinite {
                trailGradient(angle: -.radians(node.trueAnomaly), rank: node.object == object ? .primary : node.rank, centerOffset: offset/width, size: size, color: node.color)
                    .allowsHitTesting(false)
                    .opacity(node.object == object ? 1 : object == nil ? 0.8 : 0.3)
                    .frame(width: totalWidth, height: totalHeight)
                    .mask {
                        Ellipse()
                            .stroke(lineWidth: lineWidth)
                            .padding(lineWidth/2)
                    }
                    .offset(x: offset)
                    .scaleEffect(trailScale * scale)
                    .transformEffect(CGAffineTransform(translationX: -totalWidth/2, y: -totalHeight/2))
                    .transformEffect(orbitTransformation(for: node))
                    .transformEffect(CGAffineTransform(translationX: totalWidth/2, y: totalHeight/2))
                    .offset(applyAllTransformations((node.parent?.position ?? .zero) + node.barycenterPosition).mapSize)
            }
        }
    }
    
    private func trailGradient(angle: Angle, rank: Node.Rank, centerOffset: Double, size: CGSize, color: Color) -> some View {
        let gradient = AngularGradient(
            colors: rank == .primary ? [color, .black.opacity(0.2)] : [rank == .secondary ? color.opacity(0.5) : .init(white: 0.3).opacity(0.5), .black.opacity(0.2), .black.opacity(0.2), .black.opacity(0.2), .black.opacity(0.2)],
            center: UnitPoint(x: 0.5 - centerOffset, y: 0.5),
            startAngle: angle,
            endAngle: angle + .degrees(360)
        )
        return gradient
    }
    
    private func showModel(_ node: Node, size: CGSize, modelSize: CGFloat) -> Bool {
        return 0.1...max(0.2, min(size.width, size.height)) ~= modelSize
    }
    private func showText(_ node: Node, size: CGSize) -> Bool {
        return (2 * applyScale(node.position.magnitude) > max(0.1 * min(size.width, size.height), 50) || node == reference) && (applyScale(node.size) * 100 < min(size.width, size.height))
    }
    private func showTrail(_ node: Node, size: CGSize) -> Bool {
        return applyScale(node.position.magnitude) < 2 * min(size.width, size.height) && (applyScale(node.size) * 50 < min(size.width, size.height))
    }
    
   
    // MARK: - Positioning

    private func position(for node: Node, size: CGSize) -> CGPoint {
        let position = applyAllTransformations(node.globalPosition)
        return CGPoint(x: position.x + size.width/2, y: -position.y + size.height/2)
    }
    
    private func orbitTransformation(for node: Node) -> CGAffineTransform {
        Matrix(rotation: node.longitudeOfPeriapsis)
            .applying(Matrix(rotation: node.orbitalInclination, about: node.lineOfNodes))
            .applying(Matrix(rotation: -rotation.radians))
            .applying(Matrix(rotation: pitch.radians, about: .e1))
            .transformation
    }
    
    // Coordinates in Space -> Position on Screen
    
    private func applyBaseScale(_ value: CGFloat) -> CGFloat {
        return value / defaultScaleRatio
    }
    private func applyBaseScale(_ value: Vector) -> Vector {
        return value / defaultScaleRatio
    }
    private func applyScale(_ value: CGFloat) -> CGFloat {
        return value * totalScale
    }
    private func applyScale(_ value: Vector) -> Vector {
        return value * totalScale
    }
    private func applyOffset(_ value: Vector) -> Vector {
        return value - offset
    }
    private func applyRotation(_ value: Vector) -> Vector {
        return value.rotated(by: -rotation.radians, about: [0,0,1])
    }
    private func applyPitch(_ value: Vector) -> Vector {
        return value.rotated(by: pitch.radians, about: [1,0,0])
    }
    private func applyAllTransformations(_ value: Vector) -> Vector {
        return applyPitch(applyRotation(applyScale(applyOffset(value))))
    }
    
    // Position on Screen -> Coordinates in Space
    
    private func unapplyBaseScale(_ value: CGFloat) -> CGFloat {
        return value * defaultScaleRatio
    }
    private func unapplyBaseScale(_ value: Vector) -> Vector {
        return value * defaultScaleRatio
    }
    private func unapplyScale(_ value: CGFloat) -> CGFloat {
        return value / totalScale
    }
    private func unapplyScale(_ value: Vector) -> Vector {
        return value / totalScale
    }
    private func unapplyOffset(_ value: Vector) -> Vector {
        return value + offset
    }
    private func unapplyRotation(_ value: Vector) -> Vector {
        return value.rotated(by: rotation.radians, about: [0,0,1])
    }
    private func unapplyPitch(_ value: Vector) -> Vector {
        return value.rotated(by: -pitch.radians, about: [1,0,0])
    }
    private func unapplyAllTransformations(_ value: Vector) -> Vector {
        return unapplyOffset(unapplyScale(unapplyRotation(unapplyPitch(value))))
    }
    
    
    // MARK: - Intent Functions
    
    private func select(_ node: Node, size: CGSize) {
        // Select object in orbit
        if object != node.object {
            self.object = node.object
        }
        // Tap target
        else if let object = node.object {
            zoomToSurface(node: object, size: size)
        }
    }
    
    // Called when the reference object updates
    private func changeReference(node: Node?) {
        if let node {
            // Load the ephemerides
            Task {
                await node.loadEphemerides()
            }
            // Add all the relevant nodes
            withAnimation {
                nodes = [node] + node.relatedNodes
            }
        }
    }
    
    // Called when the selected system changes
    private func changeSystem(system: SystemNode?) {
        if let system {
            // Remove the selected object if irrelevant
            if let object = object, !system.children.map(\.object).contains(object) {
                self.object = nil
            }
        }
    }
    
    // Called when the selected object changes
    private func changeObject(object: ObjectNode?, size: CGSize) {
        if let object {
//            // Enter the parent system if not already
//            if reference != object.parent {
//                self.reference = object.parent
//            }
            // Zoom to the object when selected
            if object == reference?.object {
                zoomToSurface(node: object, size: size)
            } else {
                zoomToOrbit(node: object, size: size)
            }
        } else if let reference, 0...0.1 ~= offsetAmount {
            withAnimation {
                zoomToOrbit(node: reference, size: size)
            }
        }
    }
    
    // Called when a focus button is pressed
    private func changeFocus(trigger: Bool?, size: CGSize) {
        if let object, let focused = trigger {
            // Zoom to the object's surface or orbit
            if focused {
                zoomToSurface(node: object, size: size)
            } else {
                zoomToOrbit(node: object, size: size)
            }
        }
        self.focusTrigger = nil
    }
    
    // Called when a back button is pressed
    private func goBack(trigger: Bool?, size: CGSize) {
        if let back = trigger, back, let system {
            // Go back to the parent system
            zoomToOrbit(node: system, size: size)
        }
        self.backTrigger = nil
    }
    
    
    // MARK: - Animations
    
    // Update the view when navigation happens
    // Controls the focus position, current reference and selected system
    private func updateView(size: CGSize) {
        offsetAmount = 1.0
        guard let reference else { return }
        let scaleFactor: CGFloat = 1.2
        
        // Set the offset amount: the percentage which the focus is offset toward the child node
        // e.g. with the Sun as the reference node but Earth selected, offsetAmount = 0.5 would place the central focus halfway between the Earth & Sun
        let totalSize = applyScale(reference.position).magnitude + applyScale(((object ?? reference.object)?.size ?? .zero) * 2)
        let zoomScale = scaleFactor * totalSize / min(size.width, size.height)
        switch zoomScale {
        case ...0.5:
            offsetAmount *= 0
        case ...1:
            offsetAmount *= zoomScale*2 - 1
        default:
            offsetAmount *= 1.0
        }

        // Reference the child node if zoomed in enough (offset is beginning)
        if let object = object ?? reference.object, let childNode = reference.children.first(where: { $0.object == object }) {
            if scaleFactor * (applyScale(childNode.position).magnitude + applyScale(object.size * 2))/min(size.width, size.height) > 0.5 {
                self.reference = childNode
                updateView(size: size)
            }
        }
        // Reference the parent node if zoomed out enough (offset is ending)
        if let parentNode = reference.parent, zoomScale < 0.5 {
            self.reference = parentNode
            updateView(size: size)
        }

        // Select the child system if zoomed in enough (the reference node is a system that comprises more than 10px)
        if reference != system, let childSystem = reference as? SystemNode, let distance = childSystem.scaleDistance, applyScale(distance) > 10 {
            self.system = childSystem
        }
        // Select the parent system if zoomed out enough (the reference node is a system that comprises less than 10px)
        if let parentSystem = system?.parent, let distance = system?.scaleDistance, applyScale(distance) < 10 {
            self.system = parentSystem
        }
    }
    
    // Zoom to an object's surface
    private func zoomToSurface(node: Node, size: CGSize) {
        print("zooming to surface of \(node.name)")
        let node = node.object ?? node
        reference = node.parent
        zoomCamera(to: 2.5 * node.size / min(size.width, size.height), size: size)
    }
    // Zoom to an object's orbital path
    private func zoomToOrbit(node: Node, size: CGSize) {
        print("zooming to orbit of \(node.name)")
        let node = node.system ?? node
        reference = node.parent
        zoomCamera(to: 2.5 * (node.position.magnitude + node.size) / min(size.width, size.height), size: size)
    }
    
    // Zooming animation
    private func zoomCamera(to scale: CGFloat, size: CGSize) {
        let newScale = defaultScaleRatio / scale
        let scaleRatio = newScale / steadyScale
        guard scaleRatio.isFinite else { return }
        let count = Int(ceil(abs(log2(scaleRatio))*2.5))
        let factor = scaleRatio < 1 ? 1/Double(count) : 1/Double(count)
        
        // Incrementally take zoom steps toward the destination
        for i in 0..<count {
            withAnimation(.linear(duration: 0.02).delay(0.02 * Double(i))) {
                steadyScale *= pow(scaleRatio, factor)
                updateView(size: size)
            }
        }
    }
    
    // Intro
    private func runIntro() {
        withAnimation(.easeInOut(duration: 3.0)) {
            introScale = 1.0
        }
    }
}
