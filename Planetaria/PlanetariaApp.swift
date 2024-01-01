//
//  PlanetariaApp.swift
//  Planetaria
//
//  Created by Joe Rupertus on 10/27/20.
//

import SwiftUI
import PlanetariaData
import PlanetariaUI
import RealityKit

@main
struct PlanetariaApp: App {
    
    @StateObject private var simulation = Simulation(from: "Planetaria")
    
    #if os(visionOS)
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.openWindow) var openWindow
    @State private var currentStyle: ImmersionStyle = .mixed
    #endif
    
    var body: some SwiftUI.Scene {
        #if os(iOS) || os(macOS) || os(tvOS)
        WindowGroup {
            if simulation.isLoaded {
                PlanetariaView()
                    .environmentObject(simulation)
                    .preferredColorScheme(.dark)
            } else {
                LoadingScreen()
                    .preferredColorScheme(.dark)
            }
        }
        #elseif os(visionOS)
        WindowGroup {
            PlanetariaLauncher()
        }
        ImmersiveSpace(id: "simulator") {
            ZStack {
                if simulation.isLoaded {
                    Simulator3D(from: simulation)
                        .offset(z: -1000)
                        .offset(y: -1000)
                }
                RealityView { content in
                    // Create a material with a star field on it.
                    guard let resource = try? await TextureResource(named: "Starfield") else {
                        // If the asset isn't available, something is wrong with the app.
                        fatalError("Unable to load starfield texture.")
                    }
                    var material = UnlitMaterial()
                    material.color = .init(texture: .init(resource))
                    
                    // Attach the material to a large sphere.
                    let entity = Entity()
                    entity.components.set(ModelComponent(
                        mesh: .generateSphere(radius: 1000),
                        materials: [material]
                    ))
                    
                    // Ensure the texture image points inward at the viewer.
                    entity.scale *= .init(x: -1, y: 1, z: 1)
                    
                    let entity2 = Entity()
                    entity.components.set(ModelComponent(mesh: .generateSphere(radius: 10), materials: [UnlitMaterial(color: .red)]))
                    entity.position = .init(x: 20, y: 20, z: 20)
                    
                    content.add(entity)
                    content.add(entity2)
                }
            }
        }
        .immersionStyle(selection: $currentStyle, in: .full, .mixed)
        WindowGroup(id: "details") {
            if let object = simulation.selectedObject {
                ObjectDetails(object: object)
            }
        }
        .defaultSize(width: 0.5, height: 0.5, depth: 0, in: .meters)
        #endif
    }
}

#if os(visionOS)
struct PlanetariaLauncher: View {
    
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    
    var body: some View {
        VStack {
            Image("Planetaria Symbol")
                .resizable()
                .frame(width: 100, height: 100)
            Text("Welcome to Planetaria")
                .font(.extraLargeTitle)
            Button("Start") {
                Task {
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
