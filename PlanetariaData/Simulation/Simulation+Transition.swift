//
//  Simulation+Transition.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 12/9/24.
//

import Foundation
import SwiftUI

extension Simulation {
    
    // MARK: - Public Transition API
    
    // Set the camera to a specific state
    public func setCamera(
        toSize size: Double,
        byScale scale: Double = 1.0,
        toDirection axis: Vector3? = nil,
        withRotation rotation: Angle = .zero,
        withPitch pitch: Angle = .zero,
        toFocus focus: Node? = nil
    ) async {
        await MainActor.run {
            let (axisRotation, axisPitch) = convertDirection(axis)
            self.steadyScale = (self.size / size) * scale
            self.steadyRotation = (axisRotation ?? self.steadyRotation) + rotation
            self.steadyPitch = (axisPitch ?? self.steadyPitch) + pitch
            self.focus = focus ?? self.focus
        }
    }

    // Transition the camera to a specific state
    public func transitionCamera(
        toSize size: Double? = nil,
        byScale scale: Double = 1.0,
        toDirection axis: Vector3? = nil,
        withRotation rotation: Angle = .zero,
        withPitch pitch: Angle = .zero,
        toFocus focus: Node? = nil,
        easingType: EasingType = .cubicInOut,
        duration: Double
    ) async {
        await MainActor.run {
            let (axisRotation, axisPitch) = convertDirection(axis)
            transition(
                focus: focus ?? self.focus,
                size: (size ?? (self.size / self.scale)) / scale,
                rotation: (axisRotation ?? steadyRotation) + rotation,
                pitch: (axisPitch ?? steadyPitch) + pitch,
                easingType: easingType,
                duration: duration
            )
        }
        while let transition = self.transition, !transition.isComplete {
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
    }
    
    // Adjust the timestamp and speed of the simulation
    public func adjustTiming(timestamp: Date? = nil, speed: Double? = nil) async {
        await MainActor.run {
            if let timestamp {
                setTime(timestamp)
            }
            if let speed {
                setSpeed(speed)
            }
        }
    }
    
    // Reset the timestamp and speed of the simulation
    public func resetTiming() async {
        await adjustTiming(timestamp: .now, speed: 1.0)
    }
    
    
    // MARK: - Internal Transition Methods
    
    // Zoom to a node's surface
    func zoomToSurface(node: Node) {
        print("zooming to surface of \(node.name)")
        let node = node.object ?? node
        transition(focus: node, size: zoomObjectCoefficient * (viewType == .immersive ? node.size : node.totalSize), duration: animationTime)
    }
    
    // Zoom to a node's orbital path
    func zoomToOrbit(node: Node) {
        print("zooming to orbit of \(node.name)")
        let node = node.system ?? node
        let ratio = zoomOrbitCoefficient * scale * (node.position.magnitude + node.totalSize) / size
        let fraction = max(0.7, min(1.0, ratio))
        transition(focus: node.parent, size: zoomOrbitCoefficient / fraction * (node.position.magnitude + node.totalSize), duration: animationTime)
    }
    
    // Zoom to a node's local system
    func zoomToSystem(node: Node) {
        print("zooming to system of \(node.name)")
        let node = node.object ?? node
        let distance = node.system?.primaryScaleDistance ?? .infinity
        transition(focus: node.parent, size: zoomOrbitCoefficient * distance, duration: animationTime)
    }
    
    // General method to perform a transition
    func transition(focus: Node?, size: Double, rotation: Angle? = nil, pitch: Angle? = nil, easingType: EasingType = .cubicInOut, duration: Double) {
        let scale = self.size / size
        guard let focus, scale.isFinite else { return }
        let system = focus.system
        
        let originalScale = self.scale
        let originalFocus = self.focus
        let originalRotation = self.rotation
        let originalPitch = self.pitch
        
        let rotation = rotation ?? self.rotation
        let pitch = pitch ?? self.pitch
        
        // Set the focus and system nodes
        setFocus(focus)
        if let system {
            setSystem(system)
        }
        
        // Transition the entities
        let frames = Int(duration * frameRate)
        self.transition = Transition(easingType: easingType, frames: frames, originalScale: originalScale, originalRotation: originalRotation, originalPitch: originalPitch, originalFocus: originalFocus, originalOffsetAmount: offsetAmount, targetScale: scale, targetRotation: rotation, targetPitch: pitch, targetFocus: focus)
        
        // Update the saved offset and scale
        self.offsetAmount = 1.0
    }
    
    // Transition object
    // Stores all data needed for a transition in progress
    class Transition: Hashable {
        
        private let id = UUID()
        private let totalFrames: Int
        private var completedFrames: Int = 0
        private var easingType: EasingType
        
        private(set) var originalScale: Double
        private(set) var originalFocus: Node?
        private(set) var originalOffsetAmount: Double
        private(set) var originalRotation: Angle
        private(set) var originalPitch: Angle
        private(set) var targetScale: Double
        private(set) var targetFocus: Node?
        private(set) var targetRotation: Angle
        private(set) var targetPitch: Angle
        
        var scale: Double = 1.0
        var offset: Vector3 = .zero
        var rotation: Angle = .zero
        var pitch: Angle = .zero
        
        var isComplete: Bool {
            completedFrames == totalFrames
        }
        
        init(easingType: EasingType,
             frames: Int,
             originalScale: Double,
             originalRotation: Angle,
             originalPitch: Angle,
             originalFocus: Node?,
             originalOffsetAmount: Double = 1.0,
             targetScale: Double,
             targetRotation: Angle,
             targetPitch: Angle,
             targetFocus: Node?
        ) {
            self.easingType = easingType
            self.totalFrames = frames
            self.originalScale = originalScale
            self.originalRotation = originalRotation
            self.originalPitch = originalPitch
            self.originalFocus = originalFocus
            self.originalOffsetAmount = originalOffsetAmount
            self.targetScale = targetScale
            self.targetRotation = targetRotation
            self.targetPitch = targetPitch
            self.targetFocus = targetFocus
        }
        
        func nextFrame() {
            let t = Double(completedFrames) / Double(totalFrames)
            let k = easingType.f(t)
            
            scale = exp(log(originalScale) * (1 - k) + log(targetScale) * k)
            
            let r = targetScale / originalScale
            let w = r == 1 ? k : (pow(r, k) - 1) / (r - 1)
            
            let originalOffset = originalFocus?.globalPositionAtFraction(originalOffsetAmount) ?? .zero
            let targetOffset = targetFocus?.globalPosition ?? .zero
            
            offset = originalOffset * (originalScale / scale) * (1 - w) + targetOffset * (targetScale / scale) * w
            
            rotation = originalRotation * (1 - k) + targetRotation * k
            pitch = originalPitch * (1 - k) + targetPitch * k
            
            completedFrames += 1
        }
        
        static func == (lhs: Transition, rhs: Transition) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    // Easing type for transition
    public enum EasingType {
        case cubicIn
        case cubicOut
        case cubicInOut
        case quadraticIn
        case quadraticOut
        case quadraticInOut
        case linear

        func f(_ t: Double) -> Double {
            switch self {
            case .cubicIn:
                return pow(t, 3)
            case .cubicOut:
                return 1 - pow(1 - t, 3)
            case .cubicInOut:
                return t < 0.5 ? (4 * pow(t, 3)) : (1 - pow(-2 * t + 2, 3) / 2)
            case .quadraticIn:
                return pow(t, 2)
            case .quadraticOut:
                return 1 - pow(1 - t, 2)
            case .quadraticInOut:
                return t < 0.5 ? (2 * pow(t, 2)) : (1 - pow(-2 * t + 2, 2) / 2)
            case .linear:
                return t
            }
        }
    }

    // Convert direction to rotation and pitch
    private func convertDirection(_ axis: Vector3?) -> (Angle?, Angle?) {
        guard let axis else { return (nil, nil) }
        
        #if os(visionOS)
        let pitchOffset: CGFloat = -.pi/2
        #else
        let pitchOffset: CGFloat = -.pi/2
        #endif
        
        let axisRotation = Angle(radians: -atan2(-axis.x, -axis.y))
        
        let transformedX = axis.x * cos(rotation.radians) + axis.y * sin(rotation.radians)
        let transformedY = axis.y * cos(rotation.radians) - axis.x * sin(rotation.radians)
        let transformedZ = axis.z
        
        let axisPitch = Angle(radians: pitchOffset - atan2(-transformedZ, sqrt(transformedX * transformedX + transformedY * transformedY)))
        
        return (axisRotation, axisPitch)
    }
}
