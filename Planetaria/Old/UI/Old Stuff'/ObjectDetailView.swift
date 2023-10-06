////
////  ObjectDetailView.swift
////  Planetaria
////
////  Created by Joe Rupertus on 1/15/23.
////
//
//import SwiftUI
//
//struct ObjectDetailView: View {
//    
//    var object: Object
//    
//    @Environment(\.horizontalSizeClass) var horizontalSizeClass
//    @Environment(\.verticalSizeClass) var verticalSizeClass
//    
//    var largeDisplay: Bool {
//        return horizontalSizeClass == .regular && verticalSizeClass == .regular
//    }
//    
//    var body: some View {
//        ScrollView {
//            VStack {
//                
//                if object.hasModel {
//                    Object3DView(object)
//                        .frame(height: largeDisplay ? 400 : 250)
//                } 
//                
//                VStack(alignment: .leading, spacing: 15) {
//                    
//                    VStack(alignment: .leading, spacing: 10) {
//                        
//                        DetailText(object.name, object.subtitle)
//                            .font(.system(.body, design: .rounded, weight: .semibold))
//                            .foregroundColor(.white)
//                        
//                        if let idTitle = object.idTitle {
//                            Text(idTitle)
//                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
//                                .foregroundColor(.white)
//                        }
//                    }
//                    .padding(.bottom, 2)
//                    
//                    VStack(alignment: .leading, spacing: 15) {
//                        
//                        DetailText(object.name, .description)
//                            .font(.system(.callout, design: .rounded))
//                            .foregroundColor(.init(white: 0.9))
//                            .padding(.bottom, 2)
//                        
//                        if let discoveryText {
//                            Text(discoveryText)
//                                .font(.system(.callout, design: .rounded))
//                                .foregroundColor(.init(white: 0.65))
//                        }
//                        if let namesakeText {
//                            Text(namesakeText)
//                                .font(.system(.callout, design: .rounded))
//                                .foregroundColor(.init(white: 0.65))
//                        }
//                    }
//                    .padding(.bottom, 12)
//                    
//                    ForEach(PropertyCategory.allCases, id: \.self) { category in
//                        PropertyGroup(object: object, category: category)
//                    }
//                    
//                    if let planet = object as? Planet, let system = planet.moonSystem {
//                        Text("Moons")
//                            .font(.system(.title2, design: .rounded, weight: .semibold))
//                            .foregroundColor(.white)
//                            .padding(.horizontal, 4)
//                        VStack(alignment: .leading) {
//                            ForEach(system.majorMoons, id: \.id) { moon in
//                                DetailRow(name: moon.name, subtitle: moon.idTitle ?? moon.subtitle, image: moon.name, color: moon.backgroundColor) {
//                                    ObjectDetailView(object: moon)
//                                }
//                            }
//                        }
//                        if !system.minorMoons.isEmpty {
//                            NavigationLink {
//                                ObjectListView(title: "\(system.name) Moons", objects: system.moons)
//                            } label: {
//                                HStack {
//                                    Spacer()
//                                    Text("All \(system.moons.count) Moons")
//                                        .font(.system(.callout, design: .rounded, weight: .semibold))
//                                        .foregroundColor(Color.init(white: 0.7))
//                                    Image(systemName: "chevron.forward")
//                                        .foregroundColor(.white)
//                                    Spacer()
//                                }
//                                .padding(5)
//                            }
//                        }
//                    }
//                    
//                    Footnote()
//                }
//                .padding()
//                .padding(.horizontal, 2)
//            }
//        }
//        .navigationTitle(object.name)
//    }
//    
//    private var discoveryText: String? {
//        if let discoveryYear = object.discoveryYear, let discoveredBy = object.discoveredBy {
//            return "Discovered in \(discoveryYear) by \(discoveredBy)\(discoveredBy.last == "." ? "" : ".")"
//        } else if let discoveryYear = object.discoveryYear {
//            return "Discovered in \(discoveryYear)."
//        } else if let discoveredBy = object.discoveredBy {
//            return "Discovered by \(discoveredBy)\(discoveredBy.last == "." ? "" : ".")"
//        }
//        return nil
//    }
//    
//    private var namesakeText: String? {
//        if let namesake = object.namesake {
//            return "Named after \(namesake)."
//        }
//        return nil
//    }
//}
//
//
