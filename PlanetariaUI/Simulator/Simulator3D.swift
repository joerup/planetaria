//
//  Simulator3D.swift
//
//
//  Created by Joe Rupertus on 11/8/23.
//

import SwiftUI
import PlanetariaData
import simd

#if os(visionOS)
public struct Simulator3D: View {

    @ObservedObject private var simulation: Simulation

    public init(from simulation: Simulation) {
        self.simulation = simulation
    }
    
    public var body: some View {
        GeometryReader3D { geometry in
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
            .simultaneousGesture(simulation.panGesture)
            .simultaneousGesture(simulation.zoomGesture)
            .onTapGesture {
                withAnimation {
                    simulation.select(nil)
                }
            }
            Circle().opacity(0).onAppear {
                simulation.startDisplay(size: min(geometry.size.width, geometry.size.height))
            }
        }
    }
    
    // MARK: - Components
    
    @ViewBuilder
    private func visual(for node: Node, size: Size3D) -> some View {
        let position = position(for: node, size: size)
        Group {
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
        .offset(position.xy)
        .offset(z: position.z)
        .transition(.opacity)
    }
    
    @ViewBuilder
    private func trail(for node: Node, size: Size3D) -> some View {
        if simulation.showOrbit(node), let orbit = node.orbit {
            let width: CGFloat = size.width
            let height: CGFloat = size.width * orbit.ratio
            let scale: CGFloat = simulation.applyBaseScale(orbit.width)/width
            let lineWidth: CGFloat = 2.5/(scale * simulation.scale)
            let totalWidth: CGFloat = width + lineWidth
            let totalHeight: CGFloat = height + lineWidth
            let transformation = orbitTransformation(orbit)
            
            OrbitTrail(orbit: orbit, isSelected: simulation.isSelected(node), noSelection: simulation.noSelection,
                       color: node.color ?? .gray, full: node.rank == .primary || simulation.isSelected(node),
                       lineWidth: lineWidth, totalWidth: totalWidth, totalHeight: totalHeight)
                .scaleEffect(scale * simulation.scale)
                .rotation3DEffect(.radians(Double(transformation.angle)), axis: RotationAxis3D(x: transformation.axis.x, y: transformation.axis.y, z: transformation.axis.z))
                .rotation3DEffect(.degrees(90), axis: .x)
                .opacity(simulation.trailVisibility(node))
        }
    }
    
    private func position(for node: Node, size: Size3D) -> (xy: CGSize, z: CGFloat) {
        let position = simulation.applyAllTransformations(node.globalPosition)
        return (xy: CGSize(width: position.x, height: -position.z), z: -position.y)
    }
    
    private func orbitTransformation(_ orbit: Orbit) -> simd_quatd {
        let q1 = simd_quatd(angle: -orbit.longitudeOfPeriapsis, axis: Vector.e3.simd)
        let q2 = simd_quatd(angle: -orbit.orbitalInclination, axis: orbit.lineOfNodes.simd)
        let q3 = simd_quatd(angle: simulation.rotation.radians, axis: Vector.e3.simd)
        let q4 = simd_quatd(angle: simulation.pitch.radians, axis: Vector.e1.simd)
        return q4 * q3 * q2 * q1
    }
}
#endif
