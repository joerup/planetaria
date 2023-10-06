////
////  ObjectStack.swift
////  Planetaria
////
////  Created by Joe Rupertus on 5/31/23.
////
//
//import SwiftUI
//
//struct ObjectStack: View {
//    
//    @EnvironmentObject var spacetime: Spacetime
//    
//    var system: System
//    
//    @State private var path: NavigationPath = .init()
//    
//    var body: some View {
//        
//        NavigationStack(path: $path) {
//            ZStack {
//                Color(uiColor: .systemGray6).edgesIgnoringSafeArea(.bottom)
//                SystemDetailView(system: system)
////                    .onAppear {
////                        withAnimation {
////                            spacetime.selectedObject = nil
////                        }
////                    }
//            }
////            .navigationDestination(for: System.self) { system in
////                SystemDetailView(system: system)
////            }
////            .onChange(of: spacetime.selectedSystem) { system in
////                print("HELLOLOOOOOO")
////                if self.system != system {
////                    path = .init([system])
////                } else {
////                    path = .init()
////                }
////            }
////            .navigationDestination(for: Object.self) { object in
////                if let system = object.hostSystem {
////                    SystemDetailView(system: system)
////                        .onAppear {
////                            if let system = spacetime.selectedSystem, system.objects.contains(object) {
////                                spacetime.selectedObject = object
////                            } else {
////                                spacetime.selectedSystem = object.mainSystem
////                                spacetime.selectedObject = object
////                            }
////                        }
////                }
////            }
////            .onChange(of: spacetime.selectedObject) { object in
////                if let object, object.hostSystem != nil {
////                    self.path = .init([object])
////                } else {
////                    self.path = .init()
////                }
////            }
//        }
//        .background(Color(uiColor: .systemGray6))
//    }
//}
