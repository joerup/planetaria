//
//  CStack.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 12/2/24.
//

import SwiftUI

public struct CStack<Content: View>: View {
    let isVertical: Bool
    @ViewBuilder let content: () -> Content

    public init(isVertical: Bool, @ViewBuilder content: @escaping () -> Content) {
        self.isVertical = isVertical
        self.content = content
    }

    public var body: some View {
        if isVertical {
            VStack { content() }
        } else {
            HStack { content() }
        }
    }
}
