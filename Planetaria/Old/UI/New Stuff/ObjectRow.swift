////
////  ObjectRow.swift
////  Planetaria
////
////  Created by Joe Rupertus on 5/20/23.
////
//
//import SwiftUI
//
//struct ObjectRow: View {
//
//    @EnvironmentObject var spacetime: Spacetime
//
//    var object: ObjectNode
//
//    var body: some View {
//        Button {
//            withAnimation {
////                spacetime.selectedObject = object
//            }
//        } label: {
//            HStack {
//                visual(size: 45)
//                    .disabled(true)
//                    .padding(.leading, 5)
//                    .padding(.trailing, 10)
//                VStack(alignment: .leading) {
//                    Text(object.name)
//                        .font(.system(.title2, design: .rounded, weight: .semibold))
//                        .foregroundColor(.white)
//                    DetailText(object.name, object.subtitle)
//                        .font(.system(.subheadline, design: .rounded, weight: .medium))
//                        .multilineTextAlignment(.leading)
//                        .foregroundColor(.init(white: 0.8))
//                }
//                Spacer()
//                Image(systemName: "arrow.forward")
//                    .font(.system(.title3, design: .rounded))
//                    .dynamicTypeSize(.medium)
//                    .foregroundColor(.init(white: 0.6))
//                    .padding(.trailing, 5)
//            }
//            .padding()
//            .background(object.associatedColor.opacity(0.05).cornerRadius(15))
//        }
//    }
//
//    @ViewBuilder
//    private func visual(size: CGFloat) -> some View {
//        Object3DView(object)
//            .frame(width: size, height: size)
//    }
//}
