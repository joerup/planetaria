//
//  SearchMenu.swift
//
//
//  Created by Joe Rupertus on 9/22/23.
//

import SwiftUI
import PlanetariaData

public struct SearchMenu: View {
    
    @EnvironmentObject var spacetime: Spacetime
    
    @Binding var searching: Bool
    @Binding var searchText: String
    
    @State private var nodes: [Node] = []
    
    @FocusState private var isFocused: Bool
    
    public init(searching: Binding<Bool>, searchText: Binding<String>) {
        self._searching = searching
        self._searchText = searchText
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack {
                TextField("Search", text: $searchText)
                    .focused($isFocused)
                Button {
                    withAnimation {
                        searchText = ""
                        searching = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                }
            }
            .padding(.leading, 5)
            .padding(5)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding()
                
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                    ForEach(nodes) { node in
                        if let object = node.object {
                            Button {
                                withAnimation {
                                    spacetime.object = object
                                }
                            } label: {
                                ObjectCard(object: object)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color.init(white: 0.1))
        .onAppear {
            isFocused = true
        }
        .onChange(of: searchText) { text in
            findMatches(to: text)
        }
    }
    
    private func findMatches(to text: String) {
        if let node = spacetime.root {
            self.nodes = findMatchingNodes(to: text, at: node)
        }
    }
    
    private func findMatchingNodes(to text: String, at node: Node) -> [Node] {
        var matchingNodes: [Node] = []
        node.children.forEach { child in
            if child.isObject && child.name.starts(with: text) {
                matchingNodes += [child]
            } else if child.isSystem {
                matchingNodes += findMatchingNodes(to: text, at: child)
            }
        }
        return matchingNodes
    }
}
