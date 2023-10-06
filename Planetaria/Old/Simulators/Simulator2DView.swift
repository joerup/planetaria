////
////  Simulator2DView.swift
////  Planetaria
////
////  Created by Joe Rupertus on 1/12/23.
////
//
//import SwiftUI
//
//struct Simulator2DView: View {
//    
//    @Environment(\.horizontalSizeClass) var horizontalSizeClass
//    @Environment(\.verticalSizeClass) var verticalSizeClass
//    var previewSizeClass: Bool {
//        return horizontalSizeClass == .compact && verticalSizeClass == .regular
//    }
//    
//    @Binding var selectedSystem: System?
//    @Binding var selectedObject: Object?
//    
//    var orbitDisplayMode: OrbitDisplayMode
//    
//    var onDismiss: () -> Void
//    
//    var objects: [Object] {
//        return selectedSystem?.objects ?? []
//    }
//    var displayedObjects: [Object] {
//        return objects
//    }
//    
//    @State private var defaultScaleRatio: Double = 1E+6
//    
//    private var centerPosition: [Double] {
//        return objects.first?.position ?? [0,0,0]
//    }
//    
//    private var centerCoordinates: CGPoint {
//        let offset = offset.applying(CGAffineTransform(rotationAngle: rotation.radians))
//        return CGPoint(x: scale * offset.width, y: scale * offset.height)
//    }
//    
//    private var totalScale: Double {
//        return scale / defaultScaleRatio
//    }
//    
//    @State private var steadyOffset: CGSize = .zero
//    @GestureState private var gestureOffset: CGSize = .zero
//    
//    private var offset: CGSize {
//        steadyOffset + gestureOffset
//    }
//    
//    @State private var steadyScale: CGFloat = 1
//    @GestureState private var gestureScale: CGFloat = 1
//    
//    private var scale: CGFloat {
//        steadyScale * gestureScale
//    }
//    
//    @State private var steadyRotation: Angle = .zero
//    @GestureState private var gestureRotation: Angle = .zero
//    
//    private var rotation: Angle {
//        steadyRotation + gestureRotation
//    }
//    
//    @State private var grayscale: Double = 0
//    
//    @State private var introScale: Double = 1
//    @State private var introObjectOpacity: Double = 0
//    
//    var body: some View {
//        
//        GeometryReader { geometry in
//            
//            ZStack {
//                ForEach(self.displayedObjects.reversed(), id: \.id) { object in
//                    ZStack {
//                        trail(for: object, size: geometry.size)
//                        visual(for: object, size: geometry.size)
//                    }
//                    .onTapGesture {
//                        withAnimation {
//                            if selectedObject == object {
//                                withAnimation(.easeIn(duration: 1.0)) {
//                                    moveCamera(to: position(for: object, size: geometry.size))
//                                    zoomCamera(to: object.safeDistance)
//                                }
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                                    setSystem(to: object.soloSystem)
//                                }
//                            } else {
//                                setObject(to: object)
//                            }
//                        }
//                    }
//                }
//            }
//            .scaleEffect(introScale)
//            .opacity(pow(introScale, 2))
//            .onChange(of: selectedSystem) { _ in
//                SoundManager.play(haptic: .heavy)
//                scaleAfterSystemChange(size: geometry.size)
//            }
//            .onChange(of: selectedObject) { _ in
//                SoundManager.play(haptic: .heavy)
//                scaleAfterObjectChange(size: geometry.size)
//            }
//            .onAppear {
//                defaultScaleRatio = 1.2 * (selectedSystem?.maxDistance ?? 1E+6) / min(geometry.size.width, geometry.size.height)
//                if !objects.contains(where: { $0.ephemerisSet }) {
//                    steadyScale = 0.5
//                    introScale = 0.01
//                    withAnimation(.easeInOut(duration: 3.5).delay(1.0)) {
//                        introScale = 0.8
//                        steadyRotation = .zero
//                    }
//                    withAnimation(.easeOut(duration: 0.5).delay(4.5)) {
//                        introScale = 1.0
//                        introObjectOpacity = 1
//                    }
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//                        SoundManager.play(haptic: .heavy)
//                    }
//                } else {
//                    introScale = 1.0
//                    steadyRotation = .zero
//                    introObjectOpacity = 1
//                }
//            }
//        }
//        .background(Image("StarrySky").rotationEffect(rotation).edgesIgnoringSafeArea(.all))
//        .onTapGesture {
//            onDismiss()
//        }
//        .simultaneousGesture(
//            MagnificationGesture()
//                .updating($gestureScale) { value, gestureScale, _ in
//                    gestureScale = value
//                }
//                .onEnded { value in
//                    steadyScale *= value
//                }
//        )
////        .simultaneousGesture(
////            RotationGesture()
////                .updating($gestureRotation) { value, gestureRotation, _ in
////                    gestureRotation = value
////                }
////                .onEnded { value in
////                    steadyRotation += value
////                }
////        )
//    }
//    
//    
//    // MARK: - Visuals
//    
//    @ViewBuilder
//    private func visual(for object: Object, size: CGSize) -> some View {
//        ZStack {
//            let imageSize: CGFloat = applyScale(object.meanRadius?[.km] ?? 1)
//            let dotSize: CGFloat = selectedObject == object ? 12 : showObject(object) ? 10 : 6
//            
//            // Tap Area
//            if imageSize > 1E-6 {
//                Circle()
//                    .fill(.black.opacity(0.01))
//                    .frame(width: dotSize * 3)
//            }
//            
//            // Circle
//            Circle()
//                .fill(showObject(object) ? object.associatedColor : .init(white: 0.4))
//                .opacity(selectedObject == nil || selectedObject == objects.first || selectedObject == object || selectedObject?.orbiting == object ? 1 : 0.3)
//                .frame(width: max(dotSize, imageSize))
//                .shadow(color: .white, radius: selectedObject == object ? 5 : 8)
//            if object == selectedObject {
//                Circle()
//                    .stroke(Color.init(white: grayscale), lineWidth: 1)
//                    .opacity(grayscale)
//                    .frame(width: dotSize * 3)
//                    .transition(.identity)
//                    .onAppear {
//                        self.grayscale = 0
//                        withAnimation(.easeIn(duration: 1.5).repeatForever(autoreverses: true)) {
//                            self.grayscale = 1
//                        }
//                    }
//            }
//        }
//        .position(coordinates(for: position(for: object, size: size), size: size))
//        .offset(offset * scale)
//        .rotationEffect(rotation)
//        .opacity(introObjectOpacity)
//        .transition(.opacity)
//    }
//    
//    @ViewBuilder
//    private func trail(for object: Object, size: CGSize) -> some View {
//        if objects.contains(object.orbiting ?? object) {
////            trailGradient(start: object.position - centerPosition, size: size, color: object.associatedColor, full: showObject(object))
////                .opacity(selectedObject == object ? 1 : (selectedObject == nil || selectedObject == objects.first) ? 0.8 : 0.2)
////                .allowsHitTesting(false)
////                .mask {
////                    if showObject(object) {
////                        let thickness: CGFloat = selectedObject == object ? 8 : 6
////                        object.trail
////                            .offset(x: size.width/2, y: size.height/2)
////                            .stroke(.white, lineWidth: thickness/scale)
////                            .scaleEffect(scale)
////                            .offset(offset * scale)
////                            .rotationEffect(rotation)
////                    }
////                }
////                .animation(.easeInOut(duration: 1.5), value: object.ephemerisSet)
////                .drawingGroup()
//        }
//    }
//    private func trailGradient(start: [Double], size: CGSize, color: Color, full: Bool) -> some View {
//        let angle = start.x == 0 ? 3/2 * Double.pi : atan2(start.x, start.y) - .pi/2
//        let center = centerCoordinates
//        let gradient = AngularGradient(
//            colors: [color, .black.opacity(0.2)],
//            center: UnitPoint(x: 0.5 + center.x / size.width, y: 0.5 + center.y / size.height),
//            startAngle: Angle(radians: angle + rotation.radians),
//            endAngle: Angle(radians: angle + rotation.radians) + .degrees(full ? 360 : 3)
//        )
//        return gradient
//    }
//    
//    private func showObject(_ object: Object) -> Bool {
//        return (selectedSystem?.primaryObjects.contains(object) ?? false) || selectedObject == object
//    }
//    
//    private func position(for object: Object, size: CGSize) -> [Double] {
//        return object.position
////        if orbitDisplayMode == .simplified {
////            return object.position.reduceDim.unitVector * Double(displayedObjects.firstIndex(of: object) ?? 0) / Double(displayedObjects.count) * defaultScaleRatio * min(size.width, size.height)
////        }
////        else if object.orbiting == selectedSystem?.firstObject {
////            return centerPosition + object.orbitalPathFunction(.radians(object.trueAnomaly))
////        }
////        else {
////            return object.position
////        }
//    }
//    
//    
//    // MARK: - Coordinates
//    
//    private func coordinates(for position: [Double], size: CGSize) -> CGPoint {
//        let coordinates = applyScale((position - centerPosition).reduceDim)
//        return CGPoint(x: coordinates.x + size.width/2, y: -coordinates.y + size.height/2)
//    }
//    private func coordinates(for position: [Double], size: CGSize) -> UnitPoint {
//        let point: CGPoint = coordinates(for: position, size: size)
//        return UnitPoint(x: point.x, y: point.y)
//    }
//    
//    private func applyScale(_ value: CGFloat) -> CGFloat {
//        return value * totalScale
//    }
//    private func applyScale(_ value: [Double]) -> [Double] {
//        return value * totalScale
//    }
//    private func applyBaseScale(_ value: [Double]) -> [Double] {
//        return value / defaultScaleRatio
//    }
//    private func applyBaseScale(_ value: CGFloat) -> CGFloat {
//        return value / defaultScaleRatio
//    }
//    
//    
//    // MARK: - Camera
//    
//    private func moveCamera(to position: [Double]) {
//        let position = applyBaseScale(position - centerPosition)
//        self.steadyOffset = CGSize(width: -position.x, height: position.y)
//    }
//    private func zoomCamera(to scale: CGFloat) {
//        self.steadyScale = defaultScaleRatio / scale
//    }
//    private func zoomCamera(by scale: CGFloat) {
//        self.steadyScale *= scale
//    }
//    
//    private func scaleAfterSystemChange(size: CGSize) {
//        guard let selectedSystem else { return }
//        withAnimation(.easeInOut(duration: 0.5)) {
//            if let orbiting = selectedObject?.orbiting, !objects.contains(orbiting) {
//                zoomCamera(to: selectedSystem.maxDistance * 2 / min(size.width, size.height))
//            } else if let selectedObject, selectedObject != objects.first {
//                zoomCamera(to: 2.5 * selectedObject.maxDistance / min(size.width, size.height))
//            } else {
//                zoomCamera(to: selectedSystem.maxDistance * 2 / min(size.width, size.height))
//            }
//        }
//    }
//    private func scaleAfterObjectChange(size: CGSize) {
//        guard let selectedObject else { return }
//        withAnimation(.easeInOut(duration: 0.5)) {
//            if selectedObject == objects.first {
//                zoomCamera(to: selectedObject.safeDistance * 10 / min(size.width, size.height))
//            } else {
//                zoomCamera(to: 2.5 * selectedObject.maxDistance / min(size.width, size.height))
//            }
//        }
//    }
//    
//    
//    // MARK: - Navigation
//    
//    private func setObject(to object: Object) {
//        self.selectedObject = object
//    }
//    private func setSystem(to system: System) {
//        self.selectedSystem = system
//        self.steadyOffset = .zero
//    }
//}
