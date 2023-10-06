//
//  Planetarium.swift
//  Planetaria
//
//  Created by Joe Rupertus on 6/9/23.
//

import SwiftUI
import PlanetariaData

struct Planetarium: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    var previewSizeClass: Bool {
        return horizontalSizeClass == .compact && verticalSizeClass == .regular
    }
    
    var root: Node?
    
    @Binding var reference: Node?
    @Binding var system: SystemNode?
    @Binding var object: ObjectNode?
    
    @Binding var focusTrigger: Bool?
    @Binding var backTrigger: Bool?
    
    var onDismiss: () -> Void
    
    @State private var nodes: [Node] = []
    
    @State private var defaultScaleRatio: Double = 1E+6
    
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
    
    // Other
    @State private var grayscale: Double = 0
    @State private var introScale: Double = 1
    @State private var introObjectOpacity: Double = 0
 
    
    var body: some View {
        
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
//                    VStack {
//                        ForEach(self.nodes) { node in
//                            if system.contains(node) {
//                                if showModel(node, size: geometry.size, modelSize: 2 * applyScale(node.size)) {
//                                    Text(node.name)
//                                        .foregroundColor(.blue)
//                                } else if showTrail(node, size: geometry.size) {
//                                    Text(node.name)
//                                        .foregroundColor(.red)
//                                } else {
//                                    Text(node.name)
//                                }
//                            }
//                        }
//                    }
                }
            }
            .scaleEffect(introScale)
            .opacity(pow(introScale, 2))
            .background(Color.black)
            .simultaneousGesture(zoomGesture(size: geometry.size))
            .simultaneousGesture(panGesture(size: geometry.size))
            .onTapGesture {
                onDismiss()
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
//            .onAppear {
//                runIntro(size: geometry.size)
//            }
            .onAppear {
                guard let root else { return }
                self.nodes = [root] + root.relatedNodes
            }
        }
    }
    
    
    
    // MARK: - Gestures
    
    private func zoomGesture(size: CGSize) -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                gestureScale = value
                updateOffset(size: size)
                
                if let reference, 2.2 * applyScale(reference.size) > min(size.width, size.height) {
                    gestureScale *= min(size.width, size.height) / (2.2 * applyScale(reference.size))
                }
            }
            .onEnded { value in
                steadyScale *= value
                gestureScale = 1.0
                updateOffset(size: size)
                
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
    
    
    
    // MARK: - Components
    
    @ViewBuilder
    private func visual(for node: Node, size: CGSize) -> some View {
        ZStack {
            let modelSize: CGFloat = 2 * applyScale(node.size)
            let dotSize: CGFloat = node.object == object ? 8 : node.rank == .primary ? 6 : 4

            // Tap Area
            if modelSize > 1E-6 {
                Circle()
                    .fill(.black.opacity(0.01))
                    .frame(width: dotSize * 3)
            }

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
                    .frame(width: dotSize * 3)
                    .transition(.identity)
                    .onAppear {
                        self.grayscale = 0
                        withAnimation(.easeIn(duration: 1.5).repeatForever(autoreverses: true)) {
                            self.grayscale = 1
                        }
                    }
            }

            // 3D Model
            if let object = node as? ObjectNode, showModel(node, size: size, modelSize: modelSize) {
                Object3D(object, pitch: pitch, rotation: rotation)
                    .frame(width: 1.2 * modelSize, height: 1.2 * modelSize)
            }
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
            let thickness: CGFloat = node.object == object ? 4 : 2
            let trailScale: CGFloat = applyBaseScale(2 * node.semimajorAxis)/width
            
            if width > 0, height > 0 {
                trailGradient(angle: -.radians(node.trueAnomaly), rank: node.object == object ? .primary : node.rank, centerOffset: offset/width, size: size, color: node.color)
                    .allowsHitTesting(false)
                    .opacity(node.object == object ? 1 : object == nil ? 0.8 : 0.3)
                    .frame(width: width, height: height)
                    .mask {
                        Ellipse()
                            .stroke(lineWidth: thickness/(trailScale * scale))
                            .padding(thickness/(trailScale * scale)/2)
                    }
                    .offset(x: offset)
                    .scaleEffect(trailScale * scale)
                    .transformEffect(CGAffineTransform(translationX: -width/2, y: -height/2))
                    .transformEffect(orbitTransformation(for: node))
                    .transformEffect(CGAffineTransform(translationX: width/2, y: height/2))
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
        return 0.1...min(size.width, size.height) ~= modelSize
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
//
    private func orbitTransformation(for node: Node) -> CGAffineTransform {
        Matrix(rotation: pitch.radians, about: [1,0,0])
            .applying(Matrix(rotation: -rotation.radians))
            .applying(Matrix(rotation: node.orbitalInclination, about: node.lineOfNodes))
            .applying(Matrix(rotation: node.longitudeOfPeriapsis))
            .transformation
    }
    
    // Object Coordinates -> Screen Position
    
    private func applyBaseScale(_ value: CGFloat) -> CGFloat {
        return value / defaultScaleRatio
    }
    private func applyBaseScale(_ value: [Double]) -> [Double] {
        return value / defaultScaleRatio
    }
    private func applyScale(_ value: CGFloat) -> CGFloat {
        return value * totalScale
    }
    private func applyScale(_ value: [Double]) -> [Double] {
        return value * totalScale
    }
    private func applyOffset(_ value: [Double]) -> [Double] {
        return value - offset
    }
    private func applyRotation(_ value: [Double]) -> [Double] {
        return value.rotated(by: -rotation.radians, about: [0,0,1])
    }
    private func applyPitch(_ value: [Double]) -> [Double] {
        return value.rotated(by: pitch.radians, about: [1,0,0])
    }
    private func applyAllTransformations(_ value: [Double]) -> [Double] {
        return applyPitch(applyRotation(applyScale(applyOffset(value))))
    }
    
    // Screen Position -> Object Coordinates
    
    private func unapplyBaseScale(_ value: CGFloat) -> CGFloat {
        return value * defaultScaleRatio
    }
    private func unapplyBaseScale(_ value: [Double]) -> [Double] {
        return value * defaultScaleRatio
    }
    private func unapplyScale(_ value: CGFloat) -> CGFloat {
        return value / totalScale
    }
    private func unapplyScale(_ value: [Double]) -> [Double] {
        return value / totalScale
    }
    private func unapplyOffset(_ value: [Double]) -> [Double] {
        return value + offset
    }
    private func unapplyRotation(_ value: [Double]) -> [Double] {
        return value.rotated(by: rotation.radians, about: [0,0,1])
    }
    private func unapplyPitch(_ value: [Double]) -> [Double] {
        return value.rotated(by: -pitch.radians, about: [1,0,0])
    }
    private func unapplyAllTransformations(_ value: [Double]) -> [Double] {
        return unapplyOffset(unapplyScale(unapplyRotation(unapplyPitch(value))))
    }
    
    
    
    // MARK: Intents
    
    private func select(_ node: Node, size: CGSize) {
        // Select object in orbit
        if object != node.object {
            withAnimation {
                self.object = node.object
                self.reference = node.parent
            }
        }
        // Tap target
        else if let object = node.object {
            zoomToSurface(node: object, size: size)
        }
    }
    
    private func changeReference(node: Node?) {
        if let node {
            // Update the ephemerides
            Task {
                await node.updateEphemerides()
            }
            // Add all the relevant nodes
            withAnimation {
                nodes = [node] + node.relatedNodes
            }
        }
    }
    
    private func changeSystem(system: SystemNode?) {
        if let system {
            // Remove the selected object if irrelevant
            if let object = object, !system.children.map(\.object).contains(object) {
                self.object = nil
            }
        }
    }
    
    private func changeObject(object: ObjectNode?, size: CGSize) {
        if let object {
            // Zoom to the object
            zoomToOrbit(node: object, size: size)
        }
    }
    
    private func changeFocus(trigger: Bool?, size: CGSize) {
        if let object, let focused = trigger {
            if focused {
                zoomToSurface(node: object, size: size)
            } else {
                zoomToOrbit(node: object, size: size)
            }
        }
        self.focusTrigger = nil
    }
    
    private func goBack(trigger: Bool?, size: CGSize) {
        if let back = trigger, back {
            // Go back
            if let system, let parent = system.parent {
                self.system = parent
                self.reference = parent
//                withAnimation(.linear(duration: 3.0)) {
//                    self.system = parent
//                }
//                if let object = system.object {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        self.reference = parent
//                        zoomToOrbit(node: object, size: size)
//                    }
//                }
            }
        }
        self.backTrigger = nil
    }
    
    
    
    // MARK: Transitions
    
    
    private func updateOffset(size: CGSize) {
        offsetAmount = 1.0
        guard let reference else { return }
        
        let factor: Double = reference is ObjectNode ? 1.8 : 1.8
        let totalSize = applyScale(reference.position).magnitude + applyScale(((object ?? reference.object)?.size ?? .zero) * 2)
        let zoomScale = factor*(totalSize)/max(size.width, size.height)
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
            let factor = childNode is ObjectNode ? 1.8 : 1.8
            if factor*(applyScale(childNode.position).magnitude + applyScale(object.size * 2))/max(size.width, size.height) > 0.5 {
                self.reference = childNode
                updateOffset(size: size)
            }
        }
        // Reference the parent node if zoomed out enough (offset is ending)
        if let parentNode = reference.parent, zoomScale < 0.5 {
            self.reference = parentNode
            updateOffset(size: size)
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
    
    private func zoomToSurface(node: ObjectNode, size: CGSize) {
        print("zooming to surface of \(node.name)")
        zoomCamera(to: 2.5 * node.size / min(size.width, size.height), size: size)
    }
    private func zoomToOrbit(node: Node, size: CGSize) {
        print("zooming to orbit of \(node.name)")
        zoomCamera(to: 2.5 * ((node.globalPosition - (reference?.globalPosition ?? .zero)).magnitude + node.size) / min(size.width, size.height), size: size)
    }
    
    private func zoomCamera(to scale: CGFloat, size: CGSize) {
        let newScale = defaultScaleRatio / scale
        let scaleRatio = newScale / steadyScale
        let count = Int(ceil(abs(log2(scaleRatio))*5))
        let factor = scaleRatio < 1 ? 1/Double(count) : 1/Double(count)
        for i in 0..<count {
            withAnimation(.linear(duration: 0.02).delay(0.02 * Double(i))) {
                self.steadyScale *= pow(scaleRatio, factor)
                if scaleRatio >= 1 {
                    self.updateOffset(size: size)
                }
            }
        }
    }
    
    
    // MARK: Intro
    
//    private func runIntro(size: CGSize) {
//
//        // Setup
//        displayedObjects = objects
//        defaultScaleRatio = 3 * (reference?.maxDistance ?? 1E+6) / min(size.width, size.height)
//
//        // Animations
//        if !objects.contains(where: { $0.ephemerisSet }) {
//            steadyScale = 1
//            introScale = 0.01
//            withAnimation(.easeInOut(duration: 3.5).delay(1.0)) {
//                introScale = 0.8
//                steadyRotation = .zero
//            }
//            withAnimation(.easeOut(duration: 0.5).delay(4.5)) {
//                introScale = 1.0
//                introObjectOpacity = 1
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//                SoundManager.play(haptic: .heavy)
//            }
//        } else {
//            introScale = 1.0
//            steadyRotation = .zero
//            introObjectOpacity = 1
//        }
//    }
}
