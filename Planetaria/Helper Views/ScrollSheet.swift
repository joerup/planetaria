//
//  ScrollSheet.swift
//  Planetaria
//
//  Created by Joe Rupertus on 10/24/24.
//

import SwiftUI

struct ScrollSheet<Content: View>: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.dismiss) var dismiss
    
    var title: String
    
    var content: () -> Content
    
    @State private var scrollPosition: Int? = 0
    
    var body: some View {
        
        #if os(iOS)
        ZStack(alignment: .top) {
            if #available(iOS 17.0, *) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Rectangle()
                            .opacity(0)
                            .frame(height: 1)
                            .id(0)
                        Text(title)
                            .font(.system(.title, design: .default, weight: .semibold))
                            .padding(.top, 8)
                            .id(1)
                        content()
                            .id(2)
                    }
                    .scrollTargetLayout()
                    .padding(.horizontal)
                    .padding(.top)
                }
                .scrollPosition(id: $scrollPosition)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(title)
                            .font(.system(.title, design: .default, weight: .semibold))
                            .padding(.top, 8)
                        content()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
            }
            VStack(spacing: 0) {
                Text(title)
                    .bold()
                    .padding()
                Divider()
            }
            .frame(maxWidth: .infinity, minHeight: 56)
            .background {
                Color(uiColor: .systemGray6)
                    .opacity(0.9)
                    .ignoresSafeArea(edges: .top)
            }
            .opacity(scrollPosition == 2 ? 1 : 0)
            .animation(.easeInOut, value: scrollPosition)
            .overlay(alignment: .topTrailing) {
                closeButton
                    .padding(8)
            }
            .onTapGesture {
                withAnimation {
                    scrollPosition = 0
                }
            }
        }
        .foregroundStyle(.white)
        
        #elseif os(macOS)
        NavigationStack {
            VStack(alignment: .leading) {
                content()
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    closeButton
                }
            }
        }
        
        #elseif os(visionOS)
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.system(.largeTitle, design: .default, weight: .semibold))
                        .padding(.top, 8)
                    content()
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .overlay(alignment: .topTrailing) {
                closeButton
                    .padding()
            }
        }
        
        #endif
    }
    
    private var closeButton: some View {
        ControlButton(icon: "xmark") {
            dismiss()
        }
    }
}

