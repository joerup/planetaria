//
//  Launcher.swift
//  Planetaria
//
//  Created by Joe Rupertus on 1/3/24.
//

import SwiftUI

struct Launcher: View {
    
    #if os(visionOS)
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    var isLoaded: Bool
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
                .padding()
            ProgressView()
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
            if isLoaded {
                Button {
                    Task {
                        await openImmersiveSpace(id: "simulator")
                        openWindow(id: "navigator")
                        dismissWindow()
                    }
                } label: {
                    Text("Enter the Solar System")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                }
                .padding()
            } else {
                ProgressView()
                    .padding()
            }
        }
        
        #endif
    }
    
}
