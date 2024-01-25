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
    
    init(object: ObjectNode) {
        self.object = object
    }
    
    var body: some View {
        VStack {
            ObjectIcon(object: object, size: 60)
            Text(object.name)
                .font(.system(.caption, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(width: 80)
        .padding(.vertical)
        .background(Color.gray.opacity(0.1).cornerRadius(15))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
