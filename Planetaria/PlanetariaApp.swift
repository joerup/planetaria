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
    
    @StateObject private var simulation = Simulation(from: "Planetaria")
    
    @State private var showImmersiveSpace: Bool = false
    
    var body: some Scene {
        
        #if os(iOS) || os(macOS) || os(tvOS)
        WindowGroup {
            Group {
                if simulation.isLoaded {
                    Navigator(showDetail: showDetail, menuID: systemID, detailID: objectID, menu: menu, detail: detail) {
                        Simulator(from: simulation)
                    }
                    .environmentObject(simulation)
                } else {
                    Launcher()
                }
            }
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    print("tick \(Date())")
                }
            }
        }
        
        #elseif os(visionOS)
        WindowGroup {
            if showImmersiveSpace {
                Navigator(showDetail: showDetail, menuID: systemID, detailID: objectID, menu: menu, detail: detail, content: {})
                    .environmentObject(simulation)
            } else {
                Launcher(isLoaded: simulation.isLoaded)
            }
        }
        .defaultSize(width: 0.6, height: 0.5, depth: 0, in: .meters)
        
        ImmersiveSpace(id: "simulator") {
            Simulator(from: simulation)
                .offset(y: -1000).offset(z: -1500)
                .onAppear { showImmersiveSpace = true }
                .onDisappear { showImmersiveSpace = false }
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
