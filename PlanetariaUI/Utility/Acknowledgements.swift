//
//  Acknowledgements.swift
//  Planetaria
//
//  Created by Joe Rupertus on 1/28/23.
//

import SwiftUI

public struct Acknowledgements: View {
    
    @Environment(\.dismiss) var dismiss
    
    let string = """
    Planetaria uses a variety of sources to access data needed to provide an accurate Solar System simulation.
    
    The current positions and velocities of objects, used to calculate their orbits, are obtained in real-time from the [NASA Horizons System](https://ssd.jpl.nasa.gov/horizons/). Rotational orientations are calculated based on the [Report of the IAU Working Group on Cartographic Coordinates and Rotational Elements: 2009](https://link.springer.com/article/10.1007/s10569-010-9320-4). Orbital and rotational properties are calculated based on these values in real-time.
    
    Data about objects' physical characteristics (mass, size, temperature, etc.) are sourced from [NASA Planetary Fact Sheets](https://nssdc.gsfc.nasa.gov/planetary/planetfact.html), along with the [IAU Minor Planet Center](https://www.minorplanetcenter.net/), and [Scott S. Sheppard](https://sites.google.com/carnegiescience.edu/sheppard/home?authuser=0).
    
    3D models of Solar System objects are provided by [NASA Solar System Resources](https://solarsystem.nasa.gov/resources/all/?order=pub_date+desc&per_page=50&page=0&search=&condition_1=1%3Ais_in_resource_list&fs=&fc=&ft=&dp=&category=).
    
    The above sources are not affiliated with Planetaria and they do not endorse it.
    """
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    VStack(alignment: .leading) {
                        Text(.init(string))
                            .font(.system(.callout, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 2)
                    }
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Acknowledgements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .tint(.blue)
    }
}

public struct Footnote: View {
    
    @State private var showAcknowledgements: Bool = false
    
    public var body: some View {
        Text("Acknowledgements")
            .font(.system(.footnote, design: .rounded, weight: .semibold))
            .foregroundColor(.init(white: 0.4))
            .underline()
            .padding(.vertical, 5)
            .onTapGesture {
                showAcknowledgements.toggle()
            }
            .sheet(isPresented: $showAcknowledgements) {
                Acknowledgements()
            }
    }
}