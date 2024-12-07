//
//  ScrollSheet.swift
//  Planetaria
//
//  Created by Joe Rupertus on 10/24/24.
//

import SwiftUI

struct ScrollSheet<Content: View>: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    var title: String
    var subtitle: String?
    var icon: String?
    
    var backButton: String?
    var backAction: (() -> Void)?
    
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
                        header()
                            .id(1)
                        content()
                            .id(2)
                    }
                    .scrollTargetLayout()
                    .safeAreaPadding(.horizontal)
                    .padding(.top, 8)
                }
                .scrollPosition(id: $scrollPosition)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        header()
                        content()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
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
                header()
                content()
            }
            .padding()
            .overlay(alignment: .topTrailing) {
                closeButton
                    .padding(8)
            }
        }
        
        #elseif os(visionOS)
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header()
                    content()
                }
                .safeAreaPadding(.horizontal)
                .padding(.top)
            }
            .overlay(alignment: .topTrailing) {
                closeButton
                    .padding()
            }
        }
        
        #endif
    }
    
    private func header() -> some View {
        HStack(spacing: 0) {
            if let icon {
                #if os(visionOS)
                ObjectIcon(icon: icon, size: 70)
                    .scaleEffect(1.2)
                    .padding(.trailing, 12)
                    .offset(y: -1)
                #else
                ObjectIcon(icon: icon, size: 60)
                    .scaleEffect(1.2)
                    .padding(.leading, -5)
                    .padding(.trailing, 12)
                    .offset(y: -1)
                #endif
            }
            VStack(alignment: .leading, spacing: 0) {
                if let backButton, let backAction {
                    Button {
                        backAction()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text(backButton)
                                .font(.system(.headline, design: .default, weight: .semibold))
                                .fontDesign(.rounded)
                        }
                        .foregroundStyle(.mint)
                    }
                    #if os(visionOS)
                    .padding(.bottom, 4)
                    #else
                    .padding(.top, 8)
                    .padding(.leading, -2)
                    #endif
                }
                Text(title)
                    #if os(visionOS)
                    .font(.system(.largeTitle, design: .default, weight: .semibold))
                    #else
                    .font(.system(.title, design: .default, weight: .semibold))
                    #endif
                    .fontDesign(.rounded)
                    .padding(.top, 8)
                    .id(1)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(.body, design: .default, weight: .medium))
                        .fontDesign(.rounded)
                        .foregroundStyle(.secondary)
                        .padding(.bottom)
                }
            }
            .dynamicTypeSize(..<DynamicTypeSize.xxxLarge)
        }
    }
    
    private var closeButton: some View {
        ControlButton(icon: "xmark") {
            dismiss()
        }
        .accessibilityLabel("Close")
    }
}

