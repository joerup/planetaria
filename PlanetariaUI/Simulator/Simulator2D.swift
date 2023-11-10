//
//  Simulator2D.swift
//  Planetaria
//
//  Created by Joe Rupertus on 6/9/23.
//

import SwiftUI
import PlanetariaData

public struct Simulator2D: View {
    
    @ObservedObject private var simulation: Simulation
    
    public init(from simulation: Simulation) {
        self.simulation = simulation
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                if simulation.isReferenceSystem {
                    Circle()
                        .foregroundColor(.init(white: 0.2))
                        .frame(width: 4)
//                        .position(position(for: system, size: geometry.size))
                }
                ForEach(simulation.allNodes) { node in
                    trail(for: node, size: geometry.size)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    visual(for: node, size: geometry.size)
                        .onTapGesture {
                            withAnimation {
                                simulation.select(node, size: geometry.size)
                            }
                        }
                    text(for: node, size: geometry.size)
                }
            }
            .background(Color.black)
            .scaleEffect(simulation.introScale)
            #if os(iOS) || os(macOS)
            .simultaneousGesture(simulation.zoomGesture(size: geometry.size))
            .simultaneousGesture(simulation.panGesture(size: geometry.size))
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
                    simulation.select(nil, size: geometry.size)
                }
            }
            .onAppear {
                simulation.defaultScaleRatio = 2E+10 / min(geometry.size.width, geometry.size.height)
                simulation.runIntro()
            }
        }
    }
    
    // MARK: - Components
    
    @ViewBuilder
    private func visual(for node: Node, size: CGSize) -> some View {
        let modelSize: CGFloat = 2 * simulation.applyScale(node.size)
        let dotSize: CGFloat = simulation.isSelected(node) ? 8 : node.rank == .primary ? 7 : 6
        
        ZStack {

            // Tap Area
            Circle()
                .fill(.black.opacity(0.01))
                .frame(width: dotSize * 3)

            // Dot
            Circle()
                .fill(node.color)
                .opacity(simulation.noSelection || simulation.isSelected(node) ? 1 : 0.6)
                .opacity(node.rank == .primary || simulation.isSelected(node) ? 1 : node.rank == .secondary ? 0.8 : 0.5)
                .opacity(cbrt(dotSize/modelSize-1.0))
                .frame(width: dotSize)
                .shadow(color: .white.opacity(simulation.isSelected(node) ? 1 : node.rank == .primary ? 0.6 : 0.2), radius: 5)

            // Target
            if simulation.isSelected(node) && dotSize > modelSize {
                Circle()
                    .stroke(Color.init(white: simulation.grayscale), lineWidth: 1)
                    .opacity(simulation.grayscale)
                    .frame(width: dotSize * 2)
                    .transition(.identity)
                    .onAppear {
                        simulation.grayscale = 0
                        withAnimation(.easeIn(duration: 1.5).repeatForever(autoreverses: true)) {
                            simulation.grayscale = 1
                        }
                    }
            }

            // 3D Model
            #if os(iOS) || os(macOS) || os(tvOS)
            if let object = node as? ObjectNode, simulation.showModel(node, size: size, modelSize: modelSize) {
                Object3D(object: object, pitch: simulation.pitch, rotation: simulation.rotation)
                    .frame(width: 1.2 * modelSize, height: 1.2 * modelSize)
            }
            #endif
        }
        .position(position(for: node, size: size))
        .transition(.opacity)
    }
    
    @ViewBuilder
    private func text(for node: Node, size: CGSize) -> some View {
        if simulation.showText(node, size: size) {
            Text(node.object?.name ?? node.name)
                .font(.system(node.rank == .primary || simulation.isSelected(node) ? .caption : .caption2, design: .rounded))
                .foregroundColor(.white)
                .opacity(node.rank == .primary || simulation.isSelected(node) ? 0.7 : node.rank == .secondary ? 0.5 : 0)
                .opacity(simulation.isSelected(node) ? 1.0 : simulation.noSelection ? 1.0 : 0.6)
                .position(position(for: node, size: size))
                .offset(y: 12)
        }
    }
    
    @ViewBuilder
    private func trail(for node: Node, size: CGSize) -> some View {
        if simulation.showTrail(node, size: size) {
            let width: CGFloat = size.width
            let height: CGFloat = size.width * sqrt(1 - pow(node.eccentricity, 2))
            let offset: CGFloat = size.width * -node.eccentricity/2
            let trailScale: CGFloat = simulation.applyBaseScale(2 * node.semimajorAxis)/width
            let lineWidth: CGFloat = 4/(trailScale * simulation.scale)
            let totalWidth: CGFloat = width + lineWidth
            let totalHeight: CGFloat = height + lineWidth
            
            if totalWidth > 0, totalWidth.isFinite, totalHeight > 0, totalHeight.isFinite {
                ObjectTrail(node: node, isSelected: simulation.isSelected(node), noSelection: simulation.noSelection, centerOffset: offset/width, lineWidth: lineWidth, totalWidth: totalWidth, totalHeight: totalHeight, size: size)
                    .offset(x: offset)
                    .scaleEffect(trailScale * simulation.scale)
                    .transformEffect(CGAffineTransform(translationX: -totalWidth/2, y: -totalHeight/2))
                    .transformEffect(orbitTransformation(for: node))
                    .transformEffect(CGAffineTransform(translationX: totalWidth/2, y: totalHeight/2))
                    .offset(simulation.applyAllTransformations((node.parent?.position ?? .zero) + node.barycenterPosition).mapSize)
            }
        }
    }
    
   
    // MARK: - Positioning

    private func position(for node: Node, size: CGSize) -> CGPoint {
        let position = simulation.applyAllTransformations(node.globalPosition)
        return CGPoint(x: position.x + size.width/2, y: -position.y + size.height/2)
    }
    
    private func orbitTransformation(for node: Node) -> CGAffineTransform {
        Matrix(rotation: node.longitudeOfPeriapsis)
            .applying(Matrix(rotation: node.orbitalInclination, about: node.lineOfNodes))
            .applying(Matrix(rotation: -simulation.rotation.radians))
            .applying(Matrix(rotation: simulation.pitch.radians, about: .e1))
            .transformation
    }
}
