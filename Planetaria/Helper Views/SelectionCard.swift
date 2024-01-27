//
//  SelectionCard.swift
//
//
//  Created by Joe Rupertus on 9/21/23.
//

import SwiftUI
import PlanetariaData

struct SelectionCard: View {
    
    var name: String
    
    var body: some View {
        VStack {
            ObjectIcon(icon: name, size: 60)
            Text(name)
                .font(.system(.caption, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(width: 80)
        .padding(.vertical)
        .background(Color.gray.opacity(0.1).cornerRadius(15))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
