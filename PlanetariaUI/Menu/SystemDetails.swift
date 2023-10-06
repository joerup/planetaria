//
//  SystemDetails.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/10/23.
//

import SwiftUI
import PlanetariaData

public struct SystemDetails: View {
    
    @EnvironmentObject var spacetime: Spacetime
    
    private var system: SystemNode
    
    @Binding private var searching: Bool
    
    public init(system: SystemNode, searching: Binding<Bool>) {
        self.system = system
        self._searching = searching
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("\(system.name) System")
                    .font(.system(.title, design: .default, weight: .semibold))
                    .padding(.vertical, 10)
                    .padding(.top, 5)
                    .padding(.horizontal)
                Spacer()
                Button {
                    withAnimation {
                        searching = true
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                        .fontWeight(.bold)
                        .padding()
                }
            }
            ScrollView {
                VStack {
                    // Stars
                    objectRows(nodes: system.children(category: .star))
                    
                    // Planets
                    objectRows("Planets", nodes: system.children(category: .planet))
                    
                    // Moons
                    objectRows("Moons", nodes: system.children(category: .moon))
                    objectRows("Moons", nodes: system.grandchildGroups(category: .moon), subsystems: true)
                }
            }
        }
        .background(Color.init(white: 0.1))
    }
    
    @ViewBuilder
    private func objectRows(_ title: String? = nil, nodes: [Node], subsystems: Bool = false) -> some View {
        VStack(alignment: .leading) {
            if let title, !nodes.isEmpty {
                Text(title)
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .padding([.horizontal, .top])
            }
            ForEach(nodes) { node in
                if let object = node.object {
                    if subsystems, node.category == .system {
                        Button {
                            withAnimation {
                                spacetime.system = system
                            }
                        } label: {
                            ObjectRow(object: object)
                        }
                    } else {
                        Button {
                            withAnimation {
                                spacetime.object = object
                            }
                        } label: {
                            ObjectRow(object: object)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
