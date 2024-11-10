//
//  Navigator.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/27/23.
//

import SwiftUI
import PlanetariaData

struct Navigator<Content: View>: View {
    
    @ObservedObject var simulation: Simulation
    
    @ViewBuilder var content: () -> Content
    
    @State private var showDetails: Bool = false
    @State private var showList: Bool = false
    @State private var showSettings: Bool = false
    @State private var showSearch: Bool = false
    @State private var showTimeControls: Bool = false
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    #elseif os(macOS)
    private let verticalSizeClass: UserInterfaceSizeClass = .regular
    private let horizontalSizeClass: UserInterfaceSizeClass = .regular

    #elseif os(visionOS)
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase
    
    private let verticalSizeClass: UserInterfaceSizeClass = .regular
    private let horizontalSizeClass: UserInterfaceSizeClass = .regular
    #endif
    
    private var isCompact: Bool {
        verticalSizeClass == .regular && horizontalSizeClass == .compact
    }
    
    init(for simulation: Simulation, @ViewBuilder content: @escaping () -> Content = { EmptyView() }) where Content: View {
        self.simulation = simulation
        self.content = content
    }

    var body: some View {
        Group {
            
            #if os(iOS)
            GeometryReader { geometry in
                content()
                    .overlay(alignment: .top) {
                        VStack(spacing: 0) {
                            HStack(alignment: .top) {
                                settingsButton
                                arButton
                                VStack(spacing: 0) {
                                    clock
                                    if !isCompact && showTimeControls {
                                        timeControls
                                            .padding(.bottom, 4)
                                            .padding(.top, -5)
                                    }
                                }
                                .padding(.horizontal)
                                .background(Color(white: 0.15).opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .frame(maxWidth: .infinity)
                                if let system = simulation.selectedSystem {
                                    listButton(system)
                                }
                                searchButton
                            }
                            if isCompact && showTimeControls {
                                timeControls
                                    .padding(.horizontal, 8)
                                    .frame(minHeight: 40)
                                    .background(Color(white: 0.15).opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .padding(.vertical, 8)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, verticalSizeClass == .regular ? 0 : 2)
                    }
                    .overlay(alignment: .bottom) {
                        if let object = simulation.selectedObject {
                            Group {
                                if isCompact {
                                    VStack {
                                        HStack(alignment: .top) {
                                            objectLabel(object)
                                            Spacer(minLength: 8)
                                            infoButton(object)
                                            closeButton
                                        }
                                        selectorButtons()
                                            .frame(maxWidth: .infinity)
                                            .padding(.top, 4)
                                    }
                                    .padding(8)
                                } else {
                                    HStack {
                                        objectLabel(object)
                                        Spacer()
                                        selectorButtons()
                                        infoButton(object)
                                        closeButton
                                    }
                                }
                            }
                            .padding(8)
                            .padding(.horizontal, isCompact ? 0 : 8)
                            .background(Color(white: 0.15).opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .padding(.horizontal)
                            .frame(maxWidth: 750)
                            .padding(isCompact ? [] : [.horizontal])
                            .padding(.bottom, verticalSizeClass == .regular ? 10 : 0)
                        }
                    }
                    .preferredColorScheme(.dark)
                    .ignoresSafeArea(.keyboard)
            }
            
            #elseif os(macOS)
            content()
                .overlay(alignment: .bottom) {
                    if let object = simulation.selectedObject {
                        HStack {
                            objectLabel(object)
                            Spacer()
                            selectorButtons()
                            infoButton(object)
                            closeButton
                        }
                        .padding(8)
                        .padding(.horizontal, isCompact ? 0 : 8)
                        .background(Color(white: 0.15).opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .padding(.horizontal)
                        .frame(maxWidth: 750)
                        .padding()
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigation) {
                        settingsButton
                    }
                    ToolbarItemGroup(placement: .principal) {
                        clock
                    }
                    ToolbarItemGroup(placement: .primaryAction) {
                        if let system = simulation.selectedSystem {
                            listButton(system)
                        }
                        searchButton
                    }
                }
                .preferredColorScheme(.dark)
            
            #elseif os(visionOS)
            HStack {
                if let object = simulation.selectedObject {
                    objectLabel(object, large: true)
                    Spacer()
                    infoButton(object)
                    closeButton
                } else {
                    Text("Welcome to the Solar System")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                        .padding(.top)
                }
            }
            .padding()
            .padding(.horizontal)
            .ornament(attachmentAnchor: .scene(.top)) {
                HStack {
                    homeButton
                    settingsButton
                    clock
                        .popover(isPresented: $showTimeControls, arrowEdge: .bottom) {
                            timeControls
                                .padding(.horizontal)
                        }
                    if let system = simulation.selectedSystem {
                        listButton(system)
                    }
                    searchButton
                }
                .padding()
                .glassBackgroundEffect()
            }
            .ornament(visibility: simulation.selectedObject != nil ? .visible : .hidden, attachmentAnchor: .scene(.bottom)) {
                selectorButtons(large: true)
                    .padding()
                    .glassBackgroundEffect()
            }
            .onChange(of: scenePhase) { _, _ in
                Task {
                    await dismissImmersiveSpace()
                }
            }
            
            #endif
        }
        .environmentObject(simulation)
    }
    
    private func objectLabel(_ object: ObjectNode, large: Bool = false) -> some View {
        HStack {
            ObjectIcon(icon: object.name, size: large ? 80 : 48)
                .scaleEffect(1.2)
                .offset(y: 1)
                .padding(.trailing, large ? 8 : 0)
            VStack(alignment: .leading, spacing: 2) {
                Text(object.name)
                    .font(large ? .largeTitle : .title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .lineLimit(0)
                Text(object.subtitle)
                    .font(large ? .headline : .caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .lineLimit(0)
                    .padding(.bottom, 2)
            }
            .dynamicTypeSize(..<DynamicTypeSize.accessibility2)
        }
    }
    
    private func infoButton(_ object: ObjectNode) -> some View {
        ControlButton(icon: "info", isActive: showDetails) {
            showDetails.toggle()
        }
        .accessibilityLabel("Show Info for \(object.name)")
        .sheet(isPresented: $showDetails) {
            ObjectDetails(object: object)
        }
    }
    
    private func listButton(_ system: SystemNode) -> some View {
        ControlButton(icon: "list.bullet", isActive: showList) {
            showList.toggle()
        }
        .accessibilityLabel("Show Object List")
        .popover(isPresented: $showList) {
            SystemDetails(system: system)
                .frame(minWidth: 350)
        }
    }
    
    private var searchButton: some View {
        ControlButton(icon: "magnifyingglass", isActive: showSearch) {
            showSearch.toggle()
        }
        .accessibilityLabel("Search")
        .popover(isPresented: $showSearch) {
            SearchMenu()
                .frame(minWidth: 350)
        }
    }
    
    private var settingsButton: some View {
        ControlButton(icon: "gearshape.fill", isActive: showSettings) {
            showSettings.toggle()
        }
        .accessibilityLabel("Settings")
        .sheet(isPresented: $showSettings) {
            Settings()
        }
    }
    
    #if os(visionOS)
    private var homeButton: some View {
        ControlButton(icon: "house") {
            Task {
                await dismissImmersiveSpace()
            }
        }
        .accessibilityLabel("Home")
    }
    #endif
    
    #if os(iOS)
    private var arButton: some View {
        ControlButton(icon: "cube.transparent\(simulation.viewType == .augmented ? ".fill" : "")", isActive: simulation.viewType == .augmented) {
            simulation.viewType = simulation.viewType == .augmented ? .fixed : .augmented
        }
        .accessibilityLabel("Change AR Mode")
    }
    #endif
    
    private var closeButton: some View {
        ControlButton(icon: "xmark") {
            simulation.selectObject(nil)
        }
        .accessibilityLabel("Deselect")
    }
    
    private var clock: some View {
        largeButton {
            withAnimation {
                showTimeControls.toggle()
            }
        } label: {
            Text(simulation.time.string)
                .lineLimit(0)
                .minimumScaleFactor(0.5)
                .foregroundColor(simulation.isRealTime ? .white : simulation.frameRatio < 0 ? .pink : .mint)
                .dynamicTypeSize(..<DynamicTypeSize.accessibility2)
        }
        .accessibilityLabel(simulation.time.string)
    }
    
    private func selectorButtons(large: Bool = false) -> some View {
        HStack(spacing: large ? nil : 5) {
            if simulation.hasOrbit {
                mediumButton(label: "Orbit", isActive: simulation.stateOrbit) {
                    simulation.selectOrbit()
                }
                .accessibilityLabel("Zoom to Orbit")
            }
            if simulation.hasSystem {
                mediumButton(label: "System", isActive: simulation.stateSystem) {
                    simulation.selectSystem()
                }
                .accessibilityLabel("Zoom to System")
            }
            mediumButton(label: "Surface", isActive: simulation.stateSurface) {
                simulation.selectSurface()
            }
            .accessibilityLabel("Zoom to Surface")
        }
        .fontDesign(.rounded)
        #if os(iOS)
        .background(Color.init(white: 0.15).opacity(0.5).cornerRadius(30))
        #endif
    }
    
    private var timeControls : some View {
        HStack(spacing: isCompact ? 3 : nil) {
            simpleButton(icon: "arrow.circlepath") {
                simulation.resetTime()
                showTimeControls = false
            }
            .accessibilityLabel("Reset Time")
            .opacity(simulation.isRealTime ? 0 : 0.5)
            
            simpleButton(icon: "backward\(simulation.frameRatio < -1 ? ".fill" : "")") {
                simulation.decreaseSpeed()
            }
            .accessibilityLabel("Decrease Speed")
            
            simpleButton(icon: "\(simulation.isPaused ? "play" : "pause").fill") {
                simulation.pause()
            }
            .accessibilityLabel(simulation.isPaused ? "Play" : "Pause")
            
            simpleButton(icon: "forward\(simulation.frameRatio > 1 ? ".fill" : "")") {
                simulation.increaseSpeed()
            }
            .accessibilityLabel("Increase Speed")
            
            simpleButton(icon: "arrow.circlepath") {
                simulation.resetTime()
            }
            .opacity(0)
        }
    }
    
    private func simpleButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundStyle(.white)
                .bold()
                .frame(minWidth: 40, minHeight: 40)
        }
    }
    
    private func mediumButton(label: String, isActive: Bool = false, action: @escaping () -> Void) -> some View {
        
        #if os(visionOS)
        Button(action: action) {
            Text(label)
                .lineLimit(0)
                .minimumScaleFactor(0.5)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .frame(minWidth: 100, minHeight: 40)
        }
        .buttonBorderShape(.capsule)
        .opacity(isActive ? 1 : 0.4)
        .dynamicTypeSize(..<DynamicTypeSize.xxLarge)
        
        #else
        Button(action: action) {
            Text(label)
                .lineLimit(0)
                .minimumScaleFactor(0.5)
                .font(.callout)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(.white)
                .padding(10)
                .frame(maxWidth: 100, minHeight: 40)
                .background(Color.init(white: isActive ? 0.3 : 0.15).opacity(0.5).cornerRadius(30))
        }
        .buttonStyle(.plain)
        .dynamicTypeSize(..<DynamicTypeSize.xxLarge)
        
        #endif
    }
    
    private func largeButton<Label: View>(action: @escaping () -> Void, label: @escaping () -> Label) -> some View {
        
        #if os(visionOS)
        Button(action: action) {
            label()
                .font(.system(.title3, design: .monospaced, weight: .bold))
                .padding(.horizontal)
                .frame(minHeight: 40)
        }
        .buttonBorderShape(.capsule)
        .dynamicTypeSize(..<DynamicTypeSize.xxLarge)

        #else
        Button(action: action) {
            label()
                .font(.system(isCompact ? .callout : .body, design: .monospaced, weight: .bold))
                .padding(.horizontal, isCompact ? 0 : 8)
                .frame(minHeight: 40)
        }
        .buttonStyle(.plain)
        .dynamicTypeSize(..<DynamicTypeSize.xxLarge)

        #endif
    }
}
