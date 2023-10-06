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
    
    @StateObject var spacetime = Spacetime()
    
    var body: some Scene {
        WindowGroup {
            if spacetime.readyForTakeoff {
                PlanetariaView()
                    .environmentObject(spacetime)
                    .preferredColorScheme(.dark)
            } else {
                LoadingScreen()
                    .preferredColorScheme(.dark)
            }
        }
    }
}
