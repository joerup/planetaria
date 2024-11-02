//
//  Launcher.swift
//  Planetaria
//
//  Created by Joe Rupertus on 1/3/24.
//

import SwiftUI
import PlanetariaData

struct Launcher: View {
    
    @ObservedObject var simulation: Simulation
    
    #if os(visionOS)
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    #endif
    
    init(for simulation: Simulation) {
        self.simulation = simulation
    }
    
    var body: some View {
        #if os(iOS) || os(macOS)
        loadingScreen
            .overlay(alignment: .bottom) {
                if case .error(let error) = simulation.status {
                    errorMessage(error: error)
                } else {
                    statusText
                }
            }
        
        #elseif os(visionOS)
        if case .error(let error) = simulation.status {
            errorMessage(error: error)
        } else {
            loadingScreen
        }
        
        #endif
    }
    
    private var loadingScreen: some View {
        #if os(iOS) || os(macOS) || os(tvOS)
        VStack {
            Image("Planetaria Symbol")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 100)
            Text("Planetaria")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            ProgressView()
        }
        .preferredColorScheme(.dark)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Image("sky")
                .resizable()
                .ignoresSafeArea()
        }
        
        #elseif os(visionOS)
        VStack {
            Image("Planetaria Symbol")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 150)
                .shadow(radius: 10)
            Text("Planetaria")
                .font(.extraLargeTitle)
                .fontWeight(.bold)
                .padding()
            ZStack {
                Button {
                    Task {
                        await openImmersiveSpace(id: "simulator")
                    }
                } label: {
                    Text("Enter the Solar System")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                }
                .padding()
                .opacity(simulation.isLoaded ? 1 : 0)
                
                if !simulation.isLoaded {
                    ProgressView()
                        .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Image("sky")
                .resizable()
                .opacity(0.1)
                .ignoresSafeArea()
        }
        
        #endif
    }
    
    private func errorMessage(error: Simulation.SimulationError) -> some View {
        VStack {
            Text(error.text)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.red)
                .italic()
                .padding(.bottom)
            Text("\(error.detailText) [contact support](https://planetaria.app/support).")
                .multilineTextAlignment(.center)
                .padding(.bottom)
            Button("Try Again", systemImage: "arrow.clockwise") {
                simulation.load()
            }
            .padding(5)
        }
        .padding()
        #if os(iOS) || os(macOS)
        .background(Color(white: 0.15))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(maxWidth: 500)
        .padding()
        #endif
    }
    
    private var statusText: some View {
        Text("\(simulation.status.text)...")
            .fontWeight(.semibold)
            .foregroundStyle(.gray)
            .padding(.bottom, 40)
    }
}
