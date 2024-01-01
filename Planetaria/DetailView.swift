//
//  DetailView.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/27/23.
//

import SwiftUI
import PlanetariaData
import PlanetariaUI

struct DetailView<SystemDetail: View, ObjectDetail: View, Toolbar: View>: ViewModifier {
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    #endif
    
    var detents: Set<PresentationDetent>
    @Binding var selectedDetent: PresentationDetent
    
    var showSidebar: Bool
    var showObject: Bool
    
    @ViewBuilder var systemDetails: () -> SystemDetail
    @ViewBuilder var objectDetails: () -> ObjectDetail
    @ViewBuilder var toolbar: () -> Toolbar
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            #if os(iOS)
            if horizontalSizeClass == .compact && verticalSizeClass == .regular {
                content
                    .padding(.bottom, selectedDetent.height(size: geometry.size))
                    .overlay(alignment: .bottom) {
                        toolbar()
                            .padding(.bottom, selectedDetent.height(size: geometry.size))
                    }
                    .animation(.default, value: selectedDetent)
                    .sheet(isPresented: .constant(true)) {
                        systemDetails()
                            .overlay {
                                if showObject {
                                    objectDetails()
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
            } else {
                content
                    .padding(.leading, (showSidebar ? min(geometry.size.width*0.4, 375) : 0) + 10)
                    .overlay {
                        if showSidebar {
                            HStack(alignment: .bottom, spacing: 0) {
                                systemDetails()
                                    .background(.ultraThinMaterial)
                                    .transition(.move(edge: .bottom))
                                    .overlay {
                                        if showObject {
                                            objectDetails()
                                                .background(.regularMaterial)
                                                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))
                                                .transition(.move(edge: .bottom))
                                        }
                                    }
                                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))
                                    .frame(width: min(geometry.size.width*0.4, 375))
                                    .padding([.leading, .top], 10)
                                    .ignoresSafeArea(edges: .bottom)
                                
                                toolbar()
                            }
                        }
                    }
            }
            #elseif os(macOS)
            NavigationSplitView {
                systemDetails()
                    .overlay {
                        if showObject {
                            objectDetails()
                                .background(.background)
                        }
                    }
            } detail: {
                content
                    .overlay(alignment: .bottom) {
                        toolbar()
                    }
            }
            #endif
        }
    }
}

extension View {
    func details<SystemDetail: View, ObjectDetail: View, Toolbar: View>(
        detents: Set<PresentationDetent>,
        selectedDetent: Binding<PresentationDetent>,
        showSidebar: Bool,
        showObject: Bool,
        @ViewBuilder systemDetails: @escaping () -> SystemDetail,
        @ViewBuilder objectDetails: @escaping () -> ObjectDetail,
        @ViewBuilder toolbar: @escaping () -> Toolbar = { EmptyView() }
    ) -> some View {
        return modifier(DetailView(detents: detents, selectedDetent: selectedDetent, showSidebar: showSidebar, showObject: showObject, systemDetails: systemDetails, objectDetails: objectDetails, toolbar: toolbar))
    }
}
