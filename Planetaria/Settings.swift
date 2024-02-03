//
//  Settings.swift
//  Planetaria
//
//  Created by Joe Rupertus on 5/25/23.
//

import SwiftUI
import PlanetariaData

#if os(iOS) || os(tvOS) || os(visionOS)
struct Settings: View {
    
    @EnvironmentObject var simulation: Simulation
    
    @Environment(\.dismiss) var dismiss
    
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    @State private var presentShare: Bool = false
    @State private var presentAcknowledgements: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Show Orbits", isOn: $simulation.showOrbits)
                    Toggle("Show Labels", isOn: $simulation.showLabels)
                }
                
                Section {
                    Button {
                        self.presentAcknowledgements.toggle()
                    } label: {
                        row("Acknowledgements")
                    }
                    .sheet(isPresented: $presentAcknowledgements) {
                        Acknowledgements()
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
                    .sheet(isPresented: self.$presentShare, content: {
                        ActivityViewController(activityItems: [URL(string: "https://apps.apple.com/us/app/planetaria/id1546887479")!])
                    })
                }
                
                Section {} header: {
                    VStack {
                        Text("Planetaria")
                            .font(.title3)
                            .fontDesign(.rounded)
                            .fontWeight(.bold)
                            .foregroundColor(.mint)
                        Text("Version \(appVersion ?? "")")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .textCase(nil)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .tint(.mint)
    }
    
    private func row(_ text: String) -> some View {
        NavigationLink(destination: EmptyView()) {
            HStack {
                Text(text)
                Spacer()
            }
        }
    }
}

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
