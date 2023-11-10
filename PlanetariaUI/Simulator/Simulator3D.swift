//
//  Simulator3D.swift
//
//
//  Created by Joe Rupertus on 11/8/23.
//

import SwiftUI
import PlanetariaData

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
            HStack(spacing: 0) {
                ForEach(Array(zip(simulation.allNodes.indices, simulation.allNodes)), id: \.0) { index, node in
                    ZStack {
                        trail(for: node, size: geometry.size.reduced)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                        visual(for: node, size: geometry.size.reduced)
                        text(for: node, size: geometry.size.reduced)
                    }
                    .frame(depth: geometry.size.depth)
                    .offset(x: -geometry.size.width*CGFloat(index))
                    .onTapGesture {
                        withAnimation {
                            dismissWindow(id: "details")
                            openWindow(id: "details")
                            simulation.select(node, size: geometry.size.reduced)
                        }
                    }
                }
            }
            .simultaneousGesture(simulation.zoomGesture(size: geometry.size.reduced))
            .simultaneousGesture(simulation.panGesture(size: geometry.size.reduced))
            .onTapGesture {
                withAnimation {
                    dismissWindow(id: "details")
                    simulation.select(nil, size: geometry.size.reduced)
                }
            }
            .onAppear {
                simulation.defaultScaleRatio = 2E+10 / min(geometry.size.width, geometry.size.depth)
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
    private func visual(for node: Node, size: CGSize) -> some View {
        let modelSize: CGFloat = 2 * simulation.applyScale(node.size)
        let dotSize: CGFloat = simulation.isSelected(node) ? 8 : node.rank == .primary ? 7 : 6
        let offset = simulation.applyHalfTransformations(node.globalPosition)
        
        ZStack {
            // Dot
            Circle()
                .fill(node.color)
                .frame(width: dotSize)
                .offset(x: offset.x, y: -offset.z)
                .offset(z: -offset.y)
            
            // 3D Model
            if let object = node as? ObjectNode, object.name != "Sun", simulation.showModel(node, size: size, modelSize: modelSize) {
                Object3D(object: object, pitch: simulation.pitch, rotation: simulation.rotation)
                    .frame(width: 1.2 * modelSize, height: 1.2 * modelSize)
                    .offset(x: offset.x, y: -offset.z)
                    .offset(z: -offset.y)
            }
        }
    }
    
    @ViewBuilder
    private func text(for node: Node, size: CGSize) -> some View {
        let offset = simulation.applyHalfTransformations(node.globalPosition)
        
        if simulation.showText(node, size: size) {
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
                    .rotationEffect(-.radians(node.longitudeOfPeriapsis))
                    .rotation3DEffect(-.radians(node.orbitalInclination), axis: node.lineOfNodes.floatArray)
                    .rotation3DEffect(.degrees(90), axis: .x)
            }
        }
    }
}
#endif
