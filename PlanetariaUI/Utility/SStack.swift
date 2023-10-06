//
//  SStack.swift
//  Planetaria
//
//  Created by Joe Rupertus on 5/18/23.
//

import SwiftUI

public struct SStack<Content: View>: View {
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    
    @ViewBuilder var content: () -> Content
    
    public var body: some View {
        #if os(iOS)
        if horizontalSizeClass == .compact {
            VStack(content: content)
        } else {
            HStack(content: content)
        }
        #else
        HStack(content: content)
        #endif
    }
}
