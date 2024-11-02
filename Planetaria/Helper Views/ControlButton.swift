//
//  ControlButton.swift
//  Planetaria
//
//  Created by Joe Rupertus on 10/31/24.
//

import SwiftUI

struct ControlButton: View {
    
    var icon: String
    var isActive: Bool = false
    
    var action: () -> Void
    
    var body: some View {
            
        #if os(visionOS)
        Button(action: action) {
            Image(systemName: icon)
                .bold()
                .foregroundStyle(.mint)
                .opacity(isActive ? 0.5 : 1.0)
        }
        .buttonBorderShape(.circle)
        
        #else
        Button(action: action) {
            Image(systemName: icon)
                .bold()
                .opacity(isActive ? 0.5 : 1.0)
                .frame(minWidth: 40, minHeight: 40)
                .foregroundStyle(.mint)
                .background(Color(white: isActive ? 0.3 : 0.15).opacity(0.5))
                .clipShape(Circle())
        }
        
        #endif
    }
}
