//
//  ObjectIcon.swift
//  Planetaria
//
//  Created by Joe Rupertus on 1/27/24.
//

import Foundation
import SwiftUI

struct ObjectIcon: View {
    
    var icon: String
    var size: CGFloat
    
    var body: some View {
        Group {
            #if os(macOS)
            if let image = NSImage.init(named: icon) {
                Image(nsImage: image).resizable()
            }
            else {
                Circle().fill(Color.init(white: 0.3)).padding(size*0.15)
            }
            #else
            if let image = UIImage.init(named: icon) {
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
