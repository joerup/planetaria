////
////  DetailPreview.swift
////  Planetaria
////
////  Created by Joe Rupertus on 5/24/23.
////
//
//import SwiftUI
//import PlanetariaData
//
//struct DetailPreview<Content: View>: View {
//    
//    #if os(iOS)
//    @Environment(\.horizontalSizeClass) var horizontalSizeClass
//    @Environment(\.verticalSizeClass) var verticalSizeClass
//    #endif
//    var previewSizeClass: Bool {
//        #if os(iOS)
//        return horizontalSizeClass == .compact && verticalSizeClass == .regular
//        #else
//        return false
//        #endif
//    }
//    
//    @EnvironmentObject var spacetime: Spacetime
//    
//    var size: CGSize
//    
//    var onDismiss: () -> Void
//    
//    @ViewBuilder var content: () -> Content
//    
//    @GestureState private var dragOffset: CGSize = .zero
//    @State private var staticOffset: CGSize = .zero
//    @State private var startOffset: CGFloat = 1
//    
//    @ViewBuilder
//    var body: some View {
//        if previewSizeClass {
//            #if os(iOS)
//            VStack {
//                Spacer()
//                content()
//                VStack(spacing: 0) {
//                    RoundedRectangle(cornerRadius: 2)
//                        .frame(width: 40, height: 5)
//                        .foregroundColor(.init(white: 0.2))
//                        .padding(.top, 5)
//                        .onTapGesture {
//                            withAnimation {
//                                if staticOffset.height == 0 {
//                                    staticOffset.height = -size.height * (1 - DetailConstants.verticalSheetPartial)
//                                } else {
//                                    staticOffset = .zero
//                                }
//                            }
//                        }
//                        content()
//                            .overlay {
//                                if staticOffset.height == 0 {
//                                    Color.black.opacity(1E-6)
//                                }
//                            }
//                }
//                .background(Color.init(white: 0.2).cornerRadius(20).edgesIgnoringSafeArea(.bottom))
//                .offset(y: size.height*startOffset + staticOffset.height + dragOffset.height)
//                .gesture(DragGesture()
//                    .updating($dragOffset) { value, gestureScale, _ in
//                        if staticOffset.height + gestureScale.height + value.translation.height >= -size.height * (1 - DetailConstants.verticalSheetPartial) {
//                            gestureScale = value.translation
//                        }
//                    }
//                    .onEnded { value in
//                        staticOffset = staticOffset + value.translation
//                        if value.translation.height < -size.height*0.1 {
//                            withAnimation {
//                                staticOffset.height = -size.height * (1 - DetailConstants.verticalSheetPartial)
//                            }
//                        }
//                        else if value.translation.height > 0 {
//                            withAnimation {
//                                if staticOffset.height >= 0 {
//                                    onDismiss()
//                                    staticOffset = .zero
//                                } else {
//                                    staticOffset.height = 0
//                                }
//                            }
//                        }
//                        else {
//                            withAnimation {
//                                staticOffset = .zero
//                            }
//                        }
//                    }
//                )
//                .onAppear {
//                    self.startOffset = 1
//                    withAnimation {
//                        self.startOffset = 1 - DetailConstants.verticalSheetPartial
//                    }
//                }
//            }
//            .transition(.move(edge: .bottom))
//            #endif
//        } else {
//            HStack {
//                Spacer()
//                VStack(spacing: 0) {
//                    ScrollView {
//                        content()
//                    }
//                }
//                .background(Color.init(white: 0.2).cornerRadius(20).edgesIgnoringSafeArea(.bottom))
//                .frame(maxWidth: min(DetailConstants.horizontalSheetMaximum, size.width/2))
//            }
//            .transition(.move(edge: .trailing))
//        }
//    }
//}
