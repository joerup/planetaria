//
//  Navigator.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/27/23.
//

import SwiftUI

struct Navigator<Content: View, Menu: View, Detail: View, Header: View, Toolbar: View>: View {
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    private let detents: Set<PresentationDetent> = [.preview, .small, .large]
    @State private var savedDetent: PresentationDetent = .preview
    @State private var selectedDetent: PresentationDetent = .preview
    #endif
    
    @Binding var showDetail: Bool
    
    @ViewBuilder var menu: () -> Menu
    @ViewBuilder var detail: () -> Detail
    @ViewBuilder var header: () -> Header
    @ViewBuilder var toolbar: () -> Toolbar
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        
        #if os(iOS)
        GeometryReader { geometry in
            if horizontalSizeClass == .compact && verticalSizeClass == .regular {
                content()
                    .padding(.bottom, selectedDetent.height(size: geometry.size))
                    .overlay(alignment: .top) {
                        header()
                    }
                    .overlay(alignment: .bottom) {
                        toolbar()
                            .padding(.bottom, selectedDetent.height(size: geometry.size))
                    }
                    .animation(.default, value: selectedDetent)
                    .sheet(isPresented: .constant(true)) {
                        menu()
                            .overlay {
                                if showDetail {
                                    detail()
                                        .background(.regularMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .ignoresSafeArea(edges: .bottom)
                                }
                            }
                            .presentationDetents(detents, selection: $selectedDetent)
                            .presentationBackgroundInteraction(.enabled)
                            .presentationBackground(.ultraThinMaterial)
                            .presentationCornerRadius(20)
                            .interactiveDismissDisabled()
                            .preferredColorScheme(.dark)
                    }
                    .onChange(of: showDetail) { _, showDetail in
                        if !showDetail {
                            selectedDetent = savedDetent
                        } else {
                            savedDetent = selectedDetent
                            if selectedDetent != .small {
                                selectedDetent = .preview
                            }
                        }
                    }
            } else {
                content()
                    .padding(.leading, min(geometry.size.width*0.5, 375) + 10)
                    .overlay {
                        HStack(spacing: 0) {
                            menu()
                                .background(.ultraThinMaterial)
                                .transition(.move(edge: .bottom))
                                .overlay {
                                    if showDetail {
                                        detail()
                                            .background(.regularMaterial)
                                            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))
                                            .transition(.move(edge: .bottom))
                                    }
                                }
                                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))
                                .frame(width: min(geometry.size.width*0.5, 375))
                                .padding([.leading, .top], 10)
                                .ignoresSafeArea(edges: .bottom)
                            VStack {
                                header()
                                Spacer()
                                toolbar()
                            }
                        }
                    }
            }
        }
        
        #elseif os(macOS)
        NavigationSplitView {
            menu()
                .overlay {
                    if showDetail {
                        detail()
                            .background(.background)
                    }
                }
        } detail: {
            content()
                .overlay(alignment: .top) {
                    header()
                }
                .overlay(alignment: .bottom) {
                    toolbar()
                }
        }
        
        #elseif os(tvOS)
        content()
        
        #elseif os(visionOS)
        menu()
            .sheet(isPresented: $showDetail) {
                detail()
                    .ornament(attachmentAnchor: .scene(.bottom)) {
                        toolbar()
                    }
            }
        
        #endif
    }
}
