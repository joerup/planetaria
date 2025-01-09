//
//  Node+State.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 11/29/24.
//

import Foundation
import SwiftSPICE

extension Node {
    
    // All states always from the J2000 ecliptic reference frame
    private static let frame: SPICE.ReferenceFrame = .eclipticJ2000
    
    // Get the position and velocity at the given timestamp from SPICE
    internal func setState(to time: Date, guaranteedUpdate: Bool = true) {
        guard let parent else { return }
        
        // If `guaranteedUpdate`, this node will definitely update
        // (This is the case when the state is initialized or the node is in view so we want smooth motion)
        // Otherwise, it will only update when its time step has elapsed, to save time
        
        // Once the timestep is reached, or if update is guaranteed, proceed
        let timestamp = time.timeIntervalSince1970
        guard guaranteedUpdate || abs(lastUpdateTimestamp - timestamp) >= updateStep else { return }
        lastUpdateTimestamp = timestamp
        updateStep = velocity.magnitude == 0 ? 0 : Node.stepFraction * position.magnitude / velocity.magnitude
        
        // Get the current state of this node from SPICE
        if let (state, _) = try? SPICE.getState(target: self.id, reference: parent.id, time: time, frame: Self.frame) {
            position = [state.x, state.y, state.z]
            velocity = [state.vx, state.vy, state.vz]
            isOrbitSuspended = false
            isOutOfTimeRange = false
        } else {
            isOrbitSuspended = true
            isOutOfTimeRange = true
        }
    }
}
