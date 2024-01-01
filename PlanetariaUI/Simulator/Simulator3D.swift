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
        
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow

    @ObservedObject private var simulation: Simulation

    public init(from simulation: Simulation) {
        self.simulation = simulation
    }
    
    public var body: some View {
        GeometryReader3D { geometry in
            ForEach(simulation.allNodes) { node in
                ZStack {
                    trail(for: node, size: geometry.size)
                    visual(for: node, size: geometry.size)
                    text(for: node, size: geometry.size)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .onTapGesture {
                    withAnimation {
                        dismissWindow(id: "details")
                        openWindow(id: "details")
                        simulation.select(node)
                    }
                }
            }
            .simultaneousGesture(simulation.panGesture)
            .simultaneousGesture(simulation.zoomGesture)
            .onTapGesture {
                withAnimation {
                    dismissWindow(id: "details")
                    simulation.select(nil)
                }
            }
            .onAppear {
                simulation.size = min(geometry.size.width, geometry.size.height)
                simulation.defaultScaleRatio = 2E+10 / min(geometry.size.width, geometry.size.height)
                simulation.runIntro()
            }
        }
//        .overlay {
//            VStack {
//                ForEach(simulation.allNodes, id: \.self) { node in
//                    Text("\(node.name) \(simulation.applyHalfTransformations(node.globalPosition).text)")
//                }
//                Text(simulation.offset.text)
//                Text(simulation.unapplyScale(Vector(2000, 2000, 2000)).text)
//            }
//        }
    }
    
    // MARK: - Components
    
    @ViewBuilder
    private func visual(for node: Node, size: Size3D) -> some View {
        if simulation.showVisual(node) {
            //        let modelSize: CGFloat = 2 * simulation.applyScale(node.size)
            let dotSize: CGFloat = simulation.isSelected(node) ? 8 : node.rank == .primary ? 7 : 6
            let offset = simulation.applyHalfTransformations(node.globalPosition)
            
            ZStack {
                // Dot
                Circle()
                    .fill(node.color)
                    .frame(width: dotSize)
                    .offset(x: offset.x, y: -offset.z)
                    .offset(z: -offset.y)
                
                //            // 3D Model
                //            if let object = node as? ObjectNode, object.name != "Sun", simulation.showModel(node, size: size, modelSize: modelSize) {
                //                Object3D(object: object, pitch: simulation.pitch, rotation: simulation.rotation)
                //                    .frame(width: 1.2 * modelSize, height: 1.2 * modelSize)
                //                    .offset(x: offset.x, y: -offset.z)
                //                    .offset(z: -offset.y)
                //            }
            }
        }
    }
    
    @ViewBuilder
    private func text(for node: Node, size: Size3D) -> some View {
        if simulation.showText(node) {
            let offset = simulation.applyHalfTransformations(node.globalPosition)
            Text(node.object?.name ?? node.name)
                .font(.system(node.rank == .primary || simulation.isSelected(node) ? .caption : .caption2, design: .rounded))
                .foregroundColor(.white)
                .opacity(node.rank == .primary || simulation.isSelected(node) ? 0.7 : node.rank == .secondary ? 0.5 : 0)
                .opacity(simulation.isSelected(node) || simulation.noSelection ? 1.0 : 0.6)
//                .rotation3DEffect(.degrees(90), axis: .x)
                .offset(x: offset.x, y: -offset.z - 12)
                .offset(z: -offset.y + 12)
        }
    }
    
    @ViewBuilder
    private func trail(for node: Node, size: Size3D) -> some View {
        if simulation.showTrail(node) {
            let width: CGFloat = size.width
            let height: CGFloat = size.width * sqrt(1 - pow(node.eccentricity, 2))
            let offset: CGFloat = size.width * -node.eccentricity/2
            let trailScale: CGFloat = simulation.applyBaseScale(2 * node.semimajorAxis)/width
            let lineWidth: CGFloat = 4/(trailScale * simulation.scale)
            let totalWidth: CGFloat = width + lineWidth
            let totalHeight: CGFloat = height + lineWidth
            let transformation = orbitTransformation(for: node)
            
            if totalWidth > 0, totalWidth.isFinite, totalHeight > 0, totalHeight.isFinite {
                ObjectTrail(node: node, isSelected: simulation.isSelected(node), noSelection: simulation.noSelection, centerOffset: offset/width, lineWidth: lineWidth, totalWidth: totalWidth, totalHeight: totalHeight)
                    .offset(x: offset)
                    .scaleEffect(trailScale * simulation.scale)
                    .rotation3DEffect(.radians(Double(transformation.angle)),
                      axis: RotationAxis3D(
                        x: transformation.axis.x,
                        y: transformation.axis.y,
                        z: transformation.axis.z
                    ))
                    .rotation3DEffect(.degrees(90), axis: .x)
            }
        }
    }
    
    private func orbitTransformation(for node: Node) -> simd_quatd {
        let q1 = simd_quatd(angle: -node.longitudeOfPeriapsis, axis: Vector.e3.simd)
        let q2 = simd_quatd(angle: -node.orbitalInclination, axis: node.lineOfNodes.simd)
        let q3 = simd_quatd(angle: simulation.rotation.radians, axis: Vector.e3.simd)
        let q4 = simd_quatd(angle: simulation.pitch.radians, axis: Vector.e1.simd)
        return q4 * q3 * q2 * q1
    }
}
#endif
