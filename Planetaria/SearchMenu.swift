//
//  SearchMenu.swift
//  Planetaria
//
//  Created by Joe Rupertus on 10/19/24.
//

import SwiftUI
import PlanetariaData

struct SearchMenu: View {
    
    @EnvironmentObject var simulation: Simulation
    @Environment(\.dismiss) var dismiss

    @State private var searchText: String = ""
    @State private var results: [ObjectNode] = []
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack {
            #if os(iOS)
            HStack(alignment: .top, spacing: 8) {
                searchBar
                    .padding()
                    .frame(height: 40)
                    .background(.gray.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                closeButton
            }
            .padding(8)
            
            #elseif os(visionOS)
            HStack(alignment: .top, spacing: 8) {
                searchBar
                    .padding()
                    .frame(height: 40)
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                closeButton
            }
            .padding(8)
            
            #endif
            
            resultsList
        }
        .foregroundStyle(.white)
        .tint(nil)
        .onAppear {
            isFocused = true
        }
    }
    
    private var searchBar: some View {
        TextField("Search for any object", text: $searchText)
            .focused($isFocused)
            .tint(.mint)
            .onChange(of: searchText) { text in
                results = simulation.queryObjects(text)
            }
            .onSubmit {
                isFocused = false
            }
    }
    
    private var resultsList: some View {
        ScrollView {
            if !results.isEmpty {
                VStack {
                    ForEach(results) { object in
                        Button {
                            simulation.selectObject(object)
                            dismiss()
                        } label: {
                            SelectionRow(name: object.name, icon: object.name)
                        }
                    }
                }
                .padding([.horizontal, .bottom])
            }
        }
    }
    
    private var closeButton: some View {
        ControlButton(icon: "xmark") {
            dismiss()
        }
    }
}