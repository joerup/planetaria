////
////  SystemListView.swift
////  Planetaria
////
////  Created by Joe Rupertus on 1/22/23.
////
//
//import SwiftUI
//
//struct SystemListView: View {
//    
//    var title: String
//    var systems: [System]
//    
//    @Environment(\.dismiss) var dismiss
//    
//    @Binding var selectedSystem: System?
//    
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                systemList(systems.filter { $0.primaryType == .star })
//                systemList(systems.filter { $0.primaryType == .planet })
//            }
//            .padding()
//        }
//        .navigationTitle(title)
//        .xButton()
//    }
//    
//    private func systemList(_ systems: [System]) -> some View {
//        VStack {
//            ForEach(systems, id: \.id) { system in
//                Button {
//                    withAnimation(.linear.delay(0.2)) {
//                        self.selectedSystem = system
//                        dismiss()
//                    }
//                } label: {
//                    HStack {
//                        VStack(alignment: .leading) {
//                            Text(system.fullName)
//                                .font(.system(.title2, design: .rounded, weight: .semibold))
//                                .foregroundColor(.white)
//                            Text("Explore \(system.subtitle)")
//                                .font(.system(.footnote, design: .rounded, weight: .semibold))
//                                .foregroundColor(.init(white: 0.6))
//                        }
//                        Spacer()
//                        Image(systemName: selectedSystem == system ? "checkmark.circle.fill" : "circle")
//                            .imageScale(.large)
//                            .foregroundColor(.white)
//                            .padding()
//                    }
//                    .padding()
//                    .background(system.firstObject.backgroundColor.overlay(selectedSystem == system ? Color.white.opacity(0.3) : Color.clear).cornerRadius(15))
//                }
//            }
//        }
//    }
//}
