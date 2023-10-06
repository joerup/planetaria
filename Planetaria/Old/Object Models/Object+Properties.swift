////
////  Object+Properties.swift
////  Planetaria
////
////  Created by Joe Rupertus on 1/26/23.
////
//
//import Foundation
//
//
//extension Object {
//
//    func shortComparisonDescription<ObjectType: Object, ValueType: Equatable, UnitType: Unit>(for sorter: @escaping (ObjectType) -> Property<ValueType, UnitType>?, category: PropertyCategory) -> String? {
//        if let percentile = comparisonPercentile(for: sorter, comparingAgainst: getComparingObjects(for: category)) {
//            switch percentile {
//            case 0.0..<0.1: return "VERY LOW"
//            case 0.1..<0.2: return "LOW"
//            case 0.2..<0.3: return "LOW"
//            case 0.3..<0.4: return "BELOW AVERAGE"
//            case 0.4..<0.6: return "AVERAGE"
//            case 0.6..<0.7: return "ABOVE AVERAGE"
//            case 0.7..<0.8: return "HIGH"
//            case 0.8..<0.9: return "HIGH"
//            default         : return "VERY HIGH"
//            }
//        }
//        return nil
//    }
//
//    func comparisonPercentile<ObjectType: Object, ValueType: Equatable, UnitType: Unit>(for sorter: (ObjectType) -> Property<ValueType, UnitType>?, comparingAgainst objects: [Object]) -> Double? {
//        let comparingObjects = objects.compactMap{($0 as? ObjectType)}.compactMap({sorter($0)}).compactMap({$0 as? Property<Double, UnitType>}).map({$0.commonUnit()}).sorted()
//        guard comparingObjects.count > 3 else { return nil }
//        if let object = self as? ObjectType, let property = sorter(object) as? Property<Double, UnitType>, let index = comparingObjects.firstIndex(of: property.commonUnit()) {
//            return Double(index)/Double(comparingObjects.count-1)
//        }
//        return nil
//    }
//
//    func getComparingObjects(for category: PropertyCategory) -> [Object] {
//        switch category {
//        case .stellar: return allSimilarObjects
//        case .orbit: return allSimilarObjects
//        case .rotation: return allSimilarObjects
//        case .structure: return allMatchingObjects
//        case .environment: return allObjects
//        }
//    }
//
//    func categoryDescription(_ category: PropertyCategory) -> String? {
//
//        guard category.isExpandable else { return nil }
//
//        var sentence = "\(self.name) "
//
//        if category == .orbit, let percentile = comparisonPercentile(for: { $0.semimajorAxis }, comparingAgainst: getComparingObjects(for: .orbit)), let orbiting {
//
//            switch percentile {
//            case 0.0..<0.1: sentence += ["is very close to", "is really close to", "is extremely close to", "orbits quite close to"].randomElement()!
//            case 0.1..<0.2: sentence += ["orbits close to", "is pretty close to", "is relatively close to"].randomElement()!
//            case 0.2..<0.3: sentence += ["orbits somewhat close to", "revolves around", "orbits at an average distance from"].randomElement()!
//            case 0.3..<0.5: sentence += ["orbits somewhat far from", "lies at a distance from", "is sort of far from"].randomElement()!
//            case 0.5..<0.7: sentence += ["is pretty far from", "orbits pretty far from", "orbits far from"].randomElement()!
//            default: sentence += ["is very far away from", "orbits very far away from", "is really far away from"].randomElement()!
//            }
//
//            sentence += " \(orbiting.sentenceName)"
//
//            if let value = eccentricity?.commonUnit() {
//
//                sentence += ", and " + ["its orbital path is ", "its orbit is ", "its orbital shape is "].randomElement()!
//
//                switch value {
//                case 0.0..<0.01: sentence += ["very circular", "quite circular"].randomElement()!
//                case 0.01..<0.05: sentence += ["pretty circular"].randomElement()!
//                case 0.05..<0.12: sentence += ["slightly elliptical"].randomElement()!
//                case 0.12..<0.25: sentence += ["noticeably elliptical", "elliptical"].randomElement()!
//                case 0.25..<0.5: sentence += ["very elliptical", "quite elliptical"].randomElement()!
//                default: sentence += ["extremely elliptical"].randomElement()!
//                }
//            }
//
//            sentence += "."
//        }
//
//        else if category == .rotation, let percentile = comparisonPercentile(for: { $0.siderealRotation }, comparingAgainst: getComparingObjects(for: .rotation)) {
//
//            switch percentile {
//            case 0.0..<0.1: sentence += ["spins really fast", "rotates very quickly", "spins at a very fast pace", "rotates quite quickly"].randomElement()!
//            case 0.1..<0.25: sentence += ["rotates moderately quickly", "rotates pretty quickly", "spins pretty fast", "spins at a pretty quick pace"].randomElement()!
//            case 0.25..<0.4: sentence += ["rotates sort of quickly", "rotates somewhat quickly", "spins at a slightly fast pace"].randomElement()!
//            case 0.4..<0.6: sentence += ["spins at an average pace", "rotates at an average rate", "rotates at a decent speed"].randomElement()!
//            case 0.6..<0.75: sentence += ["rotates sort of slowly", "rotates somewhat slowly", "spins somewhat slowly"].randomElement()!
//            case 0.75..<0.9: sentence += ["rotates slowly", "spins slowly", "rotates pretty slowly", "spins pretty slowly"].randomElement()!
//            default: sentence += ["rotates extremely slowly", "spins very slowly", "rotates very slowly", "spins quite slowly"].randomElement()!
//            }
//
//            if let value = axialTilt?.commonUnit() {
//
//                if 75...105 ~= value {
//
//                    let text = [" spins on its side", " rotates on its side", "s axis is tilted almost perpendicular to its orbit", " essentially spins sideways", " essentially rotates sideways"].randomElement()!
//                    sentence += [" about its axis, and it" + text, ", and it" + text].randomElement()!
//
//                } else {
//
//                    if Bool.random() {
//                        sentence += " about its axis, which is "
//                    } else {
//                        sentence += ", and its axis is "
//                    }
//
//                    switch value {
//                    case 0..<5: sentence += ["nearly aligned with its orbit"].randomElement()!
//                    case 5..<15: sentence += ["slightly tilted"].randomElement()!
//                    case 15..<30: sentence += ["pretty tilted", "relatively tilted"].randomElement()!
//                    case 150..<165: sentence += ["pretty tilted", "relatively tilted"].randomElement()!
//                    case 165..<175: sentence += ["slightly tiled"].randomElement()!
//                    case 175..<180: sentence += ["nearly aligned with its orbit"].randomElement()!
//                    default: sentence += ["very tilted", "extremely tilted"].randomElement()!
//                    }
//
//                    if value > 90 {
//                        sentence += ". " + ["It rotates in the retrograde direction", "It rotates retrograde", "It spins retrograde"].randomElement()!
//                    }
//                }
//
//            } else {
//
//                if Bool.random() {
//                    sentence += " about its axis"
//                }
//            }
//
//            sentence += "."
//        }
//
//        else if category == .structure, let percentile = comparisonPercentile(for: { $0.meanRadius }, comparingAgainst: getComparingObjects(for: .structure)) {
//
//            switch percentile {
//            case 0..<0.2: sentence += ["is really small", "is pretty small", "is a tiny \(sentenceTypeName)", "is a small \(sentenceTypeName)", "is quite a small \(sentenceTypeName)"].randomElement()!
//            case 0.2..<0.4: sentence += ["is relatively small", "is a relatively small \(sentenceTypeName)", "is a somewhat small \(sentenceTypeName)", "is somewhat small", "is smaller than average", "is slightly smaller than average"].randomElement()!
//            case 0.4..<0.6: sentence += ["is an average-sized \(sentenceTypeName)", "is an average size", "is a medium-sized \(sentenceTypeName)", "is a moderate size", "is a moderately-sized \(sentenceTypeName)"].randomElement()!
//            case 0.6..<0.8: sentence += ["is relatively large", "is a somewhat large \(sentenceTypeName)", "is somewhat big", "is a relatively big \(sentenceTypeName)", "is slightly larger than average", "is larger than average"].randomElement()!
//            default: sentence += ["is really big", "is a really large \(sentenceTypeName)", "is a pretty big \(sentenceTypeName)", "is a really big \(sentenceTypeName)", "is pretty large", "is really large"].randomElement()!
//            }
//
//            if let percentile = comparisonPercentile(for: { $0.mass }, comparingAgainst: getComparingObjects(for: .structure)) {
//
//                sentence += [" with ", ". It has "].randomElement()!
//
//                switch percentile {
//                case 0..<0.2: sentence += ["a very low mass", "a pretty small mass", "a pretty low mass", "a very small mass"].randomElement()!
//                case 0.2..<0.4: sentence += ["a low mass", "a lower than average mass", "a small mass"].randomElement()!
//                case 0.4..<0.6: sentence += ["an average mass", "a medium mass", "a moderate mass"].randomElement()!
//                case 0.6..<0.8: sentence += ["a high mass", "a higher than average mass"].randomElement()!
//                default: sentence += ["a very high mass", "a pretty high mass"].randomElement()!
//                }
//            }
//
//            sentence += "."
//        }
//
//        else if category == .environment {
//
//            if let value = self.temperature?.commonUnit() {
//
//                sentence += "is "
//
//                switch value {
//                case 0..<100: sentence += "unimaginably cold"
//                case 100..<200: sentence += "absolutely freezing"
//                case 200..<225: sentence += "ridiculously cold"
//                case 200..<250: sentence += "really cold"
//                case 250..<275: sentence += "pretty chilly"
//                case 275..<300: sentence += "a comfortable temperature"
//                case 300..<325: sentence += "pretty warm"
//                case 325..<400: sentence += "really hot"
//                case 400..<500: sentence += "ridiculously hot"
//                case 500..<1000: sentence += "absolutely scorching"
//                default: sentence += "unimaginably hot"
//                }
//
//                if let value = self.pressure?.commonUnit() {
//
//                    sentence += [" and ", ". It "].randomElement()!
//
//                    switch value {
//                    case 0: sentence += ["has no atmosphere", "lacks an atmosphere"].randomElement()!
//                    case 0..<0.1: sentence += ["has little to no atmosphere", "barely has an atmosphere"].randomElement()!
//                    case 0.1..<0.7: sentence += "has a light atmosphere"
//                    case 0.7..<1.2: sentence += "has a significant atmosphere"
//                    case 1.2..<10: sentence += "has a heavy atmosphere"
//                    case 10..<50: sentence += "has a really heavy atmosphere"
//                    default: sentence += "has a mind-crushing atmosphere with a runaway greenhouse effect"
//                    }
//                }
//
//                if self.surfaceGravity != nil {
//                    sentence += [". It also ", "; it ", ". Additionally, it ", ". It "].randomElement()!
//                }
//            }
//
//            if let value = comparisonPercentile(for: { $0.surfaceGravity }, comparingAgainst: getComparingObjects(for: .environment)) {
//
//                sentence += "has a "
//
//                switch value {
//                case 0..<0.2: sentence += "very low surface gravity"
//                case 0.2..<0.4: sentence += "low surface gravity"
//                case 0.4..<0.6: sentence += "moderate surface gravity"
//                case 0.6..<0.8: sentence += "high surface gravity"
//                default: sentence += "very high surface gravity"
//                }
//            }
//
//            sentence += "."
//        }
//
//        return sentence
//    }
//}
