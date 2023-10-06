//
//  ObjectToolbar.swift
//  
//
//  Created by Joe Rupertus on 8/28/23.
//

import SwiftUI
import PlanetariaData

public struct ObjectToolbar: View {
    
    @EnvironmentObject var spacetime: Spacetime
    
    var object: ObjectNode
    
    public init(object: ObjectNode) {
        self.object = object
    }
    
    public var body: some View {
        HStack(spacing: 5) {
            button(label: "Orbit") {
                spacetime.focusTrigger = false
            }
            button(label: "Surface") {
                spacetime.focusTrigger = true
            }
            Spacer()
        }
        .padding(5)
    }
    
    private func button(label: String, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation {
                action()
            }
        } label: {
            Text(label)
                .font(.body)
                .fontWeight(.semibold)
                .fontWidth(.expanded)
                .foregroundStyle(.white)
                .padding(10)
                .frame(minWidth: 100)
                .background(Color.init(white: 0.1).cornerRadius(10))
        }
    }
}
