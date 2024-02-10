//
//  Launcher.swift
//  Planetaria
//
//  Created by Joe Rupertus on 1/3/24.
//

import SwiftUI
import RealityKit

struct Launcher: View {
    
    @Environment(\.scenePhase) var scenePhase
    
    #if os(visionOS)
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    var isLoaded: Bool
    
    @Binding var showSimulator: Bool
    #endif
    
    var body: some View {
        
        #if os(iOS) || os(macOS) || os(tvOS)
        VStack {
            Image("Planetaria Symbol")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 100)
            Text("Planetaria")
                .font(.title)
                .fontWeight(.bold)
                .fontDesign(.rounded)
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
                .fontDesign(.rounded)
                .fontWeight(.bold)
                .padding()
            ZStack {
                Button {
                    Task {
                        showSimulator = true
                        await openImmersiveSpace(id: "simulator")
                    }
                } label: {
                    Text("Enter the Solar System")
                        .font(.title)
                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                        .padding()
                }
                .padding()
                .opacity(isLoaded ? 1 : 0)
                
                if !isLoaded {
                    ProgressView()
                        .padding()
                }
            }
        }
        
        #endif
    }
    
}
