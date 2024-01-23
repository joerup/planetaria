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
    
    @ViewBuilder var menu: () -> Menu
    @ViewBuilder var detail: () -> Detail
    @ViewBuilder var content: () -> Content
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    private let detents: Set<PresentationDetent> = [.small, .large]
    
    @State private var selectedDetent: PresentationDetent = .small
    @State private var detailDetent: PresentationDetent = .small
    
    private var activeDetent: PresentationDetent {
        showDetail ? detailDetent : selectedDetent
    }
    #endif
    
    var body: some View {
        
        #if os(iOS)
        GeometryReader { geometry in
            if horizontalSizeClass == .compact && verticalSizeClass == .regular {
                content()
                    .overlay(alignment: .top) {
                        Header(showSettings: $showSettings)
                    }
                    .overlay(alignment: .bottom) {
                        Toolbar().padding(10)
                    }
                    .padding(.bottom, PresentationDetent.small.height(size: geometry.size))
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
                        detailDetent = .small
                        selectedDetent = .small
                    }
            } else {
                content()
                    .padding(.leading, min(geometry.size.width*0.5, 375))
                    .overlay {
                        HStack(spacing: 0) {
                            menu()
                                .background(Color(uiColor: .systemGray5))
                                .opacity(showDetail ? 0 : 1)
                                .overlay {
                                    if showDetail {
                                        detail()
                                            .overlay(alignment: .topTrailing) { closeButton.padding(10) }
                                            .background(Color(uiColor: .systemGray5))
                                            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))
                                    }
                                }
                                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))
                                .frame(width: min(geometry.size.width*0.5, 375))
                                .padding([.leading, .top], 10)
                                .ignoresSafeArea(edges: .bottom)
                                .preferredColorScheme(.dark)
                            VStack {
                                Header(showSettings: $showSettings)
                                Spacer()
                                Toolbar()
                                    .padding()
                            }
                        }
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
                Header(showSettings: $showSettings)
                    .padding()
                    .glassBackgroundEffect()
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

extension PresentationDetent {
    
    static var small: PresentationDetent {
        .height(250)
    }
    
    func height(size: CGSize) -> CGFloat {
        if self == .small {
            return 250
        } else {
            return size.height*0.4
        }
    }
    var offsetFraction: CGFloat {
        if self == .small {
            return 0
        } else {
            return 0.4
        }
    }
}
