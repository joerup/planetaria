//
//  Navigator.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/27/23.
//

import SwiftUI
import PlanetariaData

struct Navigator<Content: View, Menu: View, Detail: View>: View {
    
    @Binding var showDetail: Bool
    @Binding var showSettings: Bool
    
    var menuID: Int?
    var detailID: Int?
    
    @ViewBuilder var menu: () -> Menu
    @ViewBuilder var detail: () -> Detail
    @ViewBuilder var content: () -> Content
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    private let detents: Set<PresentationDetent> = [.height(MarginConstants.small), .large]
    
    @State private var selectedDetent: PresentationDetent = .height(MarginConstants.small)
    @State private var detailDetent: PresentationDetent = .height(MarginConstants.small)
    #endif
    
    var body: some View {
        
        #if os(iOS)
        GeometryReader { geometry in
            if horizontalSizeClass == .compact && verticalSizeClass == .regular {
                content()
                    .frame(height: geometry.size.height + MarginConstants.small)
                    .offset(y: -(MarginConstants.small + geometry.safeAreaInsets.bottom/2))
                    .overlay(alignment: .top) {
                        Header(showSettings: $showSettings)
                    }
                    .overlay(alignment: .bottom) {
                        Toolbar()
                            .padding(10)
                            .offset(y: -2 * MarginConstants.small)
                    }
                    .sheet(isPresented: .constant(true)) {
                        menu()
                            .sheet(isPresented: $showDetail) {
                                detail()
                                    .padding(.top, 3)
                                    .overlay(alignment: .topTrailing) { closeButton.padding(10) }
                                    .presentationDetents(detents, selection: $detailDetent)
                                    .presentationBackground(Color(uiColor: .systemGray5))
                                    .presentationBackgroundInteraction(.enabled)
                                    .presentationCornerRadius(20)
                                    .interactiveDismissDisabled()
                                    .sheet(isPresented: $showSettings) {
                                        Settings()
                                    }
                            }
                            .presentationDetents(detents, selection: $selectedDetent)
                            .presentationBackground(Color(uiColor: .systemGray5))
                            .presentationBackgroundInteraction(.enabled)
                            .presentationCornerRadius(20)
                            .interactiveDismissDisabled()
                            .preferredColorScheme(.dark)
                            .sheet(isPresented: $showSettings) {
                                Settings()
                            }
                    }
                    .preferredColorScheme(.dark)
                    .onChange(of: showDetail) { _, showDetail in
                        detailDetent = .height(MarginConstants.small)
                        selectedDetent = .height(MarginConstants.small)
                    }
            } else {
                content()
                    .frame(width: geometry.size.width + MarginConstants.large)
                    .overlay {
                        HStack(spacing: 0) {
                            ZStack {
                                menu()
                                    .id(menuID)
                                    .background(Color(uiColor: .systemGray5))
                                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))
                                    .shadow(radius: 10)
                                    .transition(.move(edge: .bottom))
                                    .animation(.default, value: menuID)
                                if showDetail {
                                    detail()
                                        .id(detailID)
                                        .overlay(alignment: .topTrailing) { closeButton.padding(10) }
                                        .background(Color(uiColor: .systemGray5))
                                        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))
                                        .shadow(radius: 10)
                                        .transition(.move(edge: .bottom))
                                        .animation(.default, value: detailID)
                                }
                            }
                            .transition(.move(edge: .bottom))
                            .animation(.default, value: showDetail)
                            .frame(width: MarginConstants.large)
                            .padding([.leading, .top], 10)
                            .ignoresSafeArea(edges: .bottom)
                            .preferredColorScheme(.dark)
                            
                            VStack {
                                Header(showSettings: $showSettings)
                                Spacer()
                                Toolbar()
                                    .padding(10)
                            }
                        }
                        .padding(.trailing, MarginConstants.large)
                    }
                    .sheet(isPresented: $showSettings) {
                        Settings()
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
                    Header(showSettings: $showSettings)
                }
                .overlay(alignment: .bottom) {
                    Toolbar()
                        .padding(.bottom)
                }
        }
        .preferredColorScheme(.dark)
        
        #elseif os(visionOS)
        menu()
            .opacity(showDetail ? 0 : 1)
            .animation(.default, value: showDetail)
            .sheet(isPresented: $showDetail) {
                detail()
                    .overlay(alignment: .topTrailing) { closeButton.padding(10) }
                    .safeAreaPadding()
                    .ornament(attachmentAnchor: .scene(.bottom)) {
                        Toolbar()
                            .padding()
                            .glassBackgroundEffect()
                    }
            }
            .safeAreaPadding()
            .ornament(attachmentAnchor: .scene(.top)) {
//                Header(showSettings: $showSettings)
//                    .padding()
//                    .glassBackgroundEffect()
            }
            .sheet(isPresented: $showSettings) {
                Settings()
            }
        
        #endif
    }
    
    private var closeButton: some View {
        Button {
            showDetail = false
        } label: {
            Image(systemName: "xmark.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .font(.title)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close")
        .tint(.gray)
    }
}

fileprivate struct MarginConstants {
    static let small: CGFloat = 250
    static let large: CGFloat = 375
}
