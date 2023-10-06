//
//  XButton.swift
//  Planetaria
//
//  Created by Joe Rupertus on 1/14/23.
//

import SwiftUI

public struct XButton: View {
    
    var action: () -> Void
    
    public init(action: @escaping () -> Void) {
        self.action = action
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .font(.title)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close")
        .tint(.gray)
    }
}
