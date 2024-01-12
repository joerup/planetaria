//
//  Toolbar.swift
//  
//
//  Created by Joe Rupertus on 8/28/23.
//

import SwiftUI
import PlanetariaData

struct Toolbar: View {
    
    @EnvironmentObject var simulation: Simulation
    
    var body: some View {
        HStack {
            if simulation.selectedObject != nil {
                if simulation.hasOrbit {
                    button(label: "Orbit", isActive: simulation.stateOrbit) {
                        simulation.selectOrbit()
                    }
                }
                if simulation.hasSystem {
                    button(label: "System", isActive: simulation.stateSystem) {
                        simulation.selectSystem()
                    }
                }
                button(label: "Surface", isActive: simulation.stateSurface) {
                    simulation.selectSurface()
                }
            }
        }
    }
    
    private func button(label: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        
        #if os(visionOS)
        Button {
            action()
        } label: {
            Text(label)
                .fontWeight(.semibold)
                .frame(minWidth: 100)
        }
        .buttonBorderShape(.capsule)
        .opacity(isActive ? 1 : 0.4)
        
        #else
        Button {
            action()
        } label: {
            Text(label)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(10)
                .frame(minWidth: 100)
                .background(Color.init(white: isActive ? 0.2 : 0.1).cornerRadius(10))
        }
        .buttonStyle(.plain)
        
        #endif
    }
}
