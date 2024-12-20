//
//  Acknowledgements.swift
//  Planetaria
//
//  Created by Joe Rupertus on 1/28/23.
//

import SwiftUI

struct Acknowledgements: View {
    
    @Environment(\.dismiss) var dismiss
    
    let string = """
    Planetaria uses a variety of sources to access data needed to provide an accurate Solar System simulation.
    
    The positions and velocities of objects for the orbit simulation are obtained from the [SPICE Toolkit](https://naif.jpl.nasa.gov/naif/) provided by NASA's Navigation and Ancillary Information Facility (NAIF).
    
    Rotational orientations are calculated based on the [Report of the IAU Working Group on Cartographic Coordinates and Rotational Elements](https://link.springer.com/article/10.1007/s10569-017-9805-5).
    
    Properties of objects (mass, size, period, etc.) are compiled from the following sources: [NASA JPL Solar System Dynamics](https://ssd.jpl.nasa.gov/), [NASA Planetary Fact Sheets](https://nssdc.gsfc.nasa.gov/planetary/planetfact.html), [IAU Minor Planet Center](https://www.minorplanetcenter.net/), and [Scott S. Sheppard](https://sites.google.com/carnegiescience.edu/sheppard/home?authuser=0).
    
    3D models are provided by [NASA Solar System Resources](https://solarsystem.nasa.gov/resources/all/?order=pub_date+desc&per_page=50&page=0&search=&condition_1=1%3Ais_in_resource_list&fs=&fc=&ft=&dp=&category=).
    
    The above sources are not affiliated with Planetaria and they do not endorse it.
    """
    
//    Images are provided by [NASA Image and Video Library](https://images.nasa.gov/). Each individual image contains a link to its respective source.
    
    var body: some View {
        ScrollSheet(title: "Acknowledgements") {
            VStack(alignment: .leading) {
                Text(.init(string))
                    .font(.callout)
                    .foregroundColor(.white)
                    .padding(.horizontal, 2)
                    .dynamicTypeSize(..<DynamicTypeSize.accessibility2)
                    .tint(.mint)
            }
            .padding(.vertical)
        }
    }
}

struct Footnote: View {
    
    @State private var showAcknowledgements: Bool = false
    
    init() { }
    
    var body: some View {
        Text("Acknowledgements")
            .font(.system(.footnote, weight: .semibold))
            .foregroundStyle(.secondary)
            .underline()
            .padding(.vertical, 5)
            .onTapGesture {
                showAcknowledgements.toggle()
            }
            .sheet(isPresented: $showAcknowledgements) {
                Acknowledgements()
                    .tint(nil)
            }
    }
}
