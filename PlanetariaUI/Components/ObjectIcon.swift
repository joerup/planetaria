//
//  ObjectIcon.swift
//
//
//  Created by Joe Rupertus on 12/22/23.
//

import SwiftUI
import PlanetariaData

struct ObjectIcon: View {
    
    var object: Object
    var size: CGFloat
    
    var body: some View {
        Group {
            #if os(macOS)
            if let image = NSImage.init(named: object.name) {
                Image(nsImage: image).resizable()
            }
            else {
                Circle().fill(Color.init(white: 0.3)).padding(size*0.15)
            }
            #else
            if let image = UIImage.init(named: object.name) {
                Image(uiImage: image).resizable()
            }
            else {
                Circle().fill(Color.init(white: 0.3)).padding(size*0.15)
            }
            #endif
        }
        .frame(width: size, height: size)
    }
}
