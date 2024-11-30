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
    
    #if os(visionOS)
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
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
            Launcher(for: simulation)
        }
        
        WindowGroup(id: "controls") {
            Navigator(for: simulation)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 0.5, height: 0.16, depth: 0, in: .meters)
        
        ImmersiveSpace(id: "simulator") {
            Simulator(for: simulation)
                .onAppear {
                    openWindow(id: "controls")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        dismissWindow(id: "launcher")
                    }
                }
                .onDisappear {
                    openWindow(id: "launcher")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        dismissWindow(id: "controls")
                    }
                }
        }
        
        #endif
    }
}
