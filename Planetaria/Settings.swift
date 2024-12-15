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
    
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    @State private var presentShare: Bool = false
    @State private var presentAcknowledgements: Bool = false
    
    var body: some View {
        ScrollSheet(title: "Settings") {
            settingsList
        }
        .foregroundStyle(.white)
        .fontDesign(.rounded)
        .sheet(isPresented: $presentAcknowledgements) {
            Acknowledgements()
        }
        #if os(iOS) || os(tvOS)
        .sheet(isPresented: self.$presentShare, content: {
            ActivityViewController(activityItems: [URL(string: "https://apps.apple.com/us/app/planetaria/id1546887479")!])
        })
        #endif
    }
    
    private var settingsList: some View {
        ScrollView {
            VStack {
                item {
                    Toggle("Show Orbits", isOn: $simulation.showOrbits)
                }
                item {
                    Toggle("Show Labels", isOn: $simulation.showLabels)
                }
                
                if #available(iOS 18.0, macOS 15.0, visionOS 2.0, *) {
                    item {
                        Toggle("Flood Lights", isOn: $simulation.showFloodLights)
                    }
                }
                
                #if os(iOS) || os(tvOS)
                HStack {
                    Text("Links")
                        .foregroundStyle(.gray)
                    Spacer()
                }
                .padding([.top, .leading], 10)
                
                Link(destination: URL(string: "https://www.joerup.com/planetaria")!) {
                    item {
                        row("Website")
                    }
                }
                Link(destination: URL(string: "https://www.joerup.com/planetaria/support")!) {
                    item {
                        row("Support")
                    }
                }
                Link(destination: URL(string: "https://www.joerup.com/planetaria/privacy")!) {
                    item {
                        row("Privacy Policy")
                    }
                }
                
                Button {
                    guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id1546887479?action=write-review")
                    else { fatalError("Expected a valid URL") }
                    UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
                } label: {
                    item {
                        row("Rate the App")
                    }
                }
                
                Button {
                    self.presentShare.toggle()
                } label: {
                    item {
                        row("Share the App")
                    }
                }
                
                Button {
                    self.presentAcknowledgements.toggle()
                } label: {
                    item {
                        row("Acknowledgements")
                            #if os(visionOS)
                            .padding(.vertical, 5)
                            #endif
                    }
                }
                .buttonStyle(.plain)
                #endif
                
                Text("Version \(appVersion ?? "")")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .textCase(nil)
                    .padding(.top)
                    .padding(.bottom, 8)
            }
            .padding(.vertical)
        }
        .tint(.mint)
        .fontDesign(.rounded)
    }
    
    private func item<Content: View>(_ content: @escaping () -> Content) -> some View {
        content()
            .padding()
            .background(.thinMaterial)
            #if os(visionOS)
            .clipShape(RoundedRectangle(cornerRadius: 50))
            #else
            .clipShape(RoundedRectangle(cornerRadius: 15))
            #endif
    }
    
    private func row(_ text: String) -> some View {
        HStack {
            Text(text)
                .foregroundStyle(.mint)
            Spacer()
            Image(systemName: "chevron.forward")
                .imageScale(.small)
                .foregroundStyle(.gray)
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
