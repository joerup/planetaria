////
////  PropertyGroup.swift
////  Planetaria
////
////  Created by Joe Rupertus on 1/25/23.
////
//
//import SwiftUI
//
//struct PropertyGroup: View {
//
//    var object: Object
//    var category: PropertyCategory
//
//    var body: some View {
//        if category.satisfied(by: object) {
//
//            VStack(alignment: .leading, spacing: 15) {
//
//                HStack {
//
//                    Text(category.title)
//                        .font(.system(.title2, design: .rounded, weight: .semibold))
//                        .foregroundColor(.white)
//
//                    Spacer()
//
//                    if category.isExpandable {
//                        NavigationLink {
//                            PropertyGroupDetails(object: object, category: category)
//                        } label: {
//                            Text("More")
//                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
//                                .foregroundColor(.init(white: 0.7))
//                            Image(systemName: "chevron.forward")
//                                .foregroundColor(.white)
//                                .bold()
//                        }
//                    }
//                }
//                .padding(.horizontal, 4)
//
//                VStack(alignment: .leading, spacing: 5) {
//                    PropertyBlock(object: object, category: category, type: .preview)
//                }
//                .padding()
//                .background(object.backgroundColor.cornerRadius(15))
//            }
//            .padding(.vertical, 5)
//        }
//    }
//}
//
//struct PropertyGroupDetails: View {
//
//    var object: Object
//    var category: PropertyCategory
//
//    var body: some View {
//        DetailView {
//            ScrollView {
//                VStack(alignment: .leading) {
//
////                    if let description = object.categoryDescription(category) {
////                        Text(description)
////                            .multilineTextAlignment(.leading)
////                            .font(.system(.callout, design: .rounded))
////                            .foregroundColor(.white)
////                            .padding(.top, 5)
////                            .padding(.horizontal, 3)
////                            .padding(.horizontal)
////                    }
//
//                    PropertyBlock(object: object, category: category, type: .detail)
//                        .padding(.top)
//
//                    Footnote()
//                        .padding(.horizontal)
//                }
//            }
//        }
//        .navigationTitle(category.title)
//        .xButton()
//    }
//}
