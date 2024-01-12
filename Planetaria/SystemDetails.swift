//
//  SystemDetails.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/10/23.
//

import SwiftUI
import PlanetariaUI
import PlanetariaData

struct SystemDetails: View {
    
    @EnvironmentObject var simulation: Simulation
    
    private var system: System
    
    private var categories: [String] = []
    private var predicates: [String : (Node) -> Bool] = [:]
    
    init(system: System) {
        self.system = system
        
        if system.children.contains(where: { $0.category == .star }) {
            categories = ["Main","Planets","Dwarf Planets","Other"]
            predicates = [
                "Main" : { $0.category == .star },
                "Planets" : { $0.category == .planet },
                "Dwarf Planets" : { ($0.rank == .primary || $0.rank == .secondary) && ($0.category == .tno || $0.category == .asteroid) },
                "Other" : { $0.category != .star && $0.category != .planet && !(($0.rank == .primary || $0.rank == .secondary) && ($0.category == .tno || $0.category == .asteroid)) }
            ]
        } else {
            categories = ["Main"]
            predicates = [
                "Main" : { $0.category != .moon },
                "Moons" : { $0.category == .moon }
            ]
//           let groups = system.children.compactMap(\.properties?.group).uniqued()
//           for group in groups {
//                categories += [group]
//               predicates[group] = { $0.properties?.group == group }
//            }
            categories += ["Moons"]
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let parent = system.parent {
                Button {
                    simulation.leaveSystem()
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                            .imageScale(.large)
                            .fontWeight(.semibold)
                            .padding(.leading, -5)
                        Text("\(parent.name) System")
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, -5)
            }
            
            #if os(macOS)
            Text("\(system.name) System")
                .font(.system(.largeTitle, design: .default, weight: .bold))
                .padding(.top, 10)
                .padding(.horizontal)
                .padding(.bottom)
            #else
            Text("\(system.name) System")
                .font(.system(.title, design: .default, weight: .semibold))
                .padding()
            #endif
            
            ScrollView {
                list
            }
        }
        .navigationTitle("\(system.name) System")
        .tint(.mint)
    }
    
    private var list: some View {
        VStack(alignment: .leading) {
            ForEach(categories, id: \.self) { category in
                if let predicate = predicates[category] {
                    let nodes = system.children.compactMap(\.object).filter({ predicate($0) })
                    if !nodes.isEmpty {
                        if category != "Main" {
                            Spacer().frame(height: 20)
                            Text(category)
                                .textCase(.uppercase)
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray)
                                #if os(macOS)
                                .font(.headline)
                                .padding(.bottom, 5)
                                #else
                                .font(.subheadline)
                                .padding(.horizontal, 5)
                                #endif
                                .padding(.horizontal)
                        }
                        ForEach(category == "Planets" ? nodes.sorted(by: { $0.id < $1.id }) : nodes, id: \.self) { object in
                            Button {
                                withAnimation {
                                    simulation.select(object)
                                }
                            } label: {
                                ObjectRow(object: object)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .padding(.bottom)
    }
}
