////
////  DetailRow.swift
////  Planetaria
////
////  Created by Joe Rupertus on 1/15/23.
////
//
//import SwiftUI
//
//struct DetailRow<Content: View>: View {
//    
//    var name: String
//    var subtitle: String? = nil
//    var image: String? = nil
//    var color: Color
//    
//    var destination: () -> Content
//    
//    var body: some View {
//        VStack {
//            NavigationLink(destination: destination) {
//                HStack {
//                    if let image {
//                        if let image = UIImage(named: image) {
//                            Image(uiImage: image)
//                                .resizable()
//                                .frame(width: 35, height: 35)
//                                .padding(.horizontal, 2.5)
//                        } else {
//                            Circle()
//                                .fill(Color.init(white: 0.8).opacity(0.5))
//                                .frame(width: 25, height: 25)
//                                .padding(.horizontal, 7.5)
//                        }
//                    }
//                    VStack(alignment: .leading) {
//                        Text(name)
//                            .font(.system(.title2, design: .rounded, weight: .semibold))
//                            .foregroundColor(.white)
//                            .lineLimit(0)
//                        DetailText(name, subtitle)
//                            .font(.system(.caption, design: .rounded, weight: .semibold))
//                            .lineLimit(0)
//                            .foregroundColor(.gray)
//                    }
//                    Spacer()
//                    Image(systemName: "chevron.forward")
//                        .font(.system(.body, design: .rounded, weight: .semibold))
//                        .foregroundColor(.white)
//                }
//            }
//            .padding(.leading, -3)
//        }
//        .padding()
//        .background(color.cornerRadius(15))
//    }
//}
//
//
