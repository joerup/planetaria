//
//  SwiftUIView.swift
//  
//
//  Created by Joe Rupertus on 9/21/23.
//

import SwiftUI
import PlanetariaData

struct ObjectCard: View {
    
    var object: Object
    
    var body: some View {
        VStack {
            ObjectIcon(object: object, size: 75)
                .scaleEffect(1/1.2)
            Text(object.name)
                .font(.system(.body, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding()
        .aspectRatio(1.0, contentMode: .fit)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
