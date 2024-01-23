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
        if let url = URL(string: photo.url) {
            Button {
                showFullScreen = true
            } label: {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                } placeholder: {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.thinMaterial)
                        .aspectRatio(1.0, contentMode: .fill)
                        .overlay(ProgressView().tint(.gray))
                }
            }
            .fullScreenCover(isPresented: $showFullScreen) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView().tint(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .topTrailing) {
                    XButton {
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
    }
}
