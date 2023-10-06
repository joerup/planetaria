//
//  NewDetailRow.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/10/23.
//

import SwiftUI
import PlanetariaData

struct NewDetailRow: View {
    
    @EnvironmentObject var spacetime: Spacetime
    
    var node: Node
    
    var body: some View {
        Button {
            withAnimation {
                spacetime.object = node.object
            }
        } label: {
            HStack {
//                visual(size: 45)
//                    .disabled(true)
//                    .padding(.leading, 5)
//                    .padding(.trailing, 10)
                Text(node.object?.name ?? node.name)
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
            .background(node.color.opacity(0.1).cornerRadius(15))
        }
    }
    
    @ViewBuilder
    private func visual(size: CGFloat) -> some View {
        if let object = node.object {
            Object3D(object)
                .frame(width: size, height: size)
        }
    }
}
