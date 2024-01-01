//
//  PlanetariaWatchApp.swift
//  PlanetariaWatch Watch App
//
//  Created by Joe Rupertus on 8/16/23.
//

import SwiftUI
import PlanetariaData

@main
struct PlanetariaWatchApp: App {
    
    @StateObject private var simulation = Simulation(from: "planetaria")
    
    var body: some Scene {
        WindowGroup {
            PlanetariaWatchView()
                .environmentObject(simulation)
        }
    }
}
