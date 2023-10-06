//
//  DetailView.swift
//  Planetaria
//
//  Created by Joe Rupertus on 1/15/23.
//

import SwiftUI

struct DetailView<Content: View>: View {
    
    @Environment(\.dismiss) var dismiss
    
    var content: () -> Content
    
    init(content: @escaping () -> Content) {
        
        self.content = content
        
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize, weight: .bold).rounded()]
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont.preferredFont(forTextStyle: .headline).rounded()]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                content()
            }
        }
        .preferredColorScheme(.dark)
        .environmentObject(Dismiss(dismiss))
    }
}
