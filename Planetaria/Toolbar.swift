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
            Spacer()
                .frame(maxWidth: .infinity)
            HStack(spacing: 5) {
                if simulation.selectedObject != nil {
                    largeButton(label: "Orbit", isActive: simulation.stateInOrbit) {
                        simulation.selectObjectOrbit()
                    }
                    if simulation.hasLocalSystem {
                        largeButton(label: "System", isActive: simulation.stateInSystem) {
                            simulation.selectLocalSystem()
                        }
                    }
                    largeButton(label: "Surface", isActive: simulation.stateOnSurface) {
                        simulation.selectObjectSurface()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            HStack(spacing: 5) {
                Spacer()
//                smallButton(icon: "minus") {
//                    simulation.zoomOut()
//                }
//                smallButton(icon: "plus") {
//                    simulation.zoomIn()
//                }
            }
            .frame(maxWidth: .infinity)
        }
        #if os(macOS)
        .padding()
        #endif
        .padding(5)
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
