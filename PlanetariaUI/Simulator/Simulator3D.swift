//
//  Simulator3D.swift
//
//
//  Created by Joe Rupertus on 11/8/23.
//

#if os(visionOS)
import SwiftUI
import PlanetariaData
import simd
import RealityKit

public struct Simulator3D: View {

    @ObservedObject private var simulation: Simulation

    public init(from simulation: Simulation) {
        self.simulation = simulation
    }
    
    public var body: some View {
        GeometryReader3D { geometry in
            Group {
//                ForEach(simulation.currentNodes, id: \.id) { node in
//                    trail(for: node, size: geometry.size)
//                }
                RealityView { content in
                    for entity in simulation.entities {
                        content.add(entity)
                    }
                } update: { content in
                    var lastEntities = Set(content.entities)
                    for entity in simulation.entities {
                        content.add(entity)
                        lastEntities.remove(entity)
                    }
                    for entity in lastEntities {
                        content.remove(entity)
                    }
                }
                .rotation3DEffect(Rotation3D(angle: .radians(-simulation.rotation.radians), axis: .y))
                .gesture(tapGesture)
                .simultaneousGesture(panGesture)
                .simultaneousGesture(zoomGesture)
            }
            .frame(width: geometry.size.width, height: geometry.size.height).frame(depth: geometry.size.depth)
            .onTapGesture {
                withAnimation {
                    simulation.select(nil)
                }
            }
            Circle().opacity(0).onAppear {
                simulation.setupDisplay(size: min(geometry.size.width, geometry.size.height))
            }
        }
    }
    
    
    // MARK: - Components
    
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
    
    
    // MARK: - Positioning
    
    private func orbitTransformation(_ orbit: Orbit) -> simd_quatd {
        let q1 = simd_quatd(angle: -orbit.longitudeOfPeriapsis, axis: Vector.referencePlane.simd)
        let q2 = simd_quatd(angle: -orbit.orbitalInclination, axis: orbit.lineOfNodes.simd)
        let q3 = simd_quatd(angle: simulation.rotation.radians, axis: Vector.referencePlane.simd)
        let q4 = simd_quatd(angle: -simulation.pitch.radians, axis: Vector.vernalEquinox.simd)
        return q4 * q3 * q2 * q1
    }
    
    
    // MARK: - Gestures
    
    private var tapGesture: some Gesture {
        SpatialTapGesture()
            .targetedToAnyEntity()
            .onEnded { value in
                print("tapped at \(value.location3D)")
                if let node = simulation.currentNodes.first(where: { $0.name == value.entity.name || $0.id == Int(value.entity.name) ?? -1 }) {
                    withAnimation {
                        simulation.select(node)
                    }
                }
            }
    }
    
    private var panGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                simulation.updateRotationGesture(with: value.translation3D.x)
            }
            .onEnded { value in
                simulation.completeRotationGesture(with: value.translation3D.x)
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
