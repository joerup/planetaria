//
//  SystemDetails.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/10/23.
//

import SwiftUI
import PlanetariaData

struct SystemDetails: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var simulation: Simulation
    
    private let system: SystemNode
    
    private let primaryObjects: [Node]
    private let secondaryObjects: [Node]
    private let dwarfPlanets: [Node]

    init(system: SystemNode) {
        self.system = system
        
        self.primaryObjects = system.children(type: system.primaryCategory)
        self.secondaryObjects = system.children(type: system.secondaryCategory).sorted { $0.id < $1.id }
        self.dwarfPlanets = system.children(types: [.asteroid, .tno]).filter { $0.category != system.primaryCategory }
    }
    
    var body: some View {
        ScrollSheet(title: "\(system.name) System", backButton: backButton, backAction: backAction) {
            list
        }
        .fontDesign(.rounded)
    }
    
    private var list: some View {
        VStack(alignment: .leading) {
            
            // Primary Objects (Stars or Planets)
            ForEach(primaryObjects) { child in
                Button {
                    if !simulation.isSelected(child) {
                        simulation.selectObject(child)
                    }
                    dismiss()
                } label: {
                    SelectionRow(title: child.name, icon: child.name)
                }
            }
            
            // Secondary Objects (Planets or Moons)
            listSectionHeader("\(system.secondaryCategory?.text ?? "")s")
            ForEach(secondaryObjects) { child in
                Button {
                    if !simulation.isSelected(child) {
                        simulation.selectObject(child)
                    }
                    dismiss()
                } label: {
                    SelectionRow(title: child.name, icon: child.name)
                }
            }
            
            // Dwarf Planets
            if !dwarfPlanets.isEmpty {
                listSectionHeader("Dwarf Planets")
                ForEach(dwarfPlanets) { child in
                    Button {
                        if !simulation.isSelected(child) {
                            simulation.selectObject(child)
                        }
                        dismiss()
                    } label: {
                        SelectionRow(title: child.name, icon: child.name)
                    }
                }
            }
        }
        .foregroundStyle(.white)
        .padding(.vertical)
        .tint(nil)
    }
    
    @ViewBuilder
    private func listSectionHeader(_ title: String) -> some View {
        Spacer().frame(height: 20)
        Text(title)
            .textCase(.uppercase)
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .foregroundStyle(.secondary)
            .dynamicTypeSize(..<DynamicTypeSize.xxLarge)
            #if os(macOS)
            .font(.headline)
            .padding(.bottom, 5)
            #else
            .font(.subheadline)
            #endif
            .padding(.horizontal)
    }
    
    private var backButton: String? {
        guard let parent = system.parent else { return nil }
        return "\(parent.name) System"
    }
    
    private var backAction: (() -> Void)? {
        guard let _ = system.parent else { return nil }
        return { simulation.leaveSystem() }
    }
}
