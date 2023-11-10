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
    
    @State private var searching: Bool = false
    @State private var searchText: String = ""
    
    @State private var showSettings: Bool = false
    
    var body: some View {
        EmptyView()
        Simulator2D(from: simulation)
            .ignoresSafeArea(.keyboard)
            .overlay(alignment: .top) {
                #if os(iOS)
                Header()
                #endif
            }
            .details(detents: detents, selectedDetent: $selectedDetent) {
                ZStack {
                    if let system = simulation.selectedSystem {
                        SystemDetails(system: system, searching: $searching)
                    }
                    if searching {
                        SearchMenu(searching: $searching, searchText: $searchText)
                    }
                    if let object = simulation.selectedObject {
                        ObjectDetails(object: object)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    if !simulation.noSelection {
                        XButton {
                            
                        }
                        .padding(5)
                    }
                }
            } toolbar: {
                if let object = simulation.selectedObject {
                    ObjectToolbar(object: object)
                }
            }
            .sheet(isPresented: self.$showSettings) {
                SettingsView()
            }
            .tint(.mint)
            .onChange(of: simulation.selectedObject) { _, object in
                updateDetailModals(object: object)
            }
    }
    
    private func updateDetailModals(object: ObjectNode?) {
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
