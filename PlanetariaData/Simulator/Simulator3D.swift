//
//  Simulator3D.swift
//
//
//  Created by Joe Rupertus on 11/8/23.
//

import SwiftUI
import RealityKit

#if os(visionOS)
public struct Simulator: View {

    @ObservedObject private var simulation: Simulation

    public init(from simulation: Simulation) {
        self.simulation = simulation
    }
    
    public var body: some View {
        GeometryReader3D { geometry in
            Group {
                RealityView { content in
                    content.add(simulation.rootEntity)
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
        }
    }
    
    private var tapGesture: some Gesture {
        SpatialTapGesture()
            .targetedToAnyEntity()
            .onEnded { value in
                if let entity = value.entity as? SimulationEntity ?? value.entity.parent as? SimulationEntity, let node = entity.node {
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
