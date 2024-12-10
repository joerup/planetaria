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
    
    #if os(iOS) || os(macOS)
    @StateObject private var simulation = Simulation(from: "Planetaria", viewType: .fixed, updateType: .spice)
    
    #elseif os(visionOS)
    @StateObject private var simulation = Simulation(from: "Planetaria", viewType: .immersive, updateType: .spice)
    @State private var showingImmersiveSpace: Bool = false
    
    #endif
    
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
            if showingImmersiveSpace {
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
                    showingImmersiveSpace = true
                }
                .onDisappear {
                    showingImmersiveSpace = false
                }
        }
        
        #endif
    }
}
