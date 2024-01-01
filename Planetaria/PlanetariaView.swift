//
//  PlanetariaView.swift
//  Planetaria
//
//  Created by Joe Rupertus on 1/14/23.
//

import SwiftUI
import PlanetariaData
import PlanetariaUI

struct PlanetariaView: View {
    
    @EnvironmentObject var simulation: Simulation
    
    private let detents: Set<PresentationDetent> = [.preview, .small, .large]
    
    @State private var savedDetent: PresentationDetent = .small
    @State private var selectedDetent: PresentationDetent = .small
    @State private var showSidebar: Bool = true
    @State private var showObject: Bool = false
    
    @State private var searching: Bool = false
    @State private var searchText: String = ""
    
    @State private var showSettings: Bool = false
    
    var body: some View {
        Simulator2D(from: simulation)
            .ignoresSafeArea(.keyboard)
            .overlay(alignment: .top) {
                #if os(iOS)
                Header(showSidebar: $showSidebar)
                #endif
            }
            .details(detents: detents, selectedDetent: $selectedDetent, showSidebar: showSidebar, showObject: showObject, systemDetails: {
                if let system = simulation.selectedSystem {
                    SystemDetails(system: system)
                        .id(system.id)
                }
            }, objectDetails: {
                if let object = simulation.selectedObject {
                    ObjectDetails(object: object)
                        .id(object.id)
                        .overlay(alignment: .topTrailing) {
                            XButton {
                                withAnimation {
                                    simulation.select(nil)
                                }
                            }
                            .padding(5)
                        }
                }
            }, toolbar: {
                Toolbar()
            })
            .sheet(isPresented: self.$showSettings) {
                SettingsView()
            }
            .tint(.mint)
            .onChange(of: simulation.selectedObject) { _, object in
                updateDetailModals(object: object)
                withAnimation {
                    showObject = object != nil
                }
            }
    }
    
    private func updateDetailModals(object: Object?) {
        if object == nil {
            selectedDetent = savedDetent
        } else {
            savedDetent = selectedDetent
            if selectedDetent != .small {
                selectedDetent = .preview
            }
        }
    }
}
