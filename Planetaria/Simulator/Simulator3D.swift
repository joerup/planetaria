//
//  Simulator3D.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 11/8/23.
//

import SwiftUI
import RealityKit

#if os(visionOS)
public struct Simulator: View {
    
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    @ObservedObject private var simulation: Simulation

    public init(for simulation: Simulation) {
        self.simulation = simulation
    }
    
    public var body: some View {
        GeometryReader3D { geometry in
            RealityView { content in
                content.add(simulation.rootEntity)
            }
            .gesture(tapGesture)
            .simultaneousGesture(panGesture)
            .simultaneousGesture(zoomGesture)
            .frame(width: geometry.size.width, height: geometry.size.height).frame(depth: geometry.size.depth)
            .onAppear {
                simulation.rootEntity.setSizes(.init(width: 2 * geometry.size.width, height: 2 * geometry.size.height), dynamicTypeSize)
            }
            .onChange(of: dynamicTypeSize) { _, dynamicTypeSize in
                simulation.rootEntity.setSizes(.init(width: 2 * geometry.size.width, height: 2 * geometry.size.height), dynamicTypeSize)
            }
            .onChange(of: scenePhase) { _, _ in
                Entity.registerAll()
            }
        }
    }
    
    private var tapGesture: some Gesture {
        SpatialTapGesture()
            .targetedToEntity(where: .has(InteractionComponent.self))
            .onEnded { value in
                if let node = value.entity.component(InteractionComponent.self)?.node {
                    simulation.selectObject(node)
                }
            }
    }
    
    private let translationAngleFactor: CGFloat = .pi / 400
    private var panGesture: some Gesture {
        DragGesture()
            .targetedToEntity(where: .has(InteractionComponent.self))
            .onChanged { value in
                simulation.updateRotationGesture(with: .radians(-value.translation3D.x * translationAngleFactor))
                simulation.updatePitchGesture(with: .radians(value.translation3D.y * translationAngleFactor))
            }
            .onEnded { value in
                simulation.completeRotationGesture(with: .radians(-value.translation3D.x * translationAngleFactor))
                simulation.completePitchGesture(with: .radians(value.translation3D.y * translationAngleFactor))
            }
    }
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .targetedToEntity(where: .has(InteractionComponent.self))
            .onChanged { value in
                simulation.updateScaleGesture(to: value.gestureValue)
            }
            .onEnded { value in
                simulation.completeScaleGesture(to: value.gestureValue)
            }
    }
}
#endif
