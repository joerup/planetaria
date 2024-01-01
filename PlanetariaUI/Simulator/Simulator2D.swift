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
            .scaleEffect(simulation.introScale)
            #if os(iOS) || os(macOS)
            .simultaneousGesture(simulation.zoomGesture)
            .simultaneousGesture(simulation.panGesture)
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
                    simulation.select(nil)
                }
            }
            .onAppear {
                simulation.startDisplay(size: min(geometry.size.width, geometry.size.height), ratio: 1.5E+10 / min(geometry.size.width, geometry.size.height))
            }
            .onChange(of: geometry.size) { size in
                simulation.startDisplay(size: min(size.width, size.height), ratio: 1.5E+10 / min(size.width, size.height))
            }
        }
    }
    
    // MARK: - Components
    
    @ViewBuilder
    private func visual(for node: Node, size: CGSize) -> some View {
        let modelSize: CGFloat = 2 * simulation.applyScale(node.totalSize)
        
        ZStack {
            
            ObjectDot(node: node, modelSize: modelSize, isSelected: simulation.isSelected(node), noSelection: simulation.noSelection, isSystem: simulation.isSystem(node), isReference: simulation.isReference(node))
            
            // 3D Model
            #if os(iOS) || os(macOS) || os(tvOS)
            if let object = node.object, simulation.showModel(node) {
                Object3D(object: object, pitch: simulation.pitch, rotation: simulation.rotation)
                    .frame(width: 1.2 * modelSize, height: 1.2 * modelSize)
            }
            #endif
            
            // Text
            Text(node.object?.name ?? node.name)
                .font(.system(node.rank == .primary || simulation.isSelected(node) ? .caption : .caption2, design: .rounded))
                .foregroundColor(.white)
                .opacity(node.rank == .primary || simulation.isSelected(node) ? 0.7 : node.rank == .secondary ? 0.5 : 0)
                .opacity(simulation.isSelected(node) || simulation.noSelection ? 1.0 : 0.6)
                .opacity(simulation.showText(node) ? 1 : 0)
                .offset(y: 12 + simulation.applyScale(node.size))
        }
        .position(position(for: node, size: size))
        .transition(.opacity)
    }
    
    @ViewBuilder
    private func trail(for node: Node, size: CGSize) -> some View {
        if simulation.showOrbit(node), let orbit = node.orbit {
            let width: CGFloat = size.width
            let height: CGFloat = size.width * sqrt(1 - pow(orbit.eccentricity, 2))
            let offset: CGFloat = size.width * -orbit.eccentricity/2
            let trailScale: CGFloat = simulation.applyBaseScale(2 * orbit.semimajorAxis)/width
            let lineWidth: CGFloat = 2.5/(trailScale * simulation.scale)
            let totalWidth: CGFloat = width + lineWidth
            let totalHeight: CGFloat = height + lineWidth
            
            if totalWidth > 0, totalWidth.isFinite, totalHeight > 0, totalHeight.isFinite {
                ObjectTrail(node: node, orbit: orbit, isSelected: simulation.isSelected(node), noSelection: simulation.noSelection, centerOffset: offset/width, lineWidth: lineWidth, totalWidth: totalWidth, totalHeight: totalHeight)
                    .offset(x: offset)
                    .transformEffect(CGAffineTransform(translationX: -totalWidth/2, y: -totalHeight/2))
                    .transformEffect(orbitTransformation(orbit))
                    .transformEffect(CGAffineTransform(translationX: totalWidth/2, y: totalHeight/2))
                    .scaleEffect(trailScale * simulation.scale)
                    .offset(simulation.applyAllTransformations((node.parent?.position ?? .zero) + node.barycenterPosition).mapSize)
                    .opacity(simulation.showTrail(node) ? 1 : 0)
            }
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
