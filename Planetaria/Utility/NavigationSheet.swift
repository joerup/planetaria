//
//  NavigationSheet.swift
//  Planetaria
//
//  Created by Joe Rupertus on 1/21/24.
//

import SwiftUI

struct NavigationSheet<Header: View, Content: View>: View {
    
    var header: () -> Header
    var content: () -> Content
    
    @State private var scrollPosition: Int? = 0
    
    var body: some View {
        #if os(macOS)
        ScrollView {
            VStack(alignment: .leading) {
                header()
                content()
            }
        }
        #elseif os(visionOS)
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    Rectangle().opacity(0).frame(height: 1).id(0)
                    header().opacity(0).id(1).padding(.bottom)
                    content().id(2)
                }
                .scrollTargetLayout()
                .safeAreaPadding(.horizontal)
            }
            .scrollPosition(id: $scrollPosition)
            .contentMargins(.top, 90, for: .scrollIndicators)
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    header()
                    Spacer(minLength: 0)
                }
                .background(.thinMaterial)
                Divider()
                    .opacity(scrollPosition == 0 ? 0 : 1)
                    .animation(.default, value: scrollPosition)
            }
        }
        .foregroundStyle(.white)
        #else
        ZStack(alignment: .top) {
            if #available(iOS 17.0, *) {
                ScrollView {
                    VStack(spacing: 0) {
                        Rectangle().opacity(0).frame(height: 1).id(0)
                        header().opacity(0).id(1)
                        content().id(2)
                    }
                    .scrollTargetLayout()
                    .safeAreaPadding(.horizontal)
                }
                .scrollPosition(id: $scrollPosition)
                .contentMargins(.top, 90, for: .scrollIndicators)
            } else {
                ScrollView {
                    VStack {
                        header().opacity(0)
                        content()
                    }
                    .padding(.horizontal)
                }
            }
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    header()
                    Spacer(minLength: 0)
                }
                .background(Color(uiColor: .systemGray5).opacity(0.95))
                Divider()
                    .opacity(scrollPosition == 0 ? 0 : 1)
                    .animation(.default, value: scrollPosition)
            }
        }
        .foregroundStyle(.white)
        #endif
    }
}

