//
//  PlanetariaApp.swift
//  Planetaria
//
//  Created by Joe Rupertus on 10/27/20.
//

import SwiftUI
import PlanetariaData
import PlanetariaUI

@main
struct PlanetariaApp: App {
    
    @StateObject private var simulation = Simulation(from: "Planetaria")
    
    var body: some Scene {
        
        #if os(iOS) || os(macOS) || os(tvOS)
        WindowGroup {
            if simulation.isLoaded {
                Navigator(showDetail: showDetail, menu: menu, detail: detail, header: header, toolbar: toolbar) {
                    Simulator2D(from: simulation)
                }
            } else {
                Launcher()
            }
        }
        
        #elseif os(visionOS)
        WindowGroup(id: "launcher") {
            Launcher(isLoaded: simulation.isLoaded)
        }
        WindowGroup(id: "navigator") {
            Navigator(showDetail: showDetail, menu: menu, detail: detail, header: header, toolbar: toolbar) { }
        }
        .defaultSize(width: 0.4, height: 0.7, depth: 0, in: .meters)
        
        ImmersiveSpace(id: "simulator") {
            Simulator3D(from: simulation)
                .offset(y: -1200).offset(z: -1000)
        }
        
        #endif
    }
    
    private var showDetail: Binding<Bool> {
        Binding {
            simulation.hasSelection
        } set: { _ in
            simulation.select(nil)
        }
    }
    
    @ViewBuilder
    private func menu() -> some View {
        if let system = simulation.selectedSystem {
            SystemDetails(system: system)
                .id(system.id)
                .environmentObject(simulation)
        }
    }
    
    @ViewBuilder
    private func detail() -> some View {
        if let object = simulation.selectedObject {
            ObjectDetails(object: object)
                .id(object.id)
                .environmentObject(simulation)
                .overlay(alignment: .topTrailing) {
                    XButton {
                        withAnimation {
                            simulation.select(nil)
                        }
                    }
                    .padding(5)
                }
        }
    }
    
    private func header() -> some View {
        Header(simulation: simulation)
    }
    
    private func toolbar() -> some View {
        Toolbar(simulation: simulation)
    }
}
