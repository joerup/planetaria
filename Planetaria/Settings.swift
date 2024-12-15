//
//  Settings.swift
//  Planetaria
//
//  Created by Joe Rupertus on 5/25/23.
//

import SwiftUI
import PlanetariaData

struct Settings: View {
    
    @EnvironmentObject var simulation: Simulation
    
    @Environment(\.dismiss) var dismiss
    
    #if os(iOS) || os(macOS)
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    #endif
    
    @State private var presentShare: Bool = false
    @State private var presentAcknowledgements: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Show Orbits", isOn: $simulation.showOrbits)
                    Toggle("Show Labels", isOn: $simulation.showLabels)
                }
                
                if #available(iOS 18.0, macOS 15.0, visionOS 2.0, *) {
                    Section {
                        Toggle("Flood Lights", isOn: $simulation.showFloodLights)
                    }
                }
                
                Section {
                    Button {
                        self.presentAcknowledgements.toggle()
                    } label: {
                        row("Acknowledgements")
                    }
                }
                
                Section {
                    Link(destination: URL(string: "https://www.joerup.com/planetaria")!) {
                        row("Website")
                    }
                    Link(destination: URL(string: "https://www.joerup.com/planetaria/support")!) {
                        row("Support")
                    }
                    Link(destination: URL(string: "https://www.joerup.com/planetaria/privacy")!) {
                        row("Privacy Policy")
                    }
                }
                
                #if os(iOS) || os(tvOS)
                Section {
                    Button {
                        guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id1546887479?action=write-review")
                            else { fatalError("Expected a valid URL") }
                        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
                    } label: {
                        row("Rate the App")
                    }
                    Button {
                        self.presentShare.toggle()
                    } label: {
                        row("Share the App")
                    }
                }
                #endif
                
                #if os(iOS) || os(macOS)
                Section {} header: {
                    VStack {
                        Text("Planetaria")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.mint)
                        Text("Version \(appVersion ?? "")")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .textCase(nil)
                }
                #endif
            }
            .tint(.mint)
            .fontDesign(.rounded)
            .navigationTitle("Settings")
            #if os(iOS) || os(tvOS) || os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .fontWeight(.semibold)
                            .foregroundStyle(.mint)
                    }
                }
            }
            #endif
        }
        .sheet(isPresented: $presentAcknowledgements) {
            Acknowledgements()
        }
        #if os(iOS) || os(tvOS)
        .sheet(isPresented: self.$presentShare, content: {
            ActivityViewController(activityItems: [URL(string: "https://apps.apple.com/us/app/planetaria/id1546887479")!])
        })
        #endif
    }
    
    private func row(_ text: String) -> some View {
        NavigationLink(destination: EmptyView()) {
            HStack {
                Text(text)
                    .foregroundStyle(.mint)
                Spacer()
            }
        }
    }
}

#if os(iOS) || os(tvOS) || os(visionOS)
struct ActivityViewController: UIViewControllerRepresentable {

    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}

}
#endif
