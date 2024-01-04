//
//  DebugMenu.swift
//
//
//  Created by Joe Rupertus on 12/26/23.
//

import SwiftUI
import PlanetariaData
 
struct DebugMenu: View {
    
    @ObservedObject var simulation: Simulation
    
    @State private var showAll: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Root: \(simulation.rootNode?.name ?? "N/A")")
            Text("Reference: \(simulation.focusNode?.name ?? "N/A")")
            Text("System: \(simulation.selectedSystem?.name ?? "N/A")")
            Text("Object: \(simulation.selectedObject?.name ?? "N/A")")
            Text("Screen Size: \(simulation.unapplyScale(simulation.size)) km")
            
            Text("\(simulation.currentNodes.count)/\(simulation.allNodes.count) nodes visible")
            Text("\(simulation.currentBodies.count) bodies")
            Text("\(simulation.currentNodes.filter({ simulation.showOrbit($0) }).count) orbits")
            
            Button {
                showAll.toggle()
            } label: {
                Text("Show \(showAll ? "Visible" : "All")")
            }
            
            List(showAll ? simulation.allNodes : simulation.currentNodes, id: \.id) { node in
                Button {
                    simulation.select(node)
                } label: {
                    HStack {
                        indicator(simulation.currentNodes.contains(where: { $0.matches(node) }), color: .green)
                        
                        Text(node.name)
                            .foregroundStyle(color(for: node))
                        Spacer()
                        
                        indicator(simulation.currentBodies.contains(where: { $0.matches(node) }), color: .red)
                        indicator(simulation.showOrbit(node) && simulation.currentNodes.contains(where: { $0.matches(node) }), color: .blue)
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
        if simulation.isSelected(node) {
            return .pink
        }
        return .gray
    }
}
