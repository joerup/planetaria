//
//  Node+Visuals.swift
//  Planetaria
//
//  Created by Joe Rupertus on 1/14/23.
//

import Foundation
import SceneKit

extension ObjectNode {
    
    public struct Model {
        
        public var scene: SCNScene
        
        public init() {
            self.scene = SCNScene()
        }
        public init(visual: Visual) {
            if case .usdz(let name) = visual, let scene = SCNScene(named: "\(name).usdz") {
                scene.rootNode.childNodes.forEach { node in
                    node.name = "body"
                    node.scale = node.boundingBox.max.scaleFactor()
                }
                print("success for \(name)")
                self.scene = scene
            } else {
                self.scene = SCNScene()
                let geometry = SCNSphere(radius: 1)
                #if os(iOS)
                geometry.firstMaterial?.diffuse.contents = UIColor.systemGray5
                #endif
                let node = SCNNode(geometry: geometry)
                node.name = "body"
                scene.rootNode.addChildNode(node)
            }
        }
    }
    
    public enum Visual: Equatable, Codable {
        case usdz(name: String)
    }
}


