////
////  OrbitDrawing.swift
////  Planetaria
////
////  Created by Joe Rupertus on 5/22/23.
////
//
//import SwiftUI
//
//struct OrbitDrawing: View {
//    
//    var object: Object
//    
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                let a = geometry.size.width/2
//                let e = object.eccentricity?.value ?? 0.0
//                let angle = Angle.radians(-object.trueAnomaly)
//                let minorScale = sqrt(1 - pow(e, 2))
//                let r = a * CGFloat(pow(minorScale, 2) / (1 + e * cos(angle.radians)))
//                let rect = CGRect(x: 0, y: 0, width: geometry.size.width, height: geometry.size.width * minorScale)
//                let centerX = a * (1 + CGFloat(e))
//                let centerY = a
//                let positionX = centerX + r * cos(angle.radians)
//                let positionY = centerY + r * sin(angle.radians)
//                VStack {
//                    Spacer(minLength: 0)
//                    Path { path in
//                        path.addEllipse(in: rect)
//                    }
//                    .stroke(AngularGradient(colors: [object.associatedColor.opacity(0.5), .clear], center: UnitPoint(x: 0.5 + e / 2, y: 0.5), startAngle: angle + .degrees(10), endAngle: angle + .degrees(353)), style: StrokeStyle(lineWidth: 15))
//                    .frame(width: geometry.size.width, height: geometry.size.width * minorScale)
//                    Spacer(minLength: 0)
//                }
//                Circle()
//                    .fill(Color.white.opacity(0.1))
//                    .shadow(radius: 5)
//                    .frame(width: 15, height: 15)
//                    .position(x: centerX, y: centerY)
//                Circle()
//                    .fill(object.associatedColor)
//                    .shadow(radius: 5)
//                    .frame(width: 15, height: 15)
//                    .position(x: positionX, y: positionY)
//            }
//        }
//        .aspectRatio(1.0, contentMode: .fit)
//    }
//}
//
//struct RotationDrawing: View {
//    
//    var object: Object
//    
//    var body: some View {
//        GeometryReader { geometry in
//            let flattening = object.flattening?.value ?? 0
//            let axialTilt = object.axialTilt?[.deg] as Double?
//            HStack {
//                Spacer()
//                ZStack {
//                    if axialTilt != nil {
//                        VStack(spacing: 0) {
//                            Circle()
//                                .fill(.white.opacity(0.8))
//                                .frame(width: 8, height: 8)
//                            Rectangle()
//                                .fill(.gray.opacity(0.8))
//                                .frame(width: 4, height: geometry.size.width-8)
//                        }
//                    }
//                    Circle()
//                        .fill(object.associatedColor.opacity(0.5))
//                        .frame(width: geometry.size.width * 0.75, height: geometry.size.width * 0.75 * (1 - flattening))
//                }
//                .rotationEffect(.degrees(axialTilt ?? 0))
//                Spacer()
//            }
//        }
//        .aspectRatio(1.0, contentMode: .fit)
//    }
//}
