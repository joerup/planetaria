////
////  SystemDetailView.swift
////  Planetaria
////
////  Created by Joe Rupertus on 1/14/23.
////
//
//import SwiftUI
//
//struct SystemDetailView: View {
//
//    var system: System
//
//    var body: some View {
//        VStack(alignment: .leading) {
//
//            HStack {
//                VStack(alignment: .leading) {
//                    Text("\(system.name) System")
//                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
//                    DetailText(system.fullName, system.subtitle)
//                        .font(.system(.headline, design: .rounded, weight: .semibold))
//                        .foregroundColor(.init(white: 0.8))
//                }
//                Spacer()
//            }
//            .padding([.horizontal, .top])
//
//            ScrollView {
//
//                VStack(alignment: .leading) {
//
//                    DetailSection(objects: system.stars) { star in
//                        ObjectRow(object: star)
//                    }
//                    DetailSection(objects: system.majorPlanets) { planet in
//                        ObjectRow(object: planet)
//                    }
//                    if !system.stars.isEmpty {
//                        DetailSection(objects: system.dwarfPlanets) { dwarfPlanet in
//                            ObjectRow(object: dwarfPlanet)
//                        }
//                    }
//
//                    Footnote()
//                        .padding(.top)
//                }
//                .padding()
//            }
//        }
//    }
//}
