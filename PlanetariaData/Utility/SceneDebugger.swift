//
//  SceneDebugger.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 10/20/24.
//

import SwiftUI
import RealityKit

public struct SceneDebugger: View {
    
    @ObservedObject var simulation: Simulation
    
    public init(simulation: Simulation) {
        self.simulation = simulation
    }
    
    public var body: some View {
        List {
            ForEach(simulation.rootEntity.children.map { $0 }) { entity in
                if let configuration = entity.component(SimulationComponent.self) {
                    Button {
                        simulation.selectObject(configuration.node)
                    } label: {
                        HStack {
                            Text(configuration.node.name)
                                .foregroundStyle(nameColor(configuration.node))
                            Spacer()
                            indicator(entity.component(InteractionComponent.self)?.entity.isEnabled, letter: "I", color: .blue)
                            indicator(entity.component(BodyComponent.self)?.model.isEnabled, letter: "B", color: .yellow)
                            indicator(entity.component(TargetComponent.self)?.model.isEnabled, letter: "T", color: .red)
                            indicator(entity.component(LabelComponent.self)?.model.isEnabled, letter: "L", color: .orange)
                            if #available(iOS 18.0, macOS 15.0, visionOS 2.0, *) {
                                indicator(entity.component(OrbitComponent.self)?.model.isEnabled, letter: "O", color: .green)
                            } else {
                                indicator(entity.component(OrbitComponentLegacy.self)?.model.isEnabled, letter: "O", color: .green)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func nameColor(_ node: Node) -> some ShapeStyle {
        if simulation.isSelected(node) {
            return .mint
        } else if simulation.isInSystem(node) {
            return .white
        } else {
            return .gray
        }
    }
    
    private func indicator(_ isEnabled: Bool?, letter: String, color: Color) -> some View {
        Text(letter)
            .font(.caption)
            .foregroundStyle((isEnabled ?? false) ? color : .gray)
            .opacity(isEnabled == nil ? 0 : 1)
    }
}
