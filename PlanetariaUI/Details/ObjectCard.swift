//
//  SwiftUIView.swift
//  
//
//  Created by Joe Rupertus on 9/21/23.
//

import SwiftUI
import PlanetariaData

struct ObjectCard: View {
    
    var object: ObjectNode
    
    var body: some View {
        VStack {
            Object3D(object: object)
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
