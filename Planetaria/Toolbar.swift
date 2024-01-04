//
//  Toolbar.swift
//  
//
//  Created by Joe Rupertus on 8/28/23.
//

import SwiftUI
import PlanetariaData

struct Toolbar: View {
    
    @ObservedObject var simulation: Simulation
    
    var body: some View {
        HStack {
            if simulation.selectedObject != nil {
                if simulation.hasOrbit {
                    largeButton(label: "Orbit", isActive: simulation.stateOrbit) {
                        simulation.selectOrbit()
                    }
                }
                if simulation.hasSystem {
                    largeButton(label: "System", isActive: simulation.stateSystem) {
                        simulation.selectSystem()
                    }
                }
                largeButton(label: "Surface", isActive: simulation.stateSurface) {
                    simulation.selectSurface()
                }
            }
        }
    }
    
    private func largeButton(label: String, isActive: Bool, action: @escaping () -> Void) -> some View {
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
    }
    
    private func smallButton(icon: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: icon)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(10)
                .background(Color.gray.opacity(1e-6))
        }
        .buttonStyle(.plain)
    }
}
