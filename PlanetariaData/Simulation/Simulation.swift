//
//  Simulation.swift
//
//
//  Created by Joe Rupertus on 11/7/23.
//

import Foundation
import SwiftUI

final public class Simulation: ObservableObject {
    
    // MARK: - Status
    
    @Published private var active: Bool = false
    
    public init(root: Node? = nil, reference: Node? = nil, system: SystemNode? = nil, object: ObjectNode? = nil) {
        self.root = root
        self.reference = reference
        self.system = system
        self.object = object
    }
    public func setContents(root: Node? = nil, reference: Node? = nil, system: SystemNode? = nil, object: ObjectNode? = nil) {
        self.root = root
        self.reference = reference
        self.system = system
        self.object = object
    }
    public func start() {
        guard let root else { print("Failed to start simulation"); return }
        nodes = [root] + root.relatedNodes
        active = true
    }
    public func stop() {
        active = false
    }
    public var isActive: Bool {
        return active
    }
    
    
    // MARK: - Contents
    
    @Published private var root: Node?
    @Published private var reference: Node?
    @Published private var system: SystemNode?
    @Published private var object: ObjectNode?
    
    @Published private var nodes: [Node] = []
    
    public var allNodes: [Node] {
        guard let system else { return [] }
        return nodes.filter { system.contains($0) }
    }
    
    public var selectedSystem: SystemNode? {
        return system
    }
    public var selectedObject: ObjectNode? {
        return object
    }
    public func isSelected(_ node: Node) -> Bool {
        return node.object == object
    }
    public var noSelection: Bool {
        return object == nil
    }
    public var isReferenceSystem: Bool {
        return system != nil && reference == system // change this eventually
    }
    

    // MARK: - Positioning
    
    public var defaultScaleRatio: Double = 1E+7
    
    public var totalScale: Double {
        scale / defaultScaleRatio
    }
    
    // Offset
    @Published private var offsetAmount: Double = 1.0
    public var offset: Vector {
        guard let reference else { return .zero }
        return (reference.parent?.globalPosition ?? .zero) + reference.position * offsetAmount
    }
    
    // Scale
    @Published private var steadyScale: CGFloat = 1.0
    @Published private var gestureScale: CGFloat = 1.0
    public var scale: CGFloat {
        steadyScale * gestureScale
    }
    
    // Rotation
    @Published private var steadyRotation: Angle = .zero
    @Published private var gestureRotation: Angle = .zero
    public var rotation: Angle {
        steadyRotation + gestureRotation
    }
    
    // Pitch
    @Published private var steadyPitch: Angle = .zero
    @Published private var gesturePitch: Angle = .zero
    public var pitch: Angle {
        steadyPitch + gesturePitch
    }
    
    public var grayscale: Double = 0
    public var introScale: Double = 1E-3
    
    
    // MARK: - Gestures
    
    public func zoomGesture(size: CGSize) -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                self.gestureScale = value
                self.updateView(size: size)
                
                if let reference = self.reference, 2.2 * self.applyScale(reference.size) > min(size.width, size.height) {
                    self.gestureScale *= min(size.width, size.height) / (2.2 * self.applyScale(reference.size))
                }
            }
            .onEnded { value in
                self.steadyScale *= value
                self.gestureScale = 1.0
                self.updateView(size: size)
                
                if let reference = self.reference, 2.2 * self.applyScale(reference.size) > min(size.width, size.height) {
                    self.steadyScale *= min(size.width, size.height) / (2.2 * self.applyScale(reference.size))
                }
            }
    }
    
    public func panGesture(size: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                self.gestureRotation = .radians(-value.translation.width * Double.pi / 500)
                self.gesturePitch = .radians(value.translation.height * Double.pi / 500)
                
                if self.steadyPitch + self.gesturePitch > .zero {
                    self.gesturePitch = -self.steadyPitch
                }
                if self.steadyPitch + self.gesturePitch < -.radians(.pi) {
                    self.gesturePitch = -self.steadyPitch - .radians(.pi)
                }
            }
            .onEnded { value in
                self.steadyRotation += .radians(-value.translation.width * Double.pi / 500)
                self.steadyPitch += .radians(value.translation.height * Double.pi / 500)
                self.gestureRotation = .zero
                self.gesturePitch = .zero
                
                if self.steadyPitch > .zero {
                    self.steadyPitch = .zero
                }
                if self.steadyPitch < -.radians(.pi) {
                    self.steadyPitch = -.radians(.pi)
                }
            }
    }
    
    
    // MARK: - Display Validation
    
    public func showModel(_ node: Node, size: CGSize, modelSize: CGFloat) -> Bool {
        return 0.1...max(0.2, min(size.width, size.height)) ~= modelSize
    }
    public func showText(_ node: Node, size: CGSize) -> Bool {
        return (2 * applyScale(node.position.magnitude) > max(0.1 * min(size.width, size.height), 50) || node == reference) && (applyScale(node.size) * 100 < min(size.width, size.height))
    }
    public func showTrail(_ node: Node, size: CGSize) -> Bool {
        return applyScale(node.position.magnitude) < 2 * min(size.width, size.height) && (applyScale(node.size) * 50 < min(size.width, size.height))
    }
    
    
    // MARK: - Transformations
    
    // Coordinates in Space -> Position on Screen
    
    public func applyBaseScale(_ value: CGFloat) -> CGFloat {
        return value / defaultScaleRatio
    }
    public func applyBaseScale(_ value: Vector) -> Vector {
        return value / defaultScaleRatio
    }
    public func applyScale(_ value: CGFloat) -> CGFloat {
        return value * totalScale
    }
    public func applyScale(_ value: Vector) -> Vector {
        return value * totalScale
    }
    public func applyOffset(_ value: Vector) -> Vector {
        return value - offset
    }
    public func applyRotation(_ value: Vector) -> Vector {
        return value.rotated(by: -rotation.radians, about: [0,0,1])
    }
    public func applyPitch(_ value: Vector) -> Vector {
        return value.rotated(by: pitch.radians, about: [1,0,0])
    }
    public func applyHalfTransformations(_ value: Vector) -> Vector {
        return applyScale(applyOffset(value))
    }
    public func applyAllTransformations(_ value: Vector) -> Vector {
        return applyPitch(applyRotation(applyScale(applyOffset(value))))
    }
    
    // Position on Screen -> Coordinates in Space
    
    public func unapplyBaseScale(_ value: CGFloat) -> CGFloat {
        return value * defaultScaleRatio
    }
    public func unapplyBaseScale(_ value: Vector) -> Vector {
        return value * defaultScaleRatio
    }
    public func unapplyScale(_ value: CGFloat) -> CGFloat {
        return value / totalScale
    }
    public func unapplyScale(_ value: Vector) -> Vector {
        return value / totalScale
    }
    public func unapplyOffset(_ value: Vector) -> Vector {
        return value + offset
    }
    public func unapplyRotation(_ value: Vector) -> Vector {
        return value.rotated(by: rotation.radians, about: [0,0,1])
    }
    public func unapplyPitch(_ value: Vector) -> Vector {
        return value.rotated(by: -pitch.radians, about: [1,0,0])
    }
    public func unapplyHalfTransformations(_ value: Vector) -> Vector {
        return unapplyOffset(unapplyScale(value))
    }
    public func unapplyAllTransformations(_ value: Vector) -> Vector {
        return unapplyOffset(unapplyScale(unapplyRotation(unapplyPitch(value))))
    }
    
    
    // MARK: - Intent Functions
    
    public func select(_ node: Node?, size: CGSize) {
        // Reset object
        guard let node else {
            setObject(nil, size: size)
            return
        }
        // Select object in orbit
        if object != node.object {
            setObject(node.object, size: size)
        }
        // Tap target
        else if let object = node.object {
            zoomToSurface(node: object, size: size)
        }
    }
    
    // Change the reference node
    public func setReference(_ node: Node?) {
        self.reference = node
        if let node {
            // Load the ephemerides
            Task {
                await node.loadEphemerides()
                await MainActor.run {
                    // Add all the relevant nodes
                    withAnimation {
                        nodes = [node] + node.relatedNodes
                    }
                }
            }
        }
    }
    
    // Change the system node
    public func setSystem(system: SystemNode?, size: CGSize) {
        self.system = system
        if let system {
            // Remove the selected object if irrelevant
            if let object = object, !system.children.map(\.object).contains(object) {
                setObject(nil, size: size)
            }
        }
    }
    
    // Change the object node
    public func setObject(_ object: ObjectNode?, size: CGSize) {
        self.object = object
        if let object {
//            // Enter the parent system if not already
//            if reference != object.parent {
//                self.reference = object.parent
//            }
            // Zoom to the object when selected
            if object == reference?.object {
                zoomToSurface(node: object, size: size)
            } else {
                zoomToOrbit(node: object, size: size)
            }
        } else if let reference, 0...0.1 ~= offsetAmount {
            withAnimation {
                zoomToOrbit(node: reference, size: size)
            }
        }
    }
    
    // Called when a focus button is pressed
    private func changeFocus(trigger: Bool?, size: CGSize) {
        if let object, let focused = trigger {
            // Zoom to the object's surface or orbit
            if focused {
                zoomToSurface(node: object, size: size)
            } else {
                zoomToOrbit(node: object, size: size)
            }
        }
//        self.focusTrigger = nil
    }
    
    // Called when a back button is pressed
    private func goBack(trigger: Bool?, size: CGSize) {
        if let back = trigger, back, let system {
            // Go back to the parent system
            zoomToOrbit(node: system, size: size)
        }
//        self.backTrigger = nil
    }
    
    
    // MARK: - Animations
    
    // Update the view when navigation happens
    // Controls the focus position, current reference and selected system
    private func updateView(size: CGSize) {
        offsetAmount = 1.0
        guard let reference else { return }
        let scaleFactor: CGFloat = 1.2
        
        // Set the offset amount: the percentage which the focus is offset toward the child node
        // e.g. with the Sun as the reference node but Earth selected, offsetAmount = 0.5 would place the central focus halfway between the Earth & Sun
        let totalSize = applyScale(reference.position).magnitude + applyScale(((object ?? reference.object)?.size ?? .zero) * 2)
        let zoomScale = scaleFactor * totalSize / min(size.width, size.height)
        switch zoomScale {
        case ...0.5:
            offsetAmount *= 0
        case ...1:
            offsetAmount *= zoomScale*2 - 1
        default:
            offsetAmount *= 1.0
        }

        // Reference the child node if zoomed in enough (offset is beginning)
        if let object = object ?? reference.object, let childNode = reference.children.first(where: { $0.object == object }) {
            if scaleFactor * (applyScale(childNode.position).magnitude + applyScale(object.size * 2))/min(size.width, size.height) > 0.5 {
                setReference(childNode)
                updateView(size: size)
            }
        }
        // Reference the parent node if zoomed out enough (offset is ending)
        if let parentNode = reference.parent, zoomScale < 0.5 {
            setReference(parentNode)
            updateView(size: size)
        }

        // Select the child system if zoomed in enough (the reference node is a system that comprises more than 10px)
        if reference != system, let childSystem = reference as? SystemNode, let distance = childSystem.scaleDistance, applyScale(distance) > 10 {
            setSystem(system: childSystem, size: size)
        }
        // Select the parent system if zoomed out enough (the reference node is a system that comprises less than 10px)
        if let parentSystem = system?.parent, let distance = system?.scaleDistance, applyScale(distance) < 10 {
            setSystem(system: parentSystem, size: size)
        }
    }
    
    // Zoom to an object's surface
    private func zoomToSurface(node: Node, size: CGSize) {
        print("zooming to surface of \(node.name)")
        let node = node.object ?? node
        setReference(node.parent)
        zoomCamera(to: 100/*2.5*/ * node.size / min(size.width, size.height), size: size)
    }
    // Zoom to an object's orbital path
    private func zoomToOrbit(node: Node, size: CGSize) {
        print("zooming to orbit of \(node.name)")
        let node = node.system ?? node
        setReference(node.parent)
        zoomCamera(to: 2.5 * (node.position.magnitude + node.size) / min(size.width, size.height), size: size)
    }
    
    // Zooming animation
    private func zoomCamera(to scale: CGFloat, size: CGSize) {
        let newScale = defaultScaleRatio / scale
        let scaleRatio = newScale / steadyScale
        guard scaleRatio.isFinite else { return }
        let count = Int(ceil(abs(log2(scaleRatio))*2.5))
        let factor = scaleRatio < 1 ? 1/Double(count) : 1/Double(count)
        
        // Incrementally take zoom steps toward the destination
        for i in 0..<count {
            withAnimation(.linear(duration: 0.02).delay(0.02 * Double(i))) {
                steadyScale *= pow(scaleRatio, factor)
                updateView(size: size)
            }
        }
    }
    
    // Intro
    public func runIntro() {
        withAnimation(.easeInOut(duration: 3.0)) {
            introScale = 1.0
        }
    }
}
