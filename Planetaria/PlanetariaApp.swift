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
    @StateObject private var simulation = Simulation(from: "Planetaria", viewType: .fixed)
    
    #elseif os(visionOS)
    @StateObject private var simulation = Simulation(from: "Planetaria", viewType: .immersive)
    @State private var showingImmersiveSpace: Bool = false
    @State private var immersionStyle: ImmersionStyle = .full
    
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
//        .immersionStyle(selection: $immersionStyle, in: .full)
        
        #endif
    }
}
