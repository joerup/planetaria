//
//  SystemNode+SPICE.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 11/29/24.
//

import Foundation
import SwiftSPICE

extension Node {
    
    // All states always from the J2000 ecliptic reference frame
    private static let frame = "ECLIPJ2000"
    
    // Get the position and velocity at the given timestamp from SPICE
    internal func setStateFromSPICE(by dt: Double = 0, to time: Date, guaranteedUpdate: Bool = true) {
        guard let parent else { return }
        
        // If `guaranteedUpdate`, this node will definitely update
        // (This is the case when the state is initialized or the node is in view so we want smooth motion)
        // Otherwise, it will only update when its time step has elapsed, to save time
        
        // Once the timestep is reached, or if update is guaranteed, proceed
        self.spiceElapsedTime += dt
        guard guaranteedUpdate || spiceElapsedTime >= spiceStep else { return }
        spiceElapsedTime = 0
        
        // Get the current state of this node from SPICE
        if let state = SPICE.getState(target: self.id, reference: parent.id, time: time, frame: Self.frame) {
            self.position = [state.x, state.y, state.z]
            self.velocity = [state.vx, state.vy, state.vz]
        }
    }
}
