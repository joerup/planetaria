//
//  Simulation+Navigation.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 12/9/24.
//

extension Simulation {
    
    // MARK: - Public Navigation API
    
    // Object Interaction Handler
    
    public func selectObject(_ node: Node?) {
        guard transition == nil else { return }
        // Reset object
        guard let node, selectEnabled else {
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
    
    // Navigation Button Functions
    
    public func selectSurface() {
        guard let object, transition == nil else { return }
        zoomToSurface(node: object)
    }
    public func selectOrbit() {
        guard let object, transition == nil else { return }
        zoomToOrbit(node: object)
    }
    public func selectSystem() {
        guard let system = object?.system, transition == nil else { return }
        zoomToSystem(node: system)
    }
    public func leaveSystem() {
        guard let object = system?.object, transition == nil else { return }
        zoomToOrbit(node: object)
    }
    
    // Navigation Configuration States
    
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
        return scale * (object?.totalSize ?? 0) >= (!hasSystem ? 0.05 : 0.25) * size
    }
    
    
    // MARK: - Internal Navigation Methods
    
    // Change the focus node
    func setFocus(_ node: Node?) {
        self.focus = node
    }
    
    // Change the system node
    func setSystem(_ system: SystemNode?) {
        self.system = system
        if let system, let object, !system.children.map(\.object).contains(object) {
            setObject(nil)
        }
    }
    
    // Change the object node
    func setObject(_ object: ObjectNode?) {
        if let object {
            self.object = object
            if let focus, object != focus, object == object.system?.object, focus.parent == object.system {
                zoomToOrbit(node: focus)
            }
            else if let focus, object != focus, object == object.system?.object, focus.parent?.parent == object.system {
                zoomToOrbit(node: focus.parent ?? focus)
            }
            else if object != focus?.object {
                zoomToOrbit(node: object)
            }
        }
        else if let object = self.object {
            self.object = object.parent == root ? nil : object.hostNode == object.parent?.object ? object.hostNode : nil
            if object == focus?.object || focus != (object.system ?? object).parent {
                zoomToOrbit(node: object)
            }
        }
    }
}
