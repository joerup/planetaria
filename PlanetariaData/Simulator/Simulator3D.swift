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
            RealityView { content, attachments in
                let entity = simulation.rootEntity
                content.add(entity)
            } update: { content, attachments in
                for entity in simulation.entities {
                    guard let node = entity.component(SimulationComponent.self)?.node else { continue }
                    if let label = attachments.entity(for: "\(node.id)-label") {
                        transformLabel(label, position: entity.position, node: node)
                        content.add(label)
                    }
                    if let target = attachments.entity(for: "\(node.id)-target") {
                        transformTarget(target, position: entity.position, node: node)
                        content.add(target)
                    }
                }
            } attachments: {
                ForEach(simulation.entities, id: \.self) { entity in
                    if let node = entity.component(SimulationComponent.self)?.node {
                        Attachment(id: "\(node.id)-label") {
                            labelAttachment(node: node)
                        }
                        Attachment(id: "\(node.id)-target") {
                            targetAttachment(node: node)
                        }
                    }
                }
            }
            .rotation3DEffect(Rotation3D(angle: .radians(-simulation.rotation.radians), axis: .y))
            .gesture(tapGesture)
            .simultaneousGesture(panGesture)
            .simultaneousGesture(zoomGesture)
            .frame(width: geometry.size.width, height: geometry.size.height).frame(depth: geometry.size.depth)
            .onAppear {
                simulation.setBounds(.init(width: geometry.size.width, height: geometry.size.height))
            }
        }
    }
    
    private func labelAttachment(node: Node) -> some View {
        Text(node.object?.name ?? node.name)
            .font(.callout)
            .opacity(simulation.isSelected(node) ? 1 : simulation.noSelection ? 0.7 : 0.4)
            .opacity(simulation.labelVisible(node) ? 1 : 0)
            .onTapGesture {
                simulation.selectObject(node)
            }
    }
    private func transformLabel(_ label: Entity, position: SIMD3<Float>, node: Node) {
        label.isEnabled = simulation.labelVisible(node)
        label.position = simulation.rootEntity.orientation.act(position) + [0, -6 * simulation.entityThickness, 0]
        label.orientation = simulation.rootEntity.orientation.inverse
    }
    
    
    private func targetAttachment(node: Node) -> some View {
        Circle()
            .strokeBorder(.white, lineWidth: 1)
            .frame(width: 4 * simulation.screenThickness)
            .opacity(simulation.isSelected(node) ? 1 : 0)
            .onTapGesture {
                simulation.selectObject(node)
            }
    }
    private func transformTarget(_ target: Entity, position: SIMD3<Float>, node: Node) {
        target.isEnabled = simulation.labelVisible(node)
        target.position = simulation.rootEntity.orientation.act(position)
        target.orientation = simulation.rootEntity.orientation.inverse
    }
    
    
    private var tapGesture: some Gesture {
        SpatialTapGesture()
            .targetedToAnyEntity()
            .onEnded { value in
                if let node = value.entity.parent?.component(SimulationComponent.self)?.node {
                    simulation.selectObject(node)
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
