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
    
    @StateObject private var simulation = Simulation(from: "sample")
    
    @State private var showSettings: Bool = false
    
    var body: some Scene {
        
        #if os(iOS) || os(macOS) || os(tvOS)
        WindowGroup {
            if simulation.isLoaded {
                Navigator(showDetail: showDetail, showSettings: $showSettings, menuID: systemID, detailID: objectID, menu: menu, detail: detail) {
                    Simulator(from: simulation)
                }
                .environmentObject(simulation)
            } else {
                Launcher()
            }
        }
        
        #elseif os(visionOS)
        WindowGroup(id: "launcher") {
            Launcher(isLoaded: simulation.isLoaded)
        }
        WindowGroup(id: "navigator") {
            Navigator(showDetail: showDetail, showSettings: $showSettings, menuID: systemID, detailID: objectID, menu: menu, detail: detail) { }
                .environmentObject(simulation)
        }
        .defaultSize(width: 0.5, height: 0.5, depth: 0, in: .meters)
        
        ImmersiveSpace(id: "simulator") {
            Simulator(from: simulation)
                .offset(y: -1000).offset(z: -1500)
        }
        
        #endif
    }
    
    private var showDetail: Binding<Bool> {
        Binding {
            simulation.hasSelection
        } set: { _ in
            simulation.selectObject(nil)
        }
    }
    
    private var objectID: Int? {
        simulation.selectedObject?.id
    }
    
    private var systemID: Int? {
        simulation.selectedSystem?.id
    }
    
    @ViewBuilder
    private func menu() -> some View {
        if let system = simulation.selectedSystem {
            SystemDetails(system: system)
                .environmentObject(simulation)
        }
    }
    
    @ViewBuilder
    private func detail() -> some View {
        if let object = simulation.selectedObject {
            ObjectDetails(object: object)
                .environmentObject(simulation)
        }
    }
}
