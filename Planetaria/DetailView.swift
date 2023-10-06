//
//  DetailView.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/27/23.
//

import SwiftUI
import PlanetariaData
import PlanetariaUI

struct DetailView<Details: View, Toolbar: View>: ViewModifier {
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    #endif
    
    var detents: Set<PresentationDetent>
    @Binding var selectedDetent: PresentationDetent
    
    @State private var showSidebar: Bool = true
    
    @ViewBuilder var details: () -> Details
    @ViewBuilder var toolbar: () -> Toolbar
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            #if os(iOS)
            if horizontalSizeClass == .compact {
                content
                    .padding(.bottom, selectedDetent.height(size: geometry.size))
                    .overlay(alignment: .bottom) {
                        toolbar()
                            .padding(.bottom, selectedDetent.height(size: geometry.size))
                    }
                    .animation(.default, value: selectedDetent)
                    .sheet(isPresented: .constant(true)) {
                        details()
                            .presentationDetents(detents, selection: $selectedDetent)
                            .presentationBackgroundInteraction(.enabled)
                            .presentationCornerRadius(20)
                            .interactiveDismissDisabled()
                            .preferredColorScheme(.dark)
                    }
            } else {
                content
                    .padding(.leading, showSidebar ? min(geometry.size.width*0.4, 400) : 0)
                    .overlay {
                        if showSidebar {
                            HStack(alignment: .bottom) {
                                details()
                                    .frame(width: min(geometry.size.width*0.4, 400))
                                    .background(Color(uiColor: .systemFill).cornerRadius(20))
                                Spacer()
                                toolbar()
                            }
                        }
                    }
            }
            #elseif os(macOS)
            NavigationSplitView {
                details()
            } detail: {
                content
                    .toolbar {
                        Header()
                    }
            }
            #endif
        }
    }
}

extension View {
    func details<Details: View, Toolbar: View>(
        detents: Set<PresentationDetent>,
        selectedDetent: Binding<PresentationDetent>,
        @ViewBuilder details: @escaping () -> Details,
        @ViewBuilder toolbar: @escaping () -> Toolbar = { EmptyView() }
    ) -> some View {
        return modifier(DetailView(detents: detents, selectedDetent: selectedDetent, details: details, toolbar: toolbar))
    }
}
