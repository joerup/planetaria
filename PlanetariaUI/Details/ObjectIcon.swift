//
//  ObjectIcon.swift
//
//
//  Created by Joe Rupertus on 12/22/23.
//

import SwiftUI
import PlanetariaData

public struct ObjectIcon: View {
    
    var object: Object
    var size: CGFloat
    
    public init(object: Object, size: CGFloat) {
        self.object = object
        self.size = size
    }
    
    public var body: some View {
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
