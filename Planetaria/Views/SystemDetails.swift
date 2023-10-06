//
//  SystemDetails.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/10/23.
//

import SwiftUI
import PlanetariaData

struct SystemDetails: View {
    
    var system: SystemNode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(system.name) System")
                .font(.system(.title, design: .rounded, weight: .semibold))
                .padding(.vertical, 10)
                .padding(.top, 5)
                .padding(.horizontal)
            ScrollView {
                VStack {
                    section(category: .star)
                    section(category: .planet)
                    section(category: .moon)
                    section(category: .asteroid)
                    section(category: .tno)
                }
                .padding(.horizontal)
            }
        }
        .background(Color.init(white: 0.1))
    }
    
    @ViewBuilder
    func section(category: Node.Category) -> some View {
        let nodes = system.children(category: category)
        if !nodes.isEmpty {
            VStack(alignment: .leading) {
                Text("\(category.rawValue.capitalized)")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .padding([.leading, .top])
                ForEach(nodes) { node in
                    NewDetailRow(node: node)
                }
            }
        }
    }
}
