//
//  Billboard.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 2/4/24.
//

import ARKit
import Foundation
import RealityKit
import SwiftUI

public struct BillboardComponent: Component, Codable {
    public init() { }
}

#if os(visionOS)
public class BillboardSystem: System {
    
    static let query = EntityQuery(where: .has(BillboardComponent.self))
    
    private let arKitSession = ARKitSession()
    private let worldTrackingProvider = WorldTrackingProvider()
    
    required public init(scene: RealityKit.Scene) {
        setUpSession()
    }
    
    func setUpSession() {
        Task {
            do {
                try await arKitSession.run([worldTrackingProvider])
            } catch {
                print(error)
            }
        }
    }
    
    public func update(context: SceneUpdateContext) {
        let entities = context.scene.performQuery(Self.query).map({ $0 })
        
        guard !entities.isEmpty, let pose = worldTrackingProvider.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) else { return }
        
        let cameraTransform = Transform(matrix: pose.originFromAnchorTransform)
        
        for entity in entities {
            entity.look(at: cameraTransform.translation, from: entity.position(relativeTo: nil), relativeTo: nil, forward: .positiveZ)
        }
    }
}
#else
public class BillboardSystem: System {
    
    private static let query = EntityQuery(where: .has(BillboardComponent.self))
    
    private var root: SimulationRootEntity?
    
    required public init(scene: RealityKit.Scene) { }
    
    public func update(context: SceneUpdateContext) {
        guard let root else {
            if let root = context.scene.findEntity(named: "root") as? SimulationRootEntity {
                self.root = root
            }
            return
        }
        guard let headPosition = root.arView?.cameraTransform.translation else { return }
        
        context.scene.performQuery(Self.query).forEach { entity in
            let entityPosition = entity.position(relativeTo: nil)
            let target = entityPosition - (headPosition - entityPosition)
            
            entity.look(at: target, from: entityPosition, relativeTo: nil)
        }
    }
}
#endif
