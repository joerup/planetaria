////
////  ARSimulator.swift
////  Planetaria
////
////  Created by Joe Rupertus on 1/17/23.
////
//
//import SwiftUI
//import RealityKit
//
//struct ARSimulator: View {
//    
//    @State var objects: [Object]
//    
//    // Center the simulation on the first object
//    private var centerPosition: [Double] {
//        return objects.first?.position ?? [0,0,0]
//    }
//    
//    @Binding var selectedObject: Object?
//    
//    var body: some View {
//        GeometryReader { geometry in
//            ARViewContainer(objects: objects, createEntity: createEntity)
//        }
//    }
//    
////    private func onTapGesture(_ entity: Entity) {
////
////        guard let object = objects.first(where: { $0.name == entity.name }) else { return }
////
////        withAnimation {
////            print("hi")
//////            if selectedObject == object {
//////                selectedObject = nil
//////            } else {
//////                selectedObject = object
//////            }
////        }
////
////        print("\(object.name) has been tapped!")
////    }
//    
//    private func createEntity(for object: Object) -> [Entity] {
//        
//        let entities: [Entity] = []
//        
////        for visual in object.allVisuals {
////
////            let scale = sizeScale(for: object)
////
////            // Mesh
////            var mesh: MeshResource
////            switch visual.shape {
////            case .sphere(let radius):
////                mesh = MeshResource.generateSphere(radius: Float(radius*scale))
////            case .ball(let meanRadius, _):
////                mesh = MeshResource.generateSphere(radius: Float(meanRadius*scale))
////            default:
////                continue
////            }
////
////            // Shape
////            var shape: ShapeResource
////            switch visual.shape {
////            case .sphere(let radius):
////                shape = ShapeResource.generateSphere(radius: Float(radius*scale))
////            case .ball(let meanRadius, _):
////                shape = ShapeResource.generateSphere(radius: Float(meanRadius*scale))
////            default:
////                continue
////            }
////
////            // Texture
////            var texture: PhysicallyBasedMaterial.BaseColor
////            switch visual.texture {
////            case .image(let name):
////                texture = .init(tint: .white.withAlphaComponent(0.999), texture: .init(try! .load(named: name)))
////            case .solidColor(let rgb):
////                texture = .init(tint: UIColor(red: rgb[0], green: rgb[1], blue: rgb[2], alpha: rgb.count > 3 ? rgb[3] : 1))
////            }
////
////            // Material
////            var material: RealityKit.Material
////            if visual.lit {
////                var litMaterial = UnlitMaterial()
////                litMaterial.color = texture
////                material = litMaterial
////            } else {
////                var unlitMaterial = SimpleMaterial()
////                unlitMaterial.color = texture
////                material = unlitMaterial
////            }
////
////            // Entity
////            let entity = ModelEntity(mesh: mesh, materials: [material])
////            entity.name = visual.name
////            entity.position = position(for: object)
////            entity.position.z -= 0.5
////            entity.position.y -= 0.1
////
////            // Collision
////            entity.collision = CollisionComponent(shapes: [shape])
////
////            // Lighting
////            let pointLight = PointLight()
////            pointLight.light.intensity = 50000
////            entity.addChild(pointLight)
////
////            entities.append(entity)
////        }
//        
//        return entities
//    }
//    
//    private let scale: Double = 0.5
//    
//    private func orbitalRadius(for object: Object) -> Double {
//        return Double(objects.firstIndex(of: object) ?? 0) * scale
//    }
//    
//    private func position(for object: Object) -> SIMD3<Float> {
//        let position = object.position - centerPosition
//        let unitVector = position.reduceDim.unitVector
//        guard !unitVector.isNan else { return SIMD3(0,0,0) }
//        let newVector = unitVector * orbitalRadius(for: object)
//        return newVector.simd3Vector()
//    }
//    
//    private func sizeScale(for object: Object) -> Double {
//        return scale
//    }
//}
