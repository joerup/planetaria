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
            .simultaneousGesture(areaPanGesture)
            .simultaneousGesture(turnGesture)
            .simultaneousGesture(areaTurnGesture)
            .simultaneousGesture(zoomGesture)
            .simultaneousGesture(areaZoomGesture)
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
    
    private var panGesture: some Gesture {
        DragGesture()
            .targetedToEntity(where: .has(InteractionComponent.self))
            .onChanged { value in
                updateDragGesture(with: value)
            }
            .onEnded { value in
                completeDragGesture(with: value)
            }
    }
    
    private var areaPanGesture: some Gesture {
        DragGesture()
            .targetedToEntity(where: .has(InteractionAreaComponent.self))
            .onChanged { value in
                updateDragGesture(with: value)
            }
            .onEnded { value in
                completeDragGesture(with: value)
            }
    }
    
    private var turnGesture: some Gesture {
        RotateGesture()
            .targetedToEntity(where: .has(InteractionComponent.self))
            .onChanged { value in
                simulation.updateRollGesture(with: value.rotation)
            }
            .onEnded { value in
                simulation.completeRollGesture(with: value.rotation)
            }
    }
    
    private var areaTurnGesture: some Gesture {
        RotateGesture()
            .targetedToEntity(where: .has(InteractionAreaComponent.self))
            .onChanged { value in
                simulation.updateRollGesture(with: value.rotation)
            }
            .onEnded { value in
                simulation.completeRollGesture(with: value.rotation)
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
    
    private var areaZoomGesture: some Gesture {
        MagnificationGesture()
            .targetedToEntity(where: .has(InteractionAreaComponent.self))
            .onChanged { value in
                simulation.updateScaleGesture(to: value.gestureValue)
            }
            .onEnded { value in
                simulation.completeScaleGesture(to: value.gestureValue)
            }
    }
    
    private let translationAngleFactor: CGFloat = .pi / 5
     
    private func updateDragGesture(with value: EntityTargetValue<DragGesture.Value>) {
        let start = value.convert(value.startLocation3D, from: .global, to: .scene)
        let end = value.convert(value.location3D, from: .global, to: .scene)
        
        simulation.updateRotationGesture(with: .radians(CGFloat(start.x - end.x) * translationAngleFactor))
        simulation.updatePitchGesture(with: .radians(CGFloat(start.y - end.y) * translationAngleFactor))
        simulation.updateScaleGesture(to: CGFloat(start.z / end.z))
    }
    
    private func completeDragGesture(with value: EntityTargetValue<DragGesture.Value>) {
        let start = value.convert(value.startLocation3D, from: .global, to: .scene)
        let end = value.convert(value.location3D, from: .global, to: .scene)
        
        simulation.completeRotationGesture(with: .radians(CGFloat(start.x - end.x) * translationAngleFactor))
        simulation.completePitchGesture(with: .radians(CGFloat(start.y - end.y) * translationAngleFactor))
        simulation.completeScaleGesture(to: CGFloat(start.z / end.z))
    }
    
    private func sphericalCoordinates(vector: SIMD3<Float>) -> (radius: Double, azimuth: Double, elevation: Double) {
        let x = vector.x
        let y = vector.y
        let z = vector.z

        // Radius: r = sqrt(x^2 + y^2 + z^2)
        let radius = sqrt(x * x + y * y + z * z)

        // Azimuth: θ = atan2(x, z)
        let azimuth = atan2(x, z)

        // Elevation: φ = atan2(y, sqrt(x^2 + z^2))
        let elevation = sqrt(x * x + z * z) != 0 ? atan2(y, sqrt(x * x + z * z)) : 0

        return (Double(radius), Double(azimuth), Double(elevation))
    }
}
#endif
