//
//  Simulation+Gestures.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 12/9/24.
//

import Foundation
import SwiftUI

extension Simulation {
    
    // MARK: - Public Gesture API
    
    // Scale
    
    public func updateScaleGesture(to value: CGFloat) {
        guard zoomEnabled else { return }
        
        self.gestureScale = value
        
        if let focus, 1.1 * scale * focus.size > size {
            self.gestureScale *= size / (1.1 * scale * focus.size)
        }
        updateAfterGesture()
    }
    
    public func completeScaleGesture(to value: CGFloat) {
        guard zoomEnabled else { return }
        
        self.steadyScale *= value
        self.gestureScale = 1.0
        
        if let focus, 1.1 * scale * focus.size > size {
            self.steadyScale *= size / (1.1 * scale * focus.size)
        }
        updateAfterGesture()
    }
    
    // Rotation
    
    public func updateRotationGesture(with angle: Angle) {
        guard rotateEnabled else { return }
        
        self.gestureRotation = angle
        
        updateAfterGesture()
    }
    
    public func completeRotationGesture(with angle: Angle) {
        guard rotateEnabled else { return }
        
        self.steadyRotation += angle
        self.gestureRotation = .zero
        
        updateAfterGesture()
    }
    
    public func resetRotation() {
        self.steadyRotation = .zero
    }
    
    // Pitch
    
    public func updatePitchGesture(with angle: Angle) {
        guard rotateEnabled else { return }
        
        self.gesturePitch = angle
        
        if steadyPitch + gesturePitch > maxPitchAngle {
            gesturePitch = -steadyPitch + maxPitchAngle
        }
        if steadyPitch + gesturePitch < minPitchAngle {
            gesturePitch = -steadyPitch + minPitchAngle
        }
        updateAfterGesture()
    }
    
    public func completePitchGesture(with angle: Angle) {
        guard rotateEnabled else { return }
        
        self.steadyPitch += angle
        self.gesturePitch = .zero
        
        if steadyPitch > maxPitchAngle {
            steadyPitch = maxPitchAngle
        }
        if steadyPitch < minPitchAngle {
            steadyPitch = minPitchAngle
        }
        updateAfterGesture()
    }
    
    public func resetPitch() {
        self.steadyPitch = .zero
    }
    
    // Roll
    
    public func updateRollGesture(with angle: Angle) {
        guard rotateEnabled else { return }
        
        self.gestureRoll = angle
        
        if steadyRoll + gestureRoll > maxRollAngle {
            gestureRoll = -steadyRoll + maxRollAngle
        }
        if steadyRoll + gestureRoll < minRollAngle {
            gestureRoll = -steadyRoll + minRollAngle
        }
        updateAfterGesture()
    }
    
    public func completeRollGesture(with angle: Angle) {
        guard rotateEnabled else { return }
        
        self.steadyRoll += angle
        self.gestureRoll = .zero
        
        if steadyRoll > maxRollAngle {
            steadyRoll = maxRollAngle
        }
        if steadyRoll < minRollAngle {
            steadyRoll = minRollAngle
        }
        updateAfterGesture()
    }
    
    public func resetRoll() {
        self.steadyRoll = .zero
    }
    
    
    // MARK: - Internal Gesture Methods
    
    // Update Helper
    func updateAfterGesture() {
        guard let focus else { return }
        
        let orbitWeight: Double = 1.2
        let objectWeight: Double = 4.0
        
        // Set the offset amount: the percentage which the focus is offset toward the child node
        // e.g. with the Sun as the reference node but Earth selected, offsetAmount = 0.5 would place the central focus halfway between the Earth & Sun
        let objectSize = (object ?? focus.object)?.size ?? .zero
        let totalSize = scale * max(orbitWeight * focus.position.magnitude, objectWeight * 2 * objectSize)
        let zoomScale = totalSize / size
        
        // Set the offset amount based on a nonlinear parameterization of the zoom scale
        let t = min(1, max(0, (zoomScale*2 - 1)))
        offsetAmount = 1 - pow(1 - t, 4)
        
        // Focus to the child node if zoomed in enough (offset is beginning)
        if let object = object ?? focus.object, let focus = focus as? SystemNode, let childNode = focus.children.first(where: { $0.object == object }) {
            if scale * max(orbitWeight * childNode.position.magnitude, objectWeight * 2 * object.size) > 0.5 * size {
                setFocus(childNode)
                updateAfterGesture()
            }
        }
        // Focus to the parent node if zoomed out enough (offset is ending)
        if let parentNode = focus.parent, zoomScale < 0.5 {
            setFocus(parentNode)
            updateAfterGesture()
        }

        // Select the child system if zoomed in enough (the reference node/child system is a system that comprises more than 5% of the screen)
        if focus != system, let childSystem = focus as? SystemNode, scale * childSystem.scaleDistance > 0.05 * size || scale * childSystem.primaryScaleDistance > 0.01 * size {
            setSystem(childSystem)
        }
        // Select the parent system if zoomed out enough (the reference node/child system is a system that comprises less than 5% of the screen)
        if let system, let parentSystem = system.parent, scale * system.scaleDistance < 0.05 * size && scale * system.primaryScaleDistance < 0.01 * size {
            setSystem(parentSystem)
        }
    }
    
    // Angle Constraints
    
    private var minPitchAngle: Angle {
        switch viewType {
        case .fixed:
            return -.radians(.pi)
        case .augmented:
            return .zero
        case .immersive:
            return -.radians(.pi/2)
        }
    }
    
    private var maxPitchAngle: Angle {
        switch viewType {
        case .fixed:
            return .zero
        case .augmented:
            return .zero
        case .immersive:
            return .radians(.pi/2)
        }
    }
    
    private var minRollAngle: Angle {
        switch viewType {
        case .fixed, .immersive:
            return -.radians(.pi/2)
        case .augmented:
            return .zero
        }
    }
    
    private var maxRollAngle: Angle {
        switch viewType {
        case .fixed, .immersive:
            return .radians(.pi/2)
        case .augmented:
            return .zero
        }
    }
}
