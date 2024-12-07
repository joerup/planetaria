//
//  PlanetariaApp.swift
//  Planetaria
//
//  Created by Joe Rupertus on 10/27/20.
//

import SwiftUI
import PlanetariaData

@main
struct PlanetariaApp: App {
    
    @StateObject private var simulation = Simulation(from: "Planetaria", updateType: .spice)
    
    @State private var showImmersiveSpace: Bool = false
    
    var body: some Scene {
        
        #if os(iOS) || os(macOS) || os(tvOS)
        WindowGroup {
            if simulation.isLoaded {
                Navigator(for: simulation) {
                    Simulator(for: simulation)
                }
            } else {
                Launcher(for: simulation)
            }
        }
        
        #elseif os(visionOS)
        WindowGroup(id: "launcher") {
            if showImmersiveSpace {
                Navigator(for: simulation)
            } else {
                Launcher(for: simulation)
                    .glassBackgroundEffect()
            }
        }
        .windowStyle(.plain)
        
        ImmersiveSpace(id: "simulator") {
            Simulator(for: simulation)
                .onAppear {
                    showImmersiveSpace = true
                }
                .onDisappear {
                    showImmersiveSpace = false
                }
        }
        
        #endif
    }
}
