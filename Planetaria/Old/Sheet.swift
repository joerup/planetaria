//
//  Sheet.swift
//  Planetaria
//
//  Created by Joe Rupertus on 5/31/23.
//

import SwiftUI
import PlanetariaData

struct DetailConstants {
    static var verticalSheetPartial: CGFloat = 0.3
    static var verticalSheetCollapsed: CGFloat = 0.12
    static var horizontalSheetMaximum: CGFloat = 425
}

struct Sheet<Content: View>: View {
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    #endif
    var previewSizeClass: Bool {
        #if os(iOS)
        return horizontalSizeClass == .compact && verticalSizeClass == .regular
        #else
        return false
        #endif
    }
    
    @EnvironmentObject var spacetime: Spacetime
    
    @Binding var isPresented: Bool
    @Binding var displayMode: SheetMode
    
    var size: CGSize
    
    var buttons: [(action: () -> Void, label: String)] = []
    
    @ViewBuilder var content: () -> Content
    
    @GestureState private var dragOffset: CGSize = .zero
    @State private var staticOffset: CGSize = .zero
    @State private var startOffset: CGFloat = 1
    
    private var fullHeight: CGFloat {
        -size.height * (1 - DetailConstants.verticalSheetCollapsed)
    }
    private var partialHeight: CGFloat {
        -size.height * (-DetailConstants.verticalSheetCollapsed + DetailConstants.verticalSheetPartial)
    }
    private var collapsedHeight: CGFloat {
        .zero
    }
    
    private var accentColor: Color? {
        return spacetime.object?.color
    }
    
    @ViewBuilder
    var body: some View {
        if previewSizeClass {
            #if os(iOS)
            ZStack {
                if displayMode != .full {
                    VStack {
                        Spacer()
                        HStack {
                            buttonDisplay
                        }
                        .padding(.horizontal, 5)
                    }
                    .offset(y: !isPresented ? 0 : -size.height + size.height*startOffset + staticOffset.height + dragOffset.height)
                }
                VStack {
                    Spacer()
                    VStack(spacing: 0) {
                        content()
                    }
                    .background(Color.init(white: 0.1).edgesIgnoringSafeArea(.bottom))
                    .cornerRadius(20)
                    .overlay(alignment: .top) {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.init(white: 0.3))
                            .frame(width: 50, height: 5)
                            .padding(.vertical, 5)
                    }
                }
                .offset(y: !isPresented ? size.height : size.height*startOffset + staticOffset.height + dragOffset.height)
                .highPriorityGesture(gesture)
                .onAppear {
                    self.startOffset = 1
                    withAnimation {
                        self.startOffset = 1 - DetailConstants.verticalSheetCollapsed
                        setOffset(for: displayMode)
                    }
                }
                .onChange(of: displayMode) { mode in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        setOffset(for: mode)
                    }
                }
            }
            .transition(.move(edge: .bottom))
            .tint(accentColor)
            #endif
        } else {
            HStack {
                content()
                    .background(Color.init(white: 0.2))
                    .frame(maxWidth: min(DetailConstants.horizontalSheetMaximum, size.width/2))
                    .cornerRadius(20).edgesIgnoringSafeArea(.bottom)
                    .offset(y: !isPresented ? 1 : 0)
                VStack {
                    Spacer()
                    HStack {
                        buttonDisplay
                    }
                }
            }
            .transition(.move(edge: .leading))
            .tint(accentColor)
        }
    }
    
    #if os(iOS)
    private var gesture: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, gestureScale, _ in
                if staticOffset.height + value.translation.height > fullHeight {
                    gestureScale = value.translation
                }
            }
            .onEnded { value in
                if value.translation.height < 0 {
                    if displayMode == .collapsed && abs(value.translation.height) < abs(collapsedHeight-partialHeight) {
                        setDisplay(.partial)
                    } else {
                        setDisplay(.full)
                    }
                }
                else if value.translation.height > 0 {
                    if displayMode == .full && abs(value.translation.height) < abs(partialHeight-fullHeight) {
                        setDisplay(.partial)
                    } else {
                        setDisplay(.collapsed)
                    }
                }
                if staticOffset.height + value.translation.height > fullHeight {
                    staticOffset.height += value.translation.height
                } else {
                    staticOffset.height = fullHeight
                }
            }
    }
    #endif
    
    @ViewBuilder
    private var buttonDisplay: some View {
        Spacer()
        HStack(spacing: 0) {
            ForEach(buttons.indices, id: \.self) { index in
                let button = buttons[index]
                Button(button.label) {
                    button.action()
                }
                .font(.headline)
                .padding()
                .cornerRadius(20)
                .padding(5)
            }
        }
        .background(.thickMaterial)
        .cornerRadius(25)
        .padding()
        Spacer()
    }
    
    private func setDisplay(_ mode: SheetMode) {
        withAnimation {
            self.displayMode = mode
        }
    }
    
    private func setOffset(for mode: SheetMode) {
        switch mode {
        case .full:
            self.staticOffset.height = fullHeight
        case .partial:
            self.staticOffset.height = partialHeight
        case .collapsed:
            self.staticOffset.height = collapsedHeight
        }
    }
}

enum SheetMode {
    case collapsed
    case partial
    case full
}

