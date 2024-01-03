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
                ForEach(simulation.nodes, id: \.id) { node in
                    Group {
                        trail(for: node, size: geometry.size)
                        visual(for: node, size: geometry.size)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .onTapGesture {
                        withAnimation {
                            simulation.select(node)
                        }
                    }
                }
            }
            .background(Color.black)
            #if os(iOS) || os(macOS)
            .simultaneousGesture(simulation.zoomGesture)
            .simultaneousGesture(simulation.panGesture)
            #elseif os(watchOS)
            .focusable(true)
            .digitalCrownRotation(simulation.zoomGestureScale, from: -10, through: 10, by: 0.2, sensitivity: .low, isContinuous: true, isHapticFeedbackEnabled: true)
            #endif
            .ignoresSafeArea(.keyboard)
            .onTapGesture {
                withAnimation {
                    simulation.select(nil)
                }
            }
            .onAppear {
                simulation.startDisplay(size: min(geometry.size.width, geometry.size.height))
            }
            .onChange(of: geometry.size) { size in
                simulation.startDisplay(size: min(size.width, size.height))
            }
        }
    }
    
    // MARK: - Components
    
    @ViewBuilder
    private func visual(for node: Node, size: CGSize) -> some View {
        ZStack {
            let modelSize: CGFloat = 2 * simulation.applySafeScale(node.totalSize)
            NodePoint(node: node, modelSize: modelSize, isSelected: simulation.isSelected(node), noSelection: simulation.noSelection, isSystem: simulation.isSystem(node), isReference: simulation.isReference(node))
            if let object = node.object, simulation.showBody(object) {
                ObjectBody(object: object, pitch: simulation.pitch, rotation: simulation.rotation)
                    .frame(width: 1.2 * modelSize, height: 1.2 * modelSize)
            }
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
                .offset(simulation.applyAllTransformations((node.parent?.position ?? .zero) + node.barycenterPosition).mapSize)
                .opacity(simulation.trailVisibility(node))
        }
    }
    
   
    // MARK: - Positioning

    private func position(for node: Node, size: CGSize) -> CGPoint {
        let position = simulation.applyAllTransformations(node.globalPosition)
        return CGPoint(x: position.x + size.width/2, y: -position.y + size.height/2)
    }
    
    private func orbitTransformation(_ orbit: Orbit) -> CGAffineTransform {
        let q1 = simd_quatd(angle: orbit.longitudeOfPeriapsis, axis: Vector.e3.simd)
        let q2 = simd_quatd(angle: -orbit.orbitalInclination, axis: orbit.lineOfNodes.simd)
        let q3 = simd_quatd(angle: -simulation.rotation.radians, axis: Vector.e3.simd)
        let q4 = simd_quatd(angle: -simulation.pitch.radians, axis: Vector.e1.simd)
        return CGAffineTransform(quaternion: q1 * q2 * q3 * q4)
    }

}
