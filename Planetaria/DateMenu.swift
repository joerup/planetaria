//
//  DateMenu.swift
//  Planetaria
//
//  Created by Joe Rupertus on 12/2/24.
//

import SwiftUI
import PlanetariaData

struct DateMenu: View {
    
    @EnvironmentObject var simulation: Simulation
    @Environment(\.dismiss) var dismiss

    @State private var setToNow: Bool = true
    @State private var selectedTime: Date = .now
    
    var showTimeHeader: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ControlButton(icon: "arrow.counterclockwise") {
                    setToNow = true
                    selectedTime = .now
                    simulation.resetTime()
                }
                .padding(8)
                Spacer(minLength: 0)
                Text("Set Time")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                Spacer(minLength: 0)
                ControlButton(icon: "xmark") {
                    dismiss()
                }
                .padding(8)
            }
            VStack {
                if showTimeHeader {
                    Text(simulation.time.string)
                        .lineLimit(0)
                        .textCase(nil)
                        .font(.system(.headline, design: .monospaced, weight: .bold))
                        .minimumScaleFactor(0.5)
                        .foregroundColor(simulation.isRealTime ? .white : .mint)
                        .dynamicTypeSize(..<DynamicTypeSize.accessibility2)
                        .accessibilityLabel(simulation.time.string)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                }
                DatePicker("Set Time", selection: $selectedTime, in: simulation.minTime...simulation.maxTime)
                    .datePickerStyle(.graphical)
                    .tint(.mint)
                    .onChange(of: selectedTime) { time in
                        if !setToNow {
                            simulation.setTime(time)
                        }
                        setToNow = false
                    }
                Spacer(minLength: 0)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .foregroundStyle(.white)
        .onAppear {
            selectedTime = simulation.time
        }
    }
}
