//
//  DetailSection.swift
//  Planetaria
//
//  Created by Joe Rupertus on 1/15/23.
//

import SwiftUI

struct DetailSection<Content: View, Data: Identifiable>: View {
    
    var objects: [Data]
    @ViewBuilder var content: (Data) -> Content
    
    var body: some View {
        if !objects.isEmpty {
            VStack(alignment: .leading) {
                ForEach(objects, id: \.id, content: content)
            }
            .padding(.bottom)
        }
    }
}
