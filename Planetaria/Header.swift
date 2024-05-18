//
//  Header.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/15/23.
//

import SwiftUI
import PlanetariaData

struct Header: View {
    
    @EnvironmentObject var simulation: Simulation
    
    @Binding var showSettings: Bool
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    private var isCompact: Bool {
        verticalSizeClass == .compact || horizontalSizeClass == .compact
    }
    #else
    var isCompact: Bool = false
    #endif
    
    var body: some View {
        
        #if os(iOS)
        HStack {
            settingsButton
            Spacer(minLength: 10)
            //clock
            Spacer(minLength: 10)
            arButton
        }
        .padding(.horizontal)
        .padding(.top, isCompact ? 0 : 10)
        
        #endif
    }
    
    private var settingsButton: some View {
        Button {
            showSettings.toggle()
        } label: {
            Image(systemName: "gearshape.fill")
        }
        .buttonStyle(CircleButtonStyle())
    }
    
    private var arButton: some View {
        Button {
            simulation.arMode.toggle()
        } label: {
            Image(systemName: "cube.transparent\(simulation.arMode ? ".fill" : "")")
        }
        .buttonStyle(CircleButtonStyle())
    }
    
    @ViewBuilder
    private var locationTitle: some View {
        if let system = simulation.selectedSystem {
            Text(system.name)
                .lineLimit(0)
                .minimumScaleFactor(0.5)
                .foregroundColor(.mint)
                .font(.system(isCompact ? .callout : .body, design: .monospaced, weight: .bold))
                .opacity(0.5)
                .dynamicTypeSize(..<DynamicTypeSize.xLarge)
        }
    }
    
    private var clock: some View {
        HStack {
            Button {
                simulation.decreaseSpeed()
            } label: {
                Image(systemName: "backward\(simulation.frameRatio < -1 ? ".fill" : "")")
                    .foregroundStyle(simulation.frameRatio < -1 ? .pink : .white)
                    .imageScale(isCompact ? .small : .medium)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
            }
            
            Text(simulation.time.string)
                .lineLimit(0)
                .minimumScaleFactor(0.5)
                #if os(visionOS)
                .foregroundColor(simulation.isRealTime ? .white : simulation.frameRatio < 0 ? .pink : .mint)
                #else
                .foregroundColor(simulation.isRealTime ? .gray : simulation.frameRatio < 0 ? .pink : .mint)
                #endif
                .font(.system(isCompact ? .callout : .body, design: .monospaced, weight: .bold))
            
            Button {
                simulation.increaseSpeed()
            } label: {
                Image(systemName: "forward\(simulation.frameRatio > 1 ? ".fill" : "")")
                    .foregroundStyle(simulation.frameRatio > 1 ? .mint : .white)
                    .imageScale(isCompact ? .small : .medium)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
            }
        }
        .dynamicTypeSize(..<DynamicTypeSize.xLarge)
    }
}

private struct CircleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        
        #if os(visionOS)
        configuration.label
            .padding(7.5)
            .buttonStyle(.bordered)
            .clipShape(Circle())
        
        #else
        configuration.label
            .padding(7.5)
            .foregroundStyle(.mint)
            .background(Color(white: configuration.isPressed ? 0.5 : 0.2).opacity(0.5))
            .clipShape(Circle())
        #endif
    }
}
