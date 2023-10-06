////
////  DetailSheet.swift
////  Planetaria
////
////  Created by Joe Rupertus on 5/19/23.
////
//
//import SwiftUI
//import PlanetariaData
//
//struct DetailSheet<Content: View>: View {
//    
//    @Environment(\.horizontalSizeClass) var horizontalSizeClass
//    @Environment(\.verticalSizeClass) var verticalSizeClass
//    var previewSizeClass: Bool {
//        return horizontalSizeClass == .compact && verticalSizeClass == .regular
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
//    @State private var startOffset: CGFloat = 1
//    
//    @ViewBuilder
//    var body: some View {
//        if previewSizeClass {
//            VStack {
//                Spacer()
//                VStack(spacing: 0) {
//                    RoundedRectangle(cornerRadius: 2)
//                        .frame(width: 40, height: 5)
//                        .foregroundColor(.init(white: 0.2))
//                        .padding(.top, 5)
//                    content()
//                }
//                .background(Color.black.cornerRadius(20).edgesIgnoringSafeArea(.bottom))
//                .offset(y: size.height*startOffset + dragOffset.height)
//                .gesture(DragGesture()
//                    .updating($dragOffset) { value, gestureScale, _ in
//                        if gestureScale.height + value.translation.height >= -size.height {
//                            gestureScale = value.translation
//                        }
//                    }
//                    .onEnded { value in
//                        if value.translation.height > 0 {
//                            withAnimation {
//                                onDismiss()
//                            }
//                        }
//                    }
//                )
//                .onAppear {
//                    self.startOffset = 1
//                    withAnimation {
//                        self.startOffset = 0
//                    }
//                }
//            }
//            .transition(.move(edge: .bottom))
//        } else {
//            HStack {
//                Spacer()
//                content()
//                    .background(Color.black.cornerRadius(20).edgesIgnoringSafeArea(.bottom))
//                    .frame(maxWidth: min(DetailConstants.horizontalSheetMaximum, size.width/2))
//            }
//            .transition(.move(edge: .trailing))
//        }
//    }
//}
