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
    
    @StateObject var spacetime = Spacetime()
    
    var body: some Scene {
        WindowGroup {
            PlanetariaWatchView()
                .environmentObject(spacetime)
        }
    }
}
