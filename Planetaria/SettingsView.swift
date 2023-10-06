//
//  SettingsView.swift
//  Planetaria
//
//  Created by Joe Rupertus on 5/25/23.
//

import SwiftUI
import PlanetariaData

struct SettingsView: View {
    
    @EnvironmentObject var spacetime: Spacetime
    
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Settings")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .padding()
            
            ScrollView {
                VStack(spacing: 20) {
                    VStack {
                        link(to: URL(string: "https://planetaria.app"), icon: "cursorarrow", title: "Visit our Website")
                        link(to: URL(string: "https://planetaria.app/support"), icon: "questionmark.circle", title: "Contact Support")
                        link(to: URL(string: "https://planetaria.app/privacy"), icon: "hand.raised.fill", title: "Privacy Policy")
                    }
                }
                .padding()
                VStack(spacing: 20) {
                    Text("planetaria")
                        .font(.custom("Outfit-Bold", size: 36, relativeTo: .headline))
                        .foregroundColor(.mint)
                    Text("Version \(appVersion ?? "")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private func link(to url: URL?, icon: String, title: String) -> some View {
        if let url {
            Link(destination: url) {
                HStack {
                    Image(systemName: icon)
                        .imageScale(.small)
                        .foregroundColor(.mint)
                        .padding(.trailing, 5)
                    Text(title)
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .imageScale(.small)
                        .foregroundColor(Color.init(white: 0.4))
                        .padding(.trailing, 5)
                }
            }
            .padding()
            .background(Color.init(white: 0.2).cornerRadius(10))
        }
    }
}

