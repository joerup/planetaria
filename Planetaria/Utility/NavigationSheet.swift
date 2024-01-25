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
                }
                .scrollPosition(id: $scrollPosition)
                .contentMargins(.top, 90, for: .scrollIndicators)
            } else {
                ScrollView {
                    VStack {
                        header().opacity(0)
                        content()
                    }
                }
            }
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    header()
                    Spacer(minLength: 0)
                }
                #if os(visionOS)
                .glassBackgroundEffect()
                #else
                .background(Color(uiColor: .systemGray5).opacity(0.95))
                #endif
                Divider()
                    .opacity(scrollPosition == 0 ? 0 : 1)
                    .animation(.default, value: scrollPosition)
            }
        }
        .foregroundStyle(.white)
        #endif
    }
}

