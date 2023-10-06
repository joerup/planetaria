//
//  LoadingScreen.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/31/23.
//

import SwiftUI

struct LoadingScreen: View {
    var body: some View {
        VStack {
            Image("Planetaria Symbol")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 100)
            Text("Planetaria")
                .font(.system(.title, design: .rounded, weight: .bold))
                .padding()
            ProgressView()
        }
    }
}

