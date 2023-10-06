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
    
    @EnvironmentObject var spacetime: Spacetime
    
    private let detents: Set<PresentationDetent> = [.preview, .small, .large]
    
    @State private var savedDetent: PresentationDetent = .small
    @State private var selectedDetent: PresentationDetent = .small
    
    @State private var searching: Bool = false
    @State private var searchText: String = ""
    
    @State private var showSettings: Bool = false
    
    var body: some View {
        Planetarium(root: spacetime.root, reference: $spacetime.reference, system: $spacetime.system, object: $spacetime.object, focusTrigger: $spacetime.focusTrigger, backTrigger: $spacetime.backTrigger)
            .ignoresSafeArea(.keyboard)
            .overlay(alignment: .top) {
                #if os(iOS)
                Header()
                #endif
            }
            .details(detents: detents, selectedDetent: $selectedDetent) {
                ZStack {
                    if let system = spacetime.system {
                        SystemDetails(system: system, searching: $searching)
                            .environmentObject(spacetime)
                    }
                    if searching {
                        SearchMenu(searching: $searching, searchText: $searchText)
                            .environmentObject(spacetime)
                    }
                    if let object = spacetime.object {
                        ObjectDetails(object: object)
                            .environmentObject(spacetime)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    if spacetime.object != nil || spacetime.system != spacetime.root {
                        XButton {
                            if spacetime.object != nil {
                                spacetime.object = nil
                            } else {
                                spacetime.backTrigger = true
                            }
                        }
                        .padding(5)
                    }
                }
            } toolbar: {
                if let object = spacetime.object {
                    ObjectToolbar(object: object)
                }
            }
            .sheet(isPresented: self.$showSettings) {
                SettingsView()
            }
            .tint(.mint)
            .onChange(of: spacetime.object, perform: updateDetailModals)
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
