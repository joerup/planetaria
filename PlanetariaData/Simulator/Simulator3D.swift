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
                RealityView { content, attachments in
                    let entity = simulation.rootEntity
                    content.add(entity)
                    if let env = try? await EnvironmentResource(named: "light", in: .module) {
                        let iblComponent = ImageBasedLightComponent(source: .single(env), intensityExponent: 7.95)
                        entity.components[ImageBasedLightComponent.self] = iblComponent
                        entity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: entity))
                    }
                } update: { content, attachments in
                    for entity in simulation.entities {
                        if let node = entity.component(SimulationComponent.self)?.node {
                            if let label = attachments.entity(for: "\(node.id)-label") {
                                label.position = simulation.rootEntity.orientation.act(entity.position) + [0, -0.01, 0]
                                label.orientation = simulation.rootEntity.orientation.inverse
                                content.add(label)
                            }
                            if let target = attachments.entity(for: "\(node.id)-target") {
                                target.position = simulation.rootEntity.orientation.act(entity.position)
                                target.orientation = simulation.rootEntity.orientation.inverse
                                content.add(target)
                            }
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
            }
            .frame(width: geometry.size.width, height: geometry.size.height).frame(depth: geometry.size.depth)
            .onTapGesture {
                simulation.selectObject(nil)
            }
        }
    }
    
    private func labelAttachment(node: Node) -> some View {
        Text(node.object?.name ?? node.name)
            .font(.caption)
            .opacity(simulation.isSelected(node) ? 1 : simulation.noSelection ? 0.7 : 0.4)
            .opacity(simulation.labelVisible(node) ? 1 : 0)
            .onTapGesture {
                simulation.selectObject(node)
            }
    }
    
    private func targetAttachment(node: Node) -> some View {
        Circle()
            .stroke(.white, lineWidth: 1)
            .frame(width: 16)
            .opacity(simulation.isSelected(node) ? 1 : 0)
            .onTapGesture {
                simulation.selectObject(node)
            }
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
