//
//  NodeDebugMenu.swift
//
//
//  Created by Joe Rupertus on 12/26/23.
//

import SwiftUI
import PlanetariaData

public struct NodeDebugMenu: View {
    
    @ObservedObject var simulation: Simulation
    
    public init(from simulation: Simulation) {
        self.simulation = simulation
    }
    
    @State private var showAll: Bool = false
    
    public var body: some View {
        VStack(alignment: .leading) {
            
            Text("Root: \(simulation.rootNode?.name ?? "N/A")")
            Text("Reference: \(simulation.referenceNode?.name ?? "N/A")")
            Text("System: \(simulation.selectedSystem?.name ?? "N/A")")
            Text("Object: \(simulation.selectedObject?.name ?? "N/A")")
            Text("Screen Size: \(simulation.unapplyScale(simulation.size)) km")
            Text("\(simulation.nodes.count)/\(simulation.allNodes.count) visible")
            
            Button {
                showAll.toggle()
            } label: {
                Text("Show \(showAll ? "Visible" : "All")")
            }
            
            List(showAll ? simulation.allNodes : simulation.nodes, id: \.id) { node in
                Button {
                    simulation.select(node)
                } label: {
                    HStack {
                        Text(node.name)
                            .foregroundStyle(color(for: node))
                        Spacer()
                        
                        Text("\(node.rank.amount)")
                        
                        if let object = node.object {
                            indicator(simulation.showBody(object), color: .red)
                        }
                        indicator(simulation.showOrbit(node), color: .blue)
                    }
                }
                .buttonStyle(.plain)
            }
            .listStyle(.plain)
        }
        .padding()
    }
    
    private func indicator(_ active: Bool, color: Color) -> some View {
        Circle()
            .fill(active ? color : .gray)
            .frame(width: 10)
    }
    
    private func color(for node: Node) -> Color {
//        if simulation.isSelected(node) {
//            return .pink
//        }
//        else if simulation.nodes.contains(node) {
//            return .mint
//        }
//        else {
//            return .gray
//        }
        return .gray
    }
}
