//
//  Spacetime.swift
//  Planetaria
//
//  Created by Joe Rupertus on 1/13/23.
//

import Foundation
import SwiftUI

public final class Spacetime: ObservableObject {
    
    @Published public var root: Node?
    
    @Published public var reference: Node?
    @Published public var system: SystemNode?
    @Published public var object: ObjectNode?
    
    @Published public var focusTrigger: Bool?
    @Published public var backTrigger: Bool?
    
    @Published public var timeRatio: SimulationSpeed = .realtime
    @Published public var currentDate: Date = .now
     
    @Published public var readyForTakeoff: Bool = false
    
    // MARK: - App Setup
    public init() {
        Task {
            
            // Create the objects from the local static data
            await createNodes()
            
            // Start the simulation
//            await MainActor.run {
//                runSimulation()
//            }
            
            // Load the major ephemerides
            await root?.loadEphemerides(major: true)
            
            // Ready for takeoff
            await MainActor.run {
                withAnimation {
                    readyForTakeoff = true
                }
            }
            
            // Load the minor ephemerides
            await root?.loadEphemerides(major: false)
        }
    }
    
    // Create the nodes
    private func createNodes() async {
        
        guard let file = Bundle.module.path(forResource: "Planetaria", ofType: "json") else { return }
        
        var nodes: [SystemNode] = []
        
        if let json = try? String(contentsOfFile: file), let jsonData = json.data(using: .utf8) {
            do {
                nodes = try JSONDecoder().decode([SystemNode].self, from: jsonData)
            } catch {
                print(error)
            }
        }
        
        nodes.forEach { $0.printTree() }
        
        if let node = nodes.first {
            await MainActor.run {
                self.root = node
                self.reference = node
                self.system = node
                self.reference = node
                Node.earth = node.children.first(where: { $0.name == "Earth" })
            }
        }
    }
    
    // Run the simulation
    private func runSimulation() {
        let timeStep: Double = 1/30
        Timer.scheduledTimer(withTimeInterval: timeStep, repeats: true) { _ in
            
            // Calculate the virtual time step dt
            let dt = timeStep * self.timeRatio.rawValue
            
            // Simulate each virtual time step dt over each real time step
            self.currentDate.addTimeInterval(dt)
            self.system?.simulate(dt: dt)
        }
    }
}
