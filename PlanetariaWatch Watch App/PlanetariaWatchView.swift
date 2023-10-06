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
    
    @EnvironmentObject var spacetime: Spacetime
    
    var body: some View {
        Planetarium(root: spacetime.root, reference: $spacetime.reference, system: $spacetime.system, object: $spacetime.object, focusTrigger: $spacetime.focusTrigger, backTrigger: $spacetime.backTrigger)
    }
}
