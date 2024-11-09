//
//  SelectionRow.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/10/23.
//

import SwiftUI
import PlanetariaData

struct SelectionRow: View {
    
    var title: String
    var subtitle: String?
    var icon: String?
    
    var body: some View {
        #if os(macOS)
        HStack {
            if let icon {
                ObjectIcon(icon: icon, size: 30)
                    .scaleEffect(1.2)
            }
            Text(title)
                .font(.title3)
                .foregroundStyle(.primary)
            Spacer()
            Image(systemName: "chevron.forward")
                .foregroundStyle(.secondary)
        }
        #else
        HStack {
            if let icon {
                ObjectIcon(icon: icon, size: 36)
                    .scaleEffect(1.2)
                    .padding(.vertical, -10)
                    .offset(y: 1)
            }
            if let subtitle {
                VStack(alignment: .leading) {
                    Text(title)
                        .lineLimit(0)
                        .font(.system(.headline, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.system(.caption, design: .default, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            } else {
                Text(title)
                    .lineLimit(0)
                    .font(.system(.title2, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            Spacer()
            Image(systemName: "chevron.forward")
                .font(.headline)
                .imageScale(.small)
                .foregroundColor(.init(white: 0.6))
                .padding(.trailing, 5)
        }
        #if !os(visionOS)
        .padding(.horizontal, 12)
        .padding(.vertical, subtitle == nil ? 15 : 12)
        .background(.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        #else
        .padding(.vertical, subtitle == nil ? 16 : 0)
        #endif
        #endif
    }
}

