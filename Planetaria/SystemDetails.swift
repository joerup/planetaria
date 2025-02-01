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
    
    private let groups: [String:[Node]]

    init(system: SystemNode) {
        self.system = system
        
        self.primaryObjects = system.children(type: system.primaryCategory)
        self.secondaryObjects = system.children(type: system.secondaryCategory).filter({ $0.rank >= .secondary }).sorted { $0.id < $1.id }
        self.dwarfPlanets = system.children(type: .minor).filter { $0.rank >= .secondary && $0.category != system.primaryCategory }
        
        var groups: [String:[Node]] = [:]
        for child in system.children.filter({ $0.rank < .secondary }) {
            if let group = child.group {
                groups[group, default: []].append(child)
            }
        }
        self.groups = groups
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
                    SelectionRow(title: child.name, icon: child.rank >= .tertiary ? child.name : nil)
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
                    SelectionRow(title: child.name, icon: child.rank >= .tertiary ? child.name : nil)
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
                        SelectionRow(title: child.name, icon: child.rank >= .tertiary ? child.name : nil)
                    }
                }
            }
            
            // Other Groups
            if !groups.isEmpty {
                listSectionHeader("Other Objects")
                ForEach(groups.sorted(by: { $0.value.count > $1.value.count }), id: \.key) { group in
                    Button {
                        dismiss()
                    } label: {
                        SelectionRow(title: group.key, icon: "")
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
