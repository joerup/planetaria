//
//  PlanetariaWatchView.swift
//  PlanetariaWatch Watch App
//
//  Created by Joe Rupertus on 8/16/23.
//

import SwiftUI
import PlanetariaUI
import PlanetariaData

struct PlanetariaWatchView: View {
    
    @EnvironmentObject var simulation: Simulation
    
    var body: some View {
        Simulator2D(from: simulation)
    }
}
