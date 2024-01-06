//
//  Simulation.swift
//
//
//  Created by Joe Rupertus on 11/7/23.
//

import Foundation
import SwiftUI
import RealityKit

final public class Simulation: ObservableObject {
    
    // MARK: - Setup
    
    @Published public private(set) var isLoaded: Bool = false
    
    // Part 1. Main initializer
    // This receives the nodes from a file and then retrieves their positions
    public init(from fileName: String) {
        Task {
            // Decode the tree from the file
            guard let file = Bundle.main.path(forResource: fileName, ofType: "json"),
                  let json = try? String(contentsOfFile: file),
                  let data = json.data(using: .utf8),
                  let root = try? JSONDecoder().decode(System.self, from: data)
            else { return }
            
            // Instantiate the node references
            await MainActor.run {
                self.root = root
                self.focus = root
                self.system = root
                self.allNodes = root.tree
            }
            print("Finished decoding nodes")
            
            // Load the ephemerides
            await root.loadEphemerides()
            print("Finished loading ephemerides")
            
            // Load the entities
            for i in self.allNodes.indices {
                let entity = await SimulationEntity(node: self.allNodes[i])
                await MainActor.run { self.allNodes[i].entity = entity }
            }
            print("Finished creating entities")
            
            await MainActor.run {
                self.isLoaded = true
            }
        }
    }
    
    // Part 2. Setup display
    // This receives the scaling parameters from the simulator view
    public func setupDisplay(size: CGFloat) {
        let distance = allNodes.filter({ $0.rank == .primary }).map(\.position.magnitude).max() ?? 1
        
        // Get the view's scaling parameters
        self.size = size
        self.defaultScaleRatio = 2.5 * distance / size
        
        // Initial setup of navigation
        self.navigate()
    }
    
    
    // MARK: - Structure
    
    @Published private var root: Node?
    @Published private var focus: Node?
    @Published private var system: System?
    @Published private var object: Object?
    
    @Published public private(set) var allNodes: [Node] = []
    
    @Published public private(set) var currentNodes: [Node] = []
    @Published public private(set) var currentBodies: [Object] = []
    
    public var rootNode: Node? {
        return root
    }
    public var focusNode: Node? {
        return focus
    }
    public var selectedSystem: System? {
        return system
    }
    public var selectedObject: Object? {
        return object
    }
    
    public func isSelected(_ node: Node?) -> Bool {
        return node?.object == object
    }
    public func isSystem(_ node: Node?) -> Bool {
        return node?.matches(system) ?? false
    }
    public func isFocus(_ node: Node?) -> Bool {
        return node?.matches(focus) ?? false
    }
    
    public var hasSelection: Bool {
        return object != nil
    }
    public var noSelection: Bool {
        return object == nil
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
    
    @Published private var inTransition: Bool = false
    
    
    // MARK: - Timing
    
    @Published public private(set) var timestamp: Date = .now
    
    private let timeStep: Double = 1.0
    private let timeRatio: Double = 86400*10
    public let animationTime: Double = 0.35
    
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
    
    
    // MARK: - RealityKit Stuff
    
    public var entities: [SimulationEntity] {
        return currentNodes.compactMap(\.entity)
    }
    
    private func syncNodesAndEntities(animated: Bool = false) {
        for i in allNodes.indices {
            if currentBodies.contains(where: { allNodes[i].matches($0) }) {
                allNodes[i].entity?.showBody()
            } else {
                allNodes[i].entity?.hideBody()
            }
            updateEntity(node: allNodes[i], animated: animated)
        }
    }
    
    private func updateEntity(node: Node, animated: Bool) {
        guard let entity = node.entity else { return }
        
        let position = applyScale(applyOffset(node.globalPosition)) / size
        let transform = Transform(translation: position.simdf - entity.position)
        
        if currentNodes.contains(where: { node.matches($0) }) {
            if animated {
                entity.move(to: transform, relativeTo: entity, duration: animationTime, timingFunction: .easeInOut)
            } else {
                entity.move(to: transform, relativeTo: entity)
            }
        } else {
            entity.position = position.simdf
        }
        
        if let body = entity.body {
            
            let scale = Float(applyScale(2 * node.totalSize) / size)
            let transform = Transform(scale: [scale,scale,scale] / body.scale.max())
            
            if currentNodes.contains(where: { node.matches($0) }) {
                if animated {
                    body.move(to: transform, relativeTo: body, duration: animationTime, timingFunction: .easeInOut)
                } else {
                    body.move(to: transform, relativeTo: body)
                }
            } else {
                body.scale = [scale,scale,scale]
            }
        }
    }
    
    
    // MARK: - Validation
    
    public func showNode(_ node: Node, scale: CGFloat, offset: Vector) -> Bool {
        guard node.isSet, node.parent == system /*|| node.matches(system)*/ else { return false }
        let location = scale/self.scale * transform(node.globalPosition - (offset-self.offset))
        return node.system == system || (location.isWithin(10*size) && applyScale(node.position.magnitude + node.size) * scale/self.scale * 500 > size)
    }
    public func showBody(_ node: Node, scale: CGFloat, offset: Vector) -> Bool {
        let location = scale/self.scale * transform(node.globalPosition - (offset-self.offset))
        return location.isWithin(10*size) && 3...max(4, size) ~= applyScale(node.size) * scale/self.scale
    }
    public func showOrbit(_ node: Node) -> Bool {
        return !inTransition && node.orbit != nil && node.parent == system && node.system != system
    }
    
    public func trailVisibility(_ node: Node) -> CGFloat {
        return !inTransition && applyScale(node.position.magnitude) < 2 * size && (applyScale(node.size) * 50 < size) ? 1 : 0
    }
    public func textVisibility(_ node: Node) -> CGFloat {
        return !inTransition && node.parent == system && ((node.system == system || 2 * applyScale(node.position.magnitude) > max(0.1 * size, 50)) && (applyScale(node.size) * 10 < size)) ? 1 : 0
    }
    
    
    // MARK: - Transformations
    
    // Coordinates in Virtual Space -> Position on Actual Screen
    
    public func applyScale(_ value: CGFloat) -> CGFloat {
        return value * scale / defaultScaleRatio
    }
    public func applyBaseScale(_ value: CGFloat) -> CGFloat {
        return value / defaultScaleRatio
    }
    public func applySafeScale(_ value: CGFloat) -> CGFloat {
        return min(2*size, applyScale(value))
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
    public func transform(_ value: Vector) -> Vector {
        return applyPitch(applyRotation(applyScale(applyOffset(value))))
    }
    
    // Position on Actual Screen -> Coordinates in Virtual Space
    
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
    
    
    // MARK: - Inputs
    
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
    
    public func selectSurface() {
        guard let object else { return }
        zoomToSurface(node: object)
    }
    
    public func selectOrbit() {
        guard let object else { return }
        zoomToOrbit(node: object)
    }
    
    public func selectSystem() {
        guard let system = object?.system else { return }
        zoomToSystem(node: system)
    }
    
    public func leaveSystem() {
        guard let object = system?.object else { return }
        zoomToOrbit(node: object)
    }
    
    // Input Configurations
    
    public var hasOrbit: Bool {
        return object != root?.object
    }
    public var hasSystem: Bool {
        return object?.system != nil
    }
    public var stateOrbit: Bool {
        return system != object?.system && !stateSurface
    }
    public var stateSystem: Bool {
        return system == object?.system && !stateSurface
    }
    public var stateSurface: Bool {
        return size <= applyScale(4 * (object?.totalSize ?? 0))
    }
    
    
    // MARK: - Gestures
    
    // Scale
    
    public func updateScaleGesture(to value: CGFloat) {
        self.gestureScale = value
        
        if let focus, 1.1 * applyScale(focus.size) > size {
            self.gestureScale *= size / (1.1 * applyScale(focus.size))
        }
        self.navigate()
    }
    public func completeScaleGesture(to value: CGFloat) {
        self.steadyScale *= value
        self.gestureScale = 1.0
        
        if let focus, 1.1 * applyScale(focus.size) > size {
            self.steadyScale *= size / (1.1 * applyScale(focus.size))
        }
        self.navigate()
    }
    
    // Orientation
    
    private let translationAngleFactor: CGFloat = .pi / 400
    
    public func updateRotationGesture(with translation: CGFloat) {
        self.gestureRotation = .radians(-translation * translationAngleFactor)
    }
    public func completeRotationGesture(with translation: CGFloat) {
        self.steadyRotation += .radians(-translation * translationAngleFactor)
        self.gestureRotation = .zero
    }
    
    public func updatePitchGesture(with translation: CGFloat) {
        self.gesturePitch = .radians(translation * translationAngleFactor)
        
        if steadyPitch + gesturePitch > .zero {
            gesturePitch = -steadyPitch
        }
        if steadyPitch + gesturePitch < -.radians(.pi) {
            gesturePitch = -steadyPitch - .radians(.pi)
        }
    }
    public func completePitchGesture(with translation: CGFloat) {
        self.steadyPitch += .radians(translation * translationAngleFactor)
        self.gesturePitch = .zero
        
        if steadyPitch > .zero {
            steadyPitch = .zero
        }
        if steadyPitch < -.radians(.pi) {
            steadyPitch = -.radians(.pi)
        }
    }

    
    // MARK: - Navigation Logic
    
    // Change the focus node
    private func setFocus(_ node: Node?) {
        self.focus = node
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
        withAnimation {
            self.object = object
        }
        // Zoom to the object when selected
        if let object, object == system?.object, let focus, !focus.matches(system), !focus.matches(object) {
            zoomToOrbit(node: focus)
        }
        else if let object, object != focus?.object {
            zoomToOrbit(node: object)
        } 
        else if let focus, 0...0.1 ~= offsetAmount {
            zoomToOrbit(node: focus)
        }
    }
    
    // Zoom to a node's surface
    private func zoomToSurface(node: Node) {
        print("zooming to surface of \(node.name)")
        let node = node.object ?? node
        transition(focus: node, size: 2.5 * node.totalSize)
    }
    
    // Zoom to a node's orbital path
    private func zoomToOrbit(node: Node) {
        print("zooming to orbit of \(node.name)")
        let node = node.system ?? node
        transition(focus: node.parent, size: 2.5 * (node.position.magnitude + node.totalSize))
    }
    
    // Zoom to a node's local system
    private func zoomToSystem(node: Node) {
        print("zooming to system of \(node.name)")
        let node = node.object ?? node
        let distance = node.siblings.filter({ $0.rank == .primary }).map(\.position.magnitude).max() ?? .infinity
        transition(focus: node.parent, size: min(130 * node.size, 2.5 * distance))
    }
    
    // Transition animation
    // Move to a new offset, scale, and focus node
    private func transition(focus: Node?, size: CGFloat) {
        let scale = defaultScaleRatio / (size / self.size)
        guard let focus, scale.isFinite else { return }
        let system = focus.system
        let offset = focus.globalPosition
        
        // Some elements fade during transitions to prevent awkward animations
        
        // if the selected system will change
        // all trails will be changed
        if system != self.system {
            self.inTransition = true
        }
        // or there is a reference to a child whose trail is not visible
        // this means the camera is zoomed/offset at least partially toward the surface of the child
        // new trails will need to be loaded on whichever endpoint is being transitioned to
        if let focus = self.focus, !focus.matches(system), !focus.matches(system?.object), trailVisibility(focus) == 0 {
            self.inTransition = true
        }
        
        // Set the focus and system nodes
        setFocus(focus)
        if let system {
            setSystem(system)
        }
        
        // Determine the nodes and bodies which will be visible after the transition
        let nodesAfter = allNodes.filter { showNode($0, scale: scale, offset: offset) }
        let bodiesAfter = nodesAfter.compactMap({ $0 as? Object }).filter { showBody($0, scale: scale, offset: offset) }
        
        #if os(visionOS)
        
        self.inTransition = false
        
        self.currentNodes = nodesAfter
        self.currentBodies = bodiesAfter
        
        self.offsetAmount = 1.0
        self.steadyScale = scale
        self.offset = offset
        
        #else
        
        // Display all nodes that will be involved in the transition (visible either before or after)
        for node in nodesAfter {
            if !currentNodes.contains(where: { $0.matches(node) }) {
                currentNodes.append(node)
            }
        }
        for body in bodiesAfter {
            if !currentBodies.contains(where: { $0.matches(body) }) {
                currentBodies.append(body)
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
                self.inTransition = false
            }
            self.currentNodes = nodesAfter
            self.currentBodies = bodiesAfter
            self.syncNodesAndEntities(animated: true)
        }
        #endif
    }
    
    // Navigation changes when gestures occur
    // Controls the focus position, current reference and selected system
    private func navigate() {
        guard let focus else { return }
        let scaleFactor: CGFloat = 1.2
        self.offsetAmount = 1.0
        
        // Set the offset amount: the percentage which the focus is offset toward the child node
        // e.g. with the Sun as the reference node but Earth selected, offsetAmount = 0.5 would place the central focus halfway between the Earth & Sun
        let totalSize = applyScale(focus.position).magnitude + applyScale(((object ?? focus.object)?.size ?? .zero) * 2)
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
        self.offset = (focus.parent?.globalPosition ?? .zero) + focus.position * offsetAmount
        
        // Set the current nodes and bodies
        self.currentNodes = allNodes.filter { showNode($0, scale: scale, offset: offset) }
        self.currentBodies = currentNodes.compactMap({ $0 as? Object }).filter { showBody($0, scale: scale, offset: offset) }
        
        self.syncNodesAndEntities()
        
        // Focus to the child node if zoomed in enough (offset is beginning)
        if let object = object ?? focus.object, let childNode = focus.children.first(where: { $0.object == object }) {
            if scaleFactor * (applyScale(childNode.position).magnitude + applyScale(object.size * 2))/size > 0.5 {
                setFocus(childNode)
                navigate()
            }
        }
        // Focus to the parent node if zoomed out enough (offset is ending)
        if let parentNode = focus.parent, zoomScale < 0.5 {
            setFocus(parentNode)
            navigate()
        }

        // Select the child system if zoomed in enough (the reference node/child system is a system that comprises more than 10px)
        if !focus.matches(system), let childSystem = focus as? System, let distance = childSystem.scaleDistance, applyScale(distance) > 10 {
            setSystem(childSystem)
        }
        // Select the parent system if zoomed out enough (the reference node/child system is a system that comprises less than 10px)
        if let parentSystem = system?.parent, let distance = system?.scaleDistance, applyScale(distance) < 10 {
            setSystem(parentSystem)
        }
    }
}

