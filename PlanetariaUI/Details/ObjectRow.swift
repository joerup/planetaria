//
//  ObjectRow.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/10/23.
//

import SwiftUI
import PlanetariaData

struct ObjectRow: View {
    
    @EnvironmentObject var spacetime: Spacetime
    
    var object: ObjectNode
    
    var body: some View {
        #if os(iOS)
        HStack {
            Group {
                if object.rank == .primary {
                    Object3D(object: object)
                } else {
                    Circle().fill(.white).opacity(0.4).padding(5)
                }
            }
            .frame(width: 30, height: 30)
            .padding(.vertical, -10)
            .padding(.trailing, 5)
            Text(object.name)
                .font(.system(.title2, design: .rounded, weight: .semibold))
                .foregroundColor(.white)
            Spacer()
            Image(systemName: "arrow.forward")
                .font(.system(.title3, design: .rounded))
                .dynamicTypeSize(.medium)
                .foregroundColor(.init(white: 0.6))
                .padding(.trailing, 5)
        }
        .padding()
        .background(Color.gray.opacity(0.1).cornerRadius(15))
        #elseif os(macOS)
        #endif
    }
    
    private var circle: some View {
        Circle()
            .fill(object.color)
            .opacity(0.8)
    }
}
