//
//  PhotoView.swift
//  Planetaria
//
//  Created by Joe Rupertus on 1/20/24.
//

import SwiftUI
import PlanetariaData

struct PhotoView: View {
    
    @State private var showFullScreen: Bool = false
    
    var photo: Photo
    
    var body: some View {
        Button {
            showFullScreen = true
        } label: {
            Image("\(photo.name)_preview")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        #if os(iOS) || os(visionOS)
        .fullScreenCover(isPresented: $showFullScreen) {
            fullScreen
        }
        #elseif os(macOS)
        .sheet(isPresented: $showFullScreen) {
            fullScreen
        }
        #endif
    }
    
    private var fullScreen: some View {
        Image(photo.name)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .topTrailing) {
                ControlButton(icon: "xmark") {
                    showFullScreen = false
                }
                .padding()
            }
            .overlay(alignment: .bottomLeading) {
                HStack {
                    Text(photo.desc)
                    Text("|")
                    if let source = URL(string: photo.source) {
                        Link(destination: source) {
                            Text("Source")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding()
            }
    }
}
