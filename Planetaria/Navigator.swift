//
//  Navigator.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/27/23.
//

import SwiftUI
import PlanetariaData

struct Navigator<Content: View, Menu: View, Detail: View>: View {
    
    @Environment(\.scenePhase) var scenePhase
    
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
    
    #elseif os(visionOS)
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
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
                    .frame(width: geometry.size.width + MarginConstants.size(class: horizontalSizeClass) + geometry.safeAreaInsets.leading)
                    .overlay {
                        HStack(spacing: 0) {
                            menu()
                                .id(menuID)
                                .background(Color(uiColor: .systemGray5))
                                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))
                                .shadow(radius: 10)
                                .transition(.move(edge: .bottom))
                                .animation(.default, value: menuID)
                                .overlay {
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
                                .frame(width: MarginConstants.size(class: horizontalSizeClass))
                                .padding([.leading, .top], 10)
                                .ignoresSafeArea(edges: .bottom)
                                .preferredColorScheme(.dark)
                                .sheet(isPresented: $showSettings) {
                                    Settings()
                                }
                            VStack {
                                Header(showSettings: $showSettings)
                                    .padding(.top, geometry.safeAreaInsets.top == 0 ? 5 : 0)
                                Spacer()
                                Toolbar()
                                    .padding(.bottom, horizontalSizeClass == .regular ? 10 : geometry.safeAreaInsets.bottom == 0 ? 5 : 0)
                            }
                        }
                        .padding(.trailing, MarginConstants.size(class: horizontalSizeClass) + geometry.safeAreaInsets.leading)
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
                .overlay(alignment: .topTrailing) { closeButton.padding(10) }
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
            .id(menuID)
            .opacity(showDetail ? 0 : 1)
            .safeAreaPadding()
            .animation(.default, value: menuID)
            .overlay {
                if showDetail {
                    detail()
                        .id(detailID)
                        .overlay(alignment: .topTrailing) { closeButton.padding(10) }
                        .safeAreaPadding()
                        .glassBackgroundEffect()
                        .animation(.default, value: detailID)
                }
            }
            .animation(.default, value: showDetail)
            .ornament(visibility: showDetail ? .visible : .hidden, attachmentAnchor: .scene(.bottom)) {
                Toolbar()
                    .padding()
                    .glassBackgroundEffect()
            }
            .ornament(attachmentAnchor: .scene(.top)) {
                Header(showSettings: $showSettings)
                    .padding()
                    .glassBackgroundEffect()
            }
            .sheet(isPresented: $showSettings) {
                Settings()
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    openWindow(id: "launcher")
                    dismissWindow(id: "navigator")
                }
            }
        
        #endif
    }
    
    private var closeButton: some View {
        XButton {
            showDetail = false
        }
    }
}

fileprivate struct MarginConstants {
    static let small: CGFloat = 250
    static let medium: CGFloat = 300
    static let large: CGFloat = 375
    static func size(class sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        return sizeClass == .regular ? large : medium
    }
}
