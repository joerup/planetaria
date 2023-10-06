//
//  Header.swift
//  
//
//  Created by Joe Rupertus on 8/15/23.
//

import SwiftUI
import PlanetariaData

public struct Header: View {
    
    @EnvironmentObject var spacetime: Spacetime
    
    public init() { }
    
    public var body: some View {
        
        HStack(alignment: .top) {
            
//            Button {
//                withAnimation {
//
//                }
//            } label: {
//                Image(systemName: "gearshape.fill")
//                    .bold()
//                    .foregroundColor(.white)
//                    .padding()
//            }
            
            Spacer()
            
            VStack {
                Text(spacetime.currentDate.string)
                    .foregroundColor(.white)
                    .font(.system(.body, design: .monospaced, weight: .bold))
                    .padding(.top)
                
//                HStack {
//                    Button {
//                        if let prev = spacetime.timeRatio.prev {
//                            spacetime.timeRatio = prev
//                        }
//                    } label: {
//                        Image(systemName: "backward\(spacetime.timeRatio.rawValue < 0 ? ".fill" : "")")
//                    }
//                    Button {
//                        if spacetime.timeRatio == .stationary {
//                            spacetime.timeRatio = .realtime
//                        } else {
//                            spacetime.timeRatio = .stationary
//                        }
//                    } label: {
//                        Image(systemName: spacetime.timeRatio == .stationary ? "play" : "pause")
//                            .fontWeight(.bold)
//                            .padding(5)
//                    }
//    //                                Text(spacetime.timeRatio.text)
//    //                                    .font(.system(.title, design: .monospaced, weight: .bold))
//    //                                    .padding(5)
//                    Button {
//                        if let next = spacetime.timeRatio.next {
//                            spacetime.timeRatio = next
//                        }
//                    } label: {
//                        Image(systemName: "forward\(spacetime.timeRatio.rawValue > 0 ? ".fill" : "")")
//                    }
//                }
            }
            
            Spacer()
            
//            Button {
//
//            } label: {
//                Image(systemName: "magnifyingglass")
//                    .bold()
//                    .foregroundColor(.white)
//                    .padding()
//            }
        }
    }
}
