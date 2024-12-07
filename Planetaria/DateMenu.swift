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
                resetButton
                Spacer(minLength: 0)
                Text("Set Time")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                Spacer(minLength: 0)
                closeButton
            }
            #if os(visionOS)
            .padding()
            #else
            .padding(8)
            #endif
            ScrollView {
                VStack {
                    if showTimeHeader {
                        timeHeader
                    }
                    datePicker
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .foregroundStyle(.white)
        .onAppear {
            selectedTime = simulation.time
        }
    }
    
    private var datePicker: some View {
        DatePicker("Set Time", selection: $selectedTime, in: simulation.minTime...simulation.maxTime)
            .datePickerStyle(.graphical)
            .tint(.mint)
            .onChange(of: selectedTime) { time in
                if !setToNow {
                    simulation.setTime(time)
                }
                setToNow = false
            }
    }
    
    private var timeHeader: some View {
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
    
    private var resetButton: some View {
        ControlButton(icon: "arrow.counterclockwise") {
            setToNow = true
            selectedTime = .now
            simulation.resetTime()
        }
    }
    
    private var closeButton: some View {
        ControlButton(icon: "xmark") {
            dismiss()
        }
    }
}
