//
//  PropertyBox.swift
//  
//
//  Created by Joe Rupertus on 8/28/23.
//

import SwiftUI

struct PropertyBox<Content: View>: View {
    
    var title: String?
    
    @ViewBuilder var content: () -> Content
    
    init(_ title: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title {
                Text(title)
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    .padding(.leading)
            }
            VStack(alignment: .leading, spacing: 10, content: content)
            #if os(iOS)
                .padding()
                .background(.tint.opacity(0.2))
                .cornerRadius(20)
            #endif
        }
    }
}
