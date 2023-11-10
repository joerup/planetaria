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
    
    @StateObject var spacetime = Spacetime()
    
    @StateObject private var simulation: Simulation = Simulation()
    
    #if os(visionOS)
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.openWindow) var openWindow
    @State private var currentStyle: ImmersionStyle = .mixed
    #endif
    
    var body: some Scene {
        #if os(iOS) || os(macOS) || os(tvOS)
        WindowGroup {
            if spacetime.readyForTakeoff {
                PlanetariaView()
                    .environmentObject(simulation)
                    .preferredColorScheme(.dark)
                    .onAppear {              
                        guard let root = spacetime.root else { return }
                        simulation.setContents(root: root, reference: spacetime.reference, system: spacetime.system, object: spacetime.object)
                        simulation.start()
                    }
            } else {
                LoadingScreen()
                    .preferredColorScheme(.dark)
            }
        }
        #elseif os(visionOS)
        WindowGroup {
            PlanetariaLauncher {
                guard let root = spacetime.root else { return }
                simulation.setContents(root: root, reference: spacetime.reference, system: spacetime.system, object: spacetime.object)
                simulation.start()
            }
        }
        ImmersiveSpace(id: "simulator") {
            if simulation.isActive {
                Simulator3D(from: simulation)
                    .frame(width: 2000, height: 2000)
                    .frame(depth: 2000)
                    .offset(z: -1000)
                    .offset(y: -1000)
                    .overlay {
                        Text("\(simulation.allNodes.count)")
                    }
            }
        }
        .immersionStyle(selection: $currentStyle)
        WindowGroup(id: "details") {
            if let object = simulation.selectedObject {
                ObjectDetails(object: object)
            }
        }
        .defaultSize(width: 0.4, height: 0.5, depth: 0, in: .meters)
        #endif
    }
}

#if os(visionOS)
struct PlanetariaLauncher: View {
    
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    
    var loadSimulator: () -> Void
    
    var body: some View {
        VStack {
            Image("Planetaria Symbol")
                .resizable()
                .frame(width: 100, height: 100)
            Text("Welcome to Planetaria")
                .font(.extraLargeTitle)
            Button("Start") {
                Task {
                    loadSimulator()
                    let result = await openImmersiveSpace(id: "simulator")
                    if case .error = result {
                        print("An error occurred")
                    }
                    dismissWindow()
                }
            }
        }
    }
}
#endif
