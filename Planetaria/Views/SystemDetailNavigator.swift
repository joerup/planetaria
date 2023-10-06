//
//  SystemDetailNavigator.swift
//  Planetaria
//
//  Created by Joe Rupertus on 8/10/23.
//

import SwiftUI
import PlanetariaData

struct SystemDetailNavigator: View {
    
    @EnvironmentObject var spacetime: Spacetime
    
    @State private var path: NavigationPath = .init()
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize, weight: .bold).rounded()]
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont.preferredFont(forTextStyle: .headline).rounded()]
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if let root = spacetime.root as? SystemNode {
                    SystemDetails(system: root)
                } else {
                    Color.init(white: 0.1)
                }
            }
            .navigationDestination(for: SystemNode.self) { system in
                SystemDetails(system: system)
            }
        }
        .onChange(of: spacetime.system) { system in
            updateNavigation(system: system)
        }
    }
    
    private func updateNavigation(system: SystemNode?) {
        path = .init()
        if let system, system != spacetime.root {
            for parent in system.parentLine {
                path.append(parent)
            }
            path.append(system)
        }
    }
}
