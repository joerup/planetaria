////
////  SearchListView.swift
////  Planetaria
////
////  Created by Joe Rupertus on 1/21/23.
////
//
//import SwiftUI
//
//struct SearchListView: View {
//    
//    @EnvironmentObject var spacetime: Spacetime
//    
//    @State private var searchText: String = ""
//    
//    var system: System
//    
//    private var matchingObjects: [Object] {
//        guard searchText.count > 1 else { return [] }
////        var objects = spacetime.objects.filter { $0.name.lowercased().starts(with: searchText.lowercased()) }
////        objects += spacetime.objects.filter { !objects.contains($0) && $0.name.lowercased().contains(searchText.lowercased()) }
////        objects += spacetime.objects.filter { !objects.contains($0) && $0.subtitle.lowercased().starts(with: searchText.lowercased()) }
////        objects += spacetime.objects.filter { !objects.contains($0) && $0.subtitle.lowercased().contains(searchText.lowercased()) }
////        return objects
//        return []
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            
//            Text("Search")
//                .font(.system(.largeTitle, design: .rounded, weight: .bold))
//                .padding()
//            
//            HStack {
//                Image(systemName: "magnifyingglass")
//                TextField("Search", text: self.$searchText)
//            }
//            .padding()
//            .background(Color.init(white: 0.7).opacity(0.2).cornerRadius(15))
//            .padding(.horizontal)
//            
//            ScrollView {
//                VStack {
//                    ForEach(matchingObjects, id: \.id) { object in
//                        ObjectRow(object: object)
//                    }
//                }
//                .padding()
//            }
//        }
//    }
//}
