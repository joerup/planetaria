//
//  PlanetariaWatchApp.swift
//  PlanetariaWatch Watch App
//
//  Created by Joe Rupertus on 8/16/23.
//

import SwiftUI
import PlanetariaData
import PlanetariaUI

@main
struct PlanetariaWatchApp: App {
    
    @StateObject private var simulation = Simulation(from: "Planetaria")
    
    var body: some Scene {
        WindowGroup {
            if simulation.isLoaded {
                Simulator2D(from: simulation)
            } else {
                ProgressView()
            }
        }
    }
}
