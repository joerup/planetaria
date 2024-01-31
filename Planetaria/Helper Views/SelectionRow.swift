//
//  SelectionRow.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/10/23.
//

import SwiftUI
import PlanetariaData

struct SelectionRow: View {
    
    var name: String
    var icon: String?
    
    var body: some View {
        #if os(macOS)
        HStack {
            if let icon {
                ObjectIcon(icon: icon, size: 30)
                    .scaleEffect(1.2)
            }
            Text(name)
                .font(.title3)
                .foregroundStyle(.primary)
            Spacer()
            Image(systemName: "chevron.forward")
                .foregroundStyle(.secondary)
        }
        #else
        HStack {
            if let icon {
                ObjectIcon(icon: icon, size: 30)
                    .scaleEffect(1.2)
                    .padding(.vertical, -10)
                    .padding(.trailing, 5)
                    .offset(y: 1)
            }
            Text(name)
                .font(.system(.title2, weight: .semibold))
                .foregroundStyle(.primary)
            Spacer()
            Image(systemName: "chevron.forward")
                .font(.title3)
                .imageScale(.small)
                .foregroundColor(.init(white: 0.6))
                .padding(.trailing, 5)
        }
        .padding()
        .background(Color.gray.opacity(0.1).cornerRadius(15))
        #endif
    }
}

