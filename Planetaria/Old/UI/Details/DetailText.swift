//
//  DetailText.swift
//  Planetaria
//
//  Created by Joe Rupertus on 1/18/23.
//

import SwiftUI

struct DetailText: View {
    
    private var name: String
    private var defaultSubtitle: String?
    private var arguments: [CVarArg]
    private var type: DetailType
    
    init(_ name: String, _ type: DetailType, arguments: [CVarArg] = []) {
        self.name = name
        self.defaultSubtitle = nil
        self.arguments = arguments
        self.type = type
    }
    init(_ name: String, _ subtitle: String?) {
        self.name = name
        self.defaultSubtitle = subtitle
        self.arguments = []
        self.type = .subtitle
    }
    
    private var key: String {
        return "\(name) \(type.rawValue)"
    }
    private var hasLocalizedString: Bool {
        return NSLocalizedString(key, comment: "") != key
    }
    
    var body: some View {
        if hasLocalizedString {
            Text(String(format: NSLocalizedString(key, comment: ""), arguments: arguments))
                .fixedSize(horizontal: false, vertical: true)
        } else if let defaultSubtitle {
            Text(defaultSubtitle)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    enum DetailType: String {
        case subtitle = "Subtitle"
        case description = "Description"
    }
}
