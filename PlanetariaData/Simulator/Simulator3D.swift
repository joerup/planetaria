//
//  Simulator3D.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 11/8/23.
//

import SwiftUI
import RealityKit

#if os(visionOS)
public struct Simulator<UI: View>: View {
    
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    @ObservedObject private var simulation: Simulation
    
    private var ui: () -> UI

    public init(for simulation: Simulation, ui: @escaping () -> UI) {
        self.simulation = simulation
        self.ui = ui
    }
    
    public var body: some View {
        GeometryReader3D { geometry in
            RealityView { content, attachments in
                content.add(simulation.rootEntity)
                if let attachment = attachments.entity(for: "attachment") {
                    simulation.rootEntity.attachmentPoint.addChild(attachment)
                }
            } attachments: {
                Attachment(id: "attachment") {
                    ui().glassBackgroundEffect()
                }
            }
            .gesture(tapGesture)
            .simultaneousGesture(panGesture)
            .simultaneousGesture(areaPanGesture)
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
//                let start = sphericalCoordinates(vector: simulation.rootEntity.interactionArea.position(relativeTo: nil))
//                let end = sphericalCoordinates(vector: value.convert(value.location3D, from: .global, to: .scene))
//                simulation.completeRotationGesture(with: -.radians(end.azimuth - start.azimuth))
//                simulation.completePitchGesture(with: .radians(end.elevation - start.elevation))
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
     
    private func updateDragGesture(with value: EntityTargetValue<DragGesture.Value>) {
        let start = sphericalCoordinates(vector: value.convert(value.startLocation3D, from: .global, to: .scene))
        let end = sphericalCoordinates(vector: value.convert(value.location3D, from: .global, to: .scene))
        
        simulation.updateRotationGesture(with: -.radians(end.azimuth - start.azimuth))
        simulation.updatePitchGesture(with: .radians(end.elevation - start.elevation))
        simulation.updateScaleGesture(to: start.radius / end.radius)
    }
    
    private func completeDragGesture(with value: EntityTargetValue<DragGesture.Value>) {
        let start = sphericalCoordinates(vector: value.convert(value.startLocation3D, from: .global, to: .scene))
        let end = sphericalCoordinates(vector: value.convert(value.location3D, from: .global, to: .scene))
        
        simulation.completeRotationGesture(with: -.radians(end.azimuth - start.azimuth))
        simulation.completePitchGesture(with: .radians(end.elevation - start.elevation))
        simulation.completeScaleGesture(to: start.radius / end.radius)
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
