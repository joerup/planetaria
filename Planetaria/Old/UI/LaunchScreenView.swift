//
//  LaunchScreenView.swift
//  Planetaria
//
//  Created by Joe Rupertus on 1/14/23.
//

import SwiftUI

struct LaunchScreenView: View {
    
    var visible: Bool
    
    @State private var logoScale: CGFloat = 1.0
    @State private var flip: SwiftUI.Angle = .zero
    
    @State private var visibility: CGFloat = 1
    @State private var offset: CGSize = .zero
    
    private let colors = [Color.init(red: 0.6, green: 0.9, blue: 0.9), Color.init(red: 0.9, green: 1, blue: 1)]
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    @State private var count: Double = 0
    private let startDate = Date.now
    
    var body: some View {
        
        GeometryReader { geometry in
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image("Planetaria Symbol")
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fit)
                        .frame(maxWidth: min(400, geometry.size.width*0.5, geometry.size.height*0.5))
                        .scaleEffect(logoScale)
                        .rotationEffect(flip)
                        .offset(offset)
                    Spacer()
                }
                VStack(spacing: 20) {
                    Text("planetaria")
                        .font(.custom("Outfit-Bold", size: 36, relativeTo: .headline))
                        .gradientForeground(colors: colors)
                        .opacity(logoScale)
                    Text("Version \(appVersion ?? "")")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .opacity(logoScale)
                }
//                .offset(offset * -1)
                Spacer()
            }
        }
        .background(Image("StarrySky"))
        .opacity(visibility)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            withAnimation(.easeInOut(duration: 1)) {
                logoScale = 1.0
            }
        }
        #if !os(macOS)
        .onChange(of: visible) { visible in
            if !visible {
                withAnimation(.easeInOut(duration: 1)) {
                    logoScale = 1E-6
                }
                withAnimation(.easeInOut(duration: 2)) {
                    visibility = 0
                }
            }
        }
        #endif
    }
}
