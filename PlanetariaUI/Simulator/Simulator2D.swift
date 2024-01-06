//
//  Simulator2D.swift
//  Planetaria
//
//  Created by Joe Rupertus on 6/9/23.
//

import SwiftUI
import PlanetariaData
import simd

public struct Simulator2D: View {
    
    @ObservedObject private var simulation: Simulation
    
    public init(from simulation: Simulation) {
        self.simulation = simulation
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(simulation.currentNodes, id: \.id) { node in
                    component(node) {
                        trail(for: node, size: geometry.size)
                        point(for: node, size: geometry.size)
                    }
                }
                ForEach(simulation.currentBodies, id: \.id) { body in
                    component(body) {
                        model(for: body, size: geometry.size)
                    }
                }
            }
            .background(Color.black)
            #if os(iOS) || os(macOS)
            .simultaneousGesture(zoomGesture)
            .simultaneousGesture(panGesture)
            #elseif os(watchOS)
            .focusable(true)
            .digitalCrownRotation(zoomGestureScale, from: -10, through: 10, by: 0.25, sensitivity: .low, isContinuous: true, isHapticFeedbackEnabled: true)
            #endif
            .ignoresSafeArea(.keyboard)
            .onTapGesture {
                simulation.select(nil)
            }
            .onAppear {
                simulation.setupDisplay(size: min(geometry.size.width, geometry.size.height))
            }
            .onChange(of: geometry.size) { size in
                simulation.setupDisplay(size: min(size.width, size.height))
            }
        }
    }
    
    private func component<Content: View>(_ node: Node, @ViewBuilder content: () -> Content) -> some View {
        content()
            .onTapGesture {
                simulation.select(node)
            }
    }
    
    // MARK: - Components
    
    @ViewBuilder
    private func model(for object: Object, size: CGSize) -> some View {
        let modelSize: CGFloat = 2 * simulation.applySafeScale(object.totalSize)
        ObjectBody(object: object, pitch: simulation.pitch, rotation: simulation.rotation)
            .frame(width: 1.2 * modelSize, height: 1.2 * modelSize)
            .position(position(for: object, size: size))
    }
    
    @ViewBuilder
    private func point(for node: Node, size: CGSize) -> some View {
        Group {
            NodePoint(node: node, isSelected: simulation.isSelected(node), noSelection: simulation.noSelection, isSystem: simulation.isSystem(node), isFocus: simulation.isFocus(node))
            NodeText(node: node, isSelected: simulation.isSelected(node), noSelection: simulation.noSelection)
                .offset(y: 12 + simulation.applyScale(node.size))
                .opacity(simulation.textVisibility(node))
        }
        .position(position(for: node, size: size))
        .transition(.opacity)
    }
    
    @ViewBuilder
    private func trail(for node: Node, size: CGSize) -> some View {
        if simulation.showOrbit(node), let orbit = node.orbit {
            let width: CGFloat = size.width
            let height: CGFloat = size.width * orbit.ratio
            let scale: CGFloat = simulation.applyBaseScale(orbit.width)/width
            let lineWidth: CGFloat = 2.5/(scale * simulation.scale)
            let totalWidth: CGFloat = width + lineWidth
            let totalHeight: CGFloat = height + lineWidth
            
            OrbitTrail(orbit: orbit, isSelected: simulation.isSelected(node), noSelection: simulation.noSelection,
                        color: node.color ?? .gray, full: node.rank == .primary || simulation.isSelected(node),
                        lineWidth: lineWidth, totalWidth: totalWidth, totalHeight: totalHeight)
                .transformEffect(CGAffineTransform(translationX: -totalWidth/2, y: -totalHeight/2))
                .transformEffect(orbitTransformation(orbit))
                .transformEffect(CGAffineTransform(translationX: totalWidth/2, y: totalHeight/2))
                .scaleEffect(scale * simulation.scale)
                .offset(simulation.transform((node.parent?.position ?? .zero) + node.barycenterPosition).mapSize)
                .opacity(simulation.trailVisibility(node))
                .frame(width: size.width, height: size.height)
        }
    }
    
   
    // MARK: - Positioning

    private func position(for node: Node, size: CGSize) -> CGPoint {
        let position = simulation.transform(node.globalPosition)
        return CGPoint(x: position.x + size.width/2, y: -position.y + size.height/2)
    }
    
    private func orbitTransformation(_ orbit: Orbit) -> CGAffineTransform {
        let q1 = simd_quatd(angle: orbit.longitudeOfPeriapsis, axis: Vector.referencePlane.simd)
        let q2 = simd_quatd(angle: -orbit.orbitalInclination, axis: orbit.lineOfNodes.simd)
        let q3 = simd_quatd(angle: -simulation.rotation.radians, axis: Vector.referencePlane.simd)
        let q4 = simd_quatd(angle: -simulation.pitch.radians, axis: Vector.vernalEquinox.simd)
        return CGAffineTransform(quaternion: q1 * q2 * q3 * q4)
    }
    
    
    // MARK: - Gestures
    
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
    
    #if os(iOS) || os(macOS)
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                simulation.updateScaleGesture(to: value)
            }
            .onEnded { value in
                simulation.completeScaleGesture(to: value)
            }
    }
    #elseif os(watchOS)
    public var zoomGestureScale: Binding<CGFloat> {
        Binding(get: {
            log2(simulation.scale)
        }, set: { newValue in
            simulation.completeScaleGesture(to: pow(2, newValue) / simulation.scale)
        })
    }
    #endif
}
