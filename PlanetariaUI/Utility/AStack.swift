//
//  AStack.swift
//  Planetaria
//
//  Created by Joe Rupertus on 1/26/23.
//

import SwiftUI

public struct AStack<Content: View>: View {
    
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    @ViewBuilder var content: () -> Content
    
    public var body: some View {
        if dynamicTypeSize >= .accessibility1 {
            HStack {
                VStack(alignment: .leading, content: content)
                Spacer()
            }
        } else {
            HStack(content: content)
        }
    }
}
