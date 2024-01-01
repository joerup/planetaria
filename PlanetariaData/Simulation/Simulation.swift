//
//  Simulation.swift
//
//
//  Created by Joe Rupertus on 11/7/23.
//

import Foundation
import SwiftUI

final public class Simulation: ObservableObject {
    
    // MARK: - Setup
    
    // First the simulation is initialized from a file containing a tree structure
    // The ephemerides are loaded for each node using API calls to Horizons
    // When enough ephemerides have loaded, the view can start displaying
    // When the view is ready, the simulation receives the size and ratio
    // and begins displaying the scene
    
    // File initializer
    public init(from fileName: String) {
        Task {
            await load(from: fileName)
//            await MainActor.run { run() }
        }
    }
    
    @Published public private(set) var isLoaded: Bool = false
    
    // Load the nodes from the file and then load the ephemerides
    private func load(from fileName: String) async {
        
        // Decode the tree from the file
        guard let file = Bundle.main.path(forResource: fileName, ofType: "json"),
              let json = try? String(contentsOfFile: file),
              let data = json.data(using: .utf8),
              let root = try? JSONDecoder().decode(System.self, from: data)
        else { return }
        
        // Set the default nodes
        await MainActor.run {
            self.root = root
            self.reference = root
            self.system = root
            self.allNodes = [root] + root.tree
        }
        
        // Load the ephemerides
        await root.loadEphemerides()
        await MainActor.run {
            self.isLoaded = true
            print("Finished loading")
        }
    }
    
    // Start displaying the scene
    public func startDisplay(size: CGFloat, ratio: CGFloat) {
        
        // Set the view's parameters
        self.size = size
        self.defaultScaleRatio = ratio
        
        // Initial setup of navigation
        self.navigate()
        
        // Run the intro
        #if os(iOS)
//        withAnimation(.easeInOut(duration: 3.0)) {
            introScale = 1.0
//        }
        #else
        introScale = 1.0
        #endif
    }
    
    
    // MARK: - Timing
    
    @Published public private(set) var timestamp: Date = .now
    
    private let timeStep: Double = 1.0
    private let timeRatio: Double = 86400*10
    private let animationTime: Double = 0.35
    
    private func run() {
        Timer.scheduledTimer(withTimeInterval: timeStep, repeats: true) { _ in
            
            // Calculate the virtual time step dt
            let dt = self.timeStep * self.timeRatio
            
            // Simulate each virtual time step dt over each real time step
            self.timestamp.addTimeInterval(dt)
            self.root?.simulate(dt: dt)
            
            print(self.timestamp.string)
        }
    }
    
    
    // MARK: - Structure
    
    @Published public private(set) var allNodes: [Node] = []
    @Published public private(set) var nodes: [Node] = []
    
    @Published private var root: Node?
    @Published private var reference: Node?
    @Published private var system: System?
    @Published private var object: Object?
    
    public var rootNode: Node? {
        return root
    }
    public var referenceNode: Node? {
        return reference
    }
    public var selectedSystem: System? {
        return system
    }
    public var selectedObject: Object? {
        return object
    }
    public func isSelected(_ node: Node) -> Bool {
        return node.object == object
    }
    public func isSystem(_ node: Node) -> Bool {
        return node.matches(system)
    }
    public func isReference(_ node: Node) -> Bool {
        return node.matches(reference)
    }
    public var noSelection: Bool {
        return object == nil
    }
    
    public func showModel(_ node: Node) -> Bool {
        return isSelected(node) || 0.1...max(0.2, size) ~= 2 * applyScale(node.size)
    }
    public func showText(_ node: Node) -> Bool {
        return node.parent == system && ((node.system == system || 2 * applyScale(node.position.magnitude) > max(0.1 * size, 50)) && (applyScale(node.size) * 10 < size))
    }
    public func showOrbit(_ node: Node) -> Bool {
        return showTrails && node.orbit != nil && node.parent == system && node.system != system && applyScale(node.size) * 10 < size
    }
    public func showTrail(_ node: Node) -> Bool {
        return applyScale(node.position.magnitude) < 2 * size && (applyScale(node.size) * 50 < size)
    }
    
    private func visibleNodes(scale: CGFloat, offset: Vector) -> [Node] {
        return allNodes.filter { node in
            guard node.isSet, node.parent == system || node.matches(system) else { return false }
            let location = scale/self.scale * applyAllTransformations(node.globalPosition - (offset-self.offset))
            return node.system == system || (-size...size ~= location.x && -size...size ~= location.y && applyScale(node.position.magnitude + node.size) * scale/self.scale * 500 > size)
        }
    }
    

    // MARK: - Positioning
    
    @Published public private(set) var size: CGFloat = 0
    @Published public private(set) var defaultScaleRatio: Double = 1E+7
    
    // Offset
    @Published public private(set) var offsetAmount: Double = 1.0
    @Published public private(set) var offset: Vector = .zero
    
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
    
    // Other
    @Published public private(set) var introScale: Double = 1E-3
    @Published private var showTrails: Bool = true
    
    
    // MARK: - Transformations
    
    // Coordinates in Virtual Space -> Position on Actual Screen
    
    public func applyBaseScale(_ value: CGFloat) -> CGFloat {
        return value / defaultScaleRatio
    }
    public func applyBaseScale(_ value: Vector) -> Vector {
        return value / defaultScaleRatio
    }
    public func applyScale(_ value: CGFloat) -> CGFloat {
        return value * scale / defaultScaleRatio
    }
    public func applyScale(_ value: Vector) -> Vector {
        return value * scale / defaultScaleRatio
    }
    public func applyOffset(_ value: Vector) -> Vector {
        return value - offset
    }
    public func applyRotation(_ value: Vector) -> Vector {
        return value.rotated(by: -rotation.radians, about: .e3)
    }
    public func applyPitch(_ value: Vector) -> Vector {
        return value.rotated(by: pitch.radians, about: .e1)
    }
    public func applyHalfTransformations(_ value: Vector) -> Vector {
        return applyScale(applyOffset(value))
    }
    public func applyAllTransformations(_ value: Vector) -> Vector {
        return applyPitch(applyRotation(applyScale(applyOffset(value))))
    }
    
    // Position on Actual Screen -> Coordinates in Virtual Space
    
    public func unapplyBaseScale(_ value: CGFloat) -> CGFloat {
        return value * defaultScaleRatio
    }
    public func unapplyBaseScale(_ value: Vector) -> Vector {
        return value * defaultScaleRatio
    }
    public func unapplyScale(_ value: CGFloat) -> CGFloat {
        return value / scale * defaultScaleRatio
    }
    public func unapplyScale(_ value: Vector) -> Vector {
        return value / scale * defaultScaleRatio
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
    
    
    // MARK: - Gestures
    
    public var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                self.gestureScale = value
                self.navigate()
                
                if let reference = self.reference, 2.2 * self.applyScale(reference.size) > self.size {
                    self.gestureScale *= self.size / (2.2 * self.applyScale(reference.size))
                }
            }
            .onEnded { value in
                self.steadyScale *= value
                self.gestureScale = 1.0
                self.navigate()
                
                if let reference = self.reference, 2.2 * self.applyScale(reference.size) > self.size {
                    self.steadyScale *= self.size / (2.2 * self.applyScale(reference.size))
                }
            }
    }
    
    public var panGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                #if os(visionOS)
                self.gestureRotation = .radians(-value.translation3D.x * Double.pi / 400)
                self.gesturePitch = .radians(value.translation3D.y * Double.pi / 400)
                #else
                self.gestureRotation = .radians(-value.translation.width * Double.pi / 400)
                self.gesturePitch = .radians(value.translation.height * Double.pi / 400)
                #endif
                
                if self.steadyPitch + self.gesturePitch > .zero {
                    self.gesturePitch = -self.steadyPitch
                }
                if self.steadyPitch + self.gesturePitch < -.radians(.pi) {
                    self.gesturePitch = -self.steadyPitch - .radians(.pi)
                }
            }
            .onEnded { value in
                #if os(visionOS)
                self.gestureRotation += .radians(-value.translation3D.x * Double.pi / 400)
                self.gesturePitch += .radians(value.translation3D.y * Double.pi / 400)
                #else
                self.steadyRotation += .radians(-value.translation.width * Double.pi / 400)
                self.steadyPitch += .radians(value.translation.height * Double.pi / 400)
                #endif
                
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
    
    
    // MARK: - Intent Functions
    
    public func select(_ node: Node?) {
        // Reset object
        guard let node else {
            setObject(nil)
            return
        }
        // Select object in orbit
        if object != node.object {
            setObject(node.object)
        }
        // Tap target
        else if let object = node.object {
            zoomToSurface(node: object)
        }
    }
    
    // Zoom to object surface
    public func selectObjectSurface() {
        guard let object else { return }
        zoomToSurface(node: object)
    }
    
    // Zoom to object orbit
    public func selectObjectOrbit() {
        guard let object else { return }
        zoomToOrbit(node: object)
    }
    
    // Zoom to local system
    public func selectLocalSystem() {
        guard let system = object?.system else { return }
        zoomToSystem(node: system)
    }
    
    // Zoom to system parent
    public func selectSystemParent() {
        guard let object = system?.object else { return }
        zoomToOrbit(node: object)
    }
    
    // Zoom in
    public func zoomIn() {
        zoom(by: 2)
    }
    // Zoom out
    public func zoomOut() {
        zoom(by: 0.5)
    }
    
    // Intent Configurations
    
    public var hasLocalSystem: Bool {
        return object?.system != nil
    }
    public var stateInOrbit: Bool {
        return system != object?.system && !stateOnSurface
    }
    public var stateInSystem: Bool {
        return system == object?.system && !stateOnSurface
    }
    public var stateOnSurface: Bool {
        return size <= applyScale(4 * (object?.size ?? 0))
    }

    
    // MARK: - Navigation Logic
    
    // Change the reference node
    private func setReference(_ node: Node?) {
        self.reference = node
    }
    
    // Change the system node
    private func setSystem(_ system: System?) {
        if object == nil {
            withAnimation {
                self.system = system
            }
        } else {
            self.system = system
        }
        // Remove the selected object if irrelevant
        if let system, let object = object, !system.children.map(\.object).contains(object) {
            setObject(nil)
        }
    }
    
    // Change the object node
    private func setObject(_ object: Object?) {
        self.object = object
        // Zoom to the object when selected
        if let object, object != reference?.object {
            zoomToOrbit(node: object)
        } else if let reference, 0...0.1 ~= offsetAmount {
            zoomToOrbit(node: reference)
        }
    }
    
    // Zoom by a certain amount
    private func zoom(by factor: CGFloat) {
        transition(reference: reference, size: unapplyScale(size) / factor)
        navigate()
    }
    
    // Zoom to a node's surface
    private func zoomToSurface(node: Node) {
        print("zooming to surface of \(node.name)")
        let node = node.object ?? node
        transition(reference: node, size: 2.5 * node.totalSize)
    }
    
    // Zoom to a node's orbital path
    private func zoomToOrbit(node: Node) {
        print("zooming to orbit of \(node.name)")
        let node = node.system ?? node
        transition(reference: node.parent, size: 2.5 * (node.position.magnitude + node.totalSize))
    }
    
    // Zoom to a node's local system
    private func zoomToSystem(node: Node) {
        print("zooming to system of \(node.name)")
        let node = node.object ?? node
        transition(reference: node.parent, size: min(130 * node.size, 2.5 * (node.siblings.filter({ $0.rank == .primary }).map(\.position.magnitude).max() ?? .infinity)))
    }
    
    // Transition animation
    // Move to a new offset, scale, and reference node
    private func transition(reference: Node?, size: CGFloat) {
        let scale = defaultScaleRatio / (size / self.size)
        guard let reference, scale.isFinite else { return }
        let offset = reference.globalPosition
        
        // Fade the trails if the offset will change
        if offset != self.offset {
            self.showTrails = false
        }
        
        // Set the reference and system nodes
        setReference(reference)
        if let system = (reference as? System) ?? reference.system {
            setSystem(system)
        }
        
        // Include all nodes involved in the transition
        let nodesAfter = visibleNodes(scale: scale, offset: offset)
        for node in nodesAfter {
            if !nodes.contains(where: { $0.matches(node) }) {
                nodes.append(node)
            }
        }
        
        // Perform the transition animation
        self.offsetAmount = 1.0
        withAnimation(.easeInOut(duration: animationTime)) {
            self.steadyScale = scale
            self.offset = offset
        }
        
        // Set the remaining nodes when the transition completes
        DispatchQueue.main.asyncAfter(deadline: .now() + animationTime) {
            withAnimation(.easeInOut(duration: self.animationTime)) {
                self.showTrails = true
            }
            self.nodes = nodesAfter
        }
    }
    
    // Navigation changes when gestures occur
    // Controls the focus position, current reference and selected system
    private func navigate() {
        guard let reference else { return }
        let scaleFactor: CGFloat = 1.2
        self.offsetAmount = 1.0
        
        // Set the offset amount: the percentage which the focus is offset toward the child node
        // e.g. with the Sun as the reference node but Earth selected, offsetAmount = 0.5 would place the central focus halfway between the Earth & Sun
        let totalSize = applyScale(reference.position).magnitude + applyScale(((object ?? reference.object)?.size ?? .zero) * 2)
        let zoomScale = scaleFactor * totalSize / size
        switch zoomScale {
        case ...0.5:
            offsetAmount *= 0
        case ...1:
            offsetAmount *= zoomScale*2 - 1
        default:
            offsetAmount *= 1.0
        }
        
        // Set the offset
        self.offset = (reference.parent?.globalPosition ?? .zero) + reference.position * offsetAmount
        
        // Set the visible nodes
        self.nodes = visibleNodes(scale: scale, offset: offset)
        
        // Reference the child node if zoomed in enough (offset is beginning)
        if let object = object ?? reference.object, let childNode = reference.children.first(where: { $0.object == object }) {
            if scaleFactor * (applyScale(childNode.position).magnitude + applyScale(object.size * 2))/size > 0.5 {
                setReference(childNode)
                navigate()
            }
        }
        // Reference the parent node if zoomed out enough (offset is ending)
        if let parentNode = reference.parent, zoomScale < 0.5 {
            setReference(parentNode)
            navigate()
        }

        // Select the child system if zoomed in enough (the reference node/child system is a system that comprises more than 10px)
        if !reference.matches(system), let childSystem = reference as? System, let distance = childSystem.scaleDistance, applyScale(distance) > 10 {
            setSystem(childSystem)
        }
        // Select the parent system if zoomed out enough (the reference node/child system is a system that comprises less than 10px)
        if let parentSystem = system?.parent, let distance = system?.scaleDistance, applyScale(distance) < 10 {
            setSystem(parentSystem)
        }
    }
}

