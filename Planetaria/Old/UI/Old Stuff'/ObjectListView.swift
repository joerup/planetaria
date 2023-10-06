////
////  ObjectListView.swift
////  Planetaria
////
////  Created by Joe Rupertus on 1/15/23.
////
//
//import SwiftUI
//
//struct ObjectListView: View {
//    
//    var title: String
//    var objects: [Object]
//    
//    var systemTitle: String {
//        return title.replacing("Moons", with: "System")
//    }
//    
//    var body: some View {
//        ScrollView {
//            LazyVStack(alignment: .leading) {
//                DetailText(systemTitle, .description)
//                    .font(.system(.callout, design: .rounded))
//                    .foregroundColor(.init(white: 0.9))
//                    .padding(.horizontal, 2)
//                    .padding(.bottom)
//                ForEach(objects, id: \.id) { object in
//                    DetailRow(name: object.name, subtitle: object.idTitle ?? object.subtitle, image: object.name, color: object.backgroundColor) {
//                        ObjectDetailView(object: object)
//                    }
//                }
//            }
//            .padding()
//        }
//        .navigationTitle(title)
////        .xButton()
//    }
//}
