//
//  UtilityExtensions.swift
//  PlanetariaData
//
//  Created by Joe Rupertus on 1/12/23.
//

import Foundation
import SwiftUI
import SceneKit

// MARK: - Math Stuff

public let G: Double = 6.67259E-11 // N * m^2 / kg^2

public extension Double {
    
    func string(_ unit: Unit?) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 3
        numberFormatter.maximumSignificantDigits = unit is TimeU || unit is AngleU ? 3 : 2
        
        let quadrillion: Double = 1E+15
        let trillion: Double = 1E+12
        let billion: Double = 1E+9
        let million: Double = 1E+6
        
        if self >= quadrillion {
            return scientificString
        } else if self >= trillion {
            return "\(numberFormatter.string(from: NSNumber(value: self / trillion)) ?? "") T"
        } else if self >= billion {
            return "\(numberFormatter.string(from: NSNumber(value: self / billion)) ?? "") B"
        } else if self >= million {
            return "\(numberFormatter.string(from: NSNumber(value: self / million)) ?? "") M"
        } else {
            return "\(numberFormatter.string(from: NSNumber(value: self)) ?? "")"
        }
    }
    var string: String {
        return string(nil)
    }
    var scientificString: String {
        if abs(self) < 1E-10 { return "0" }
        let numberFormatter = NumberFormatter()
        if abs(self) >= 1E+9 || abs(self) < 1E-4 {
            numberFormatter.numberStyle = .scientific
            numberFormatter.exponentSymbol = "E"
            numberFormatter.maximumSignificantDigits = 3
        } else {
            numberFormatter.numberStyle = .decimal
            numberFormatter.groupingSeparator = ","
            if abs(self) < 1 {
                numberFormatter.maximumSignificantDigits = 3
                numberFormatter.maximumFractionDigits = 3
            } else {
                numberFormatter.maximumSignificantDigits = 3
            }
        }
        return numberFormatter.string(for: self) ?? "\(self)"
    }
    func absoluteLog(scale: Double = 1) -> Double {
        return self < 0 ? -log(-self*scale) : log(self*scale)
    }
}

// MARK: - CGSize Stuff

public extension CGSize {
    var center: CGPoint {
        CGPoint(x: width/2, y: height/2)
    }
    static func +(lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    static func -(lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    static func *(lhs: Self, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    static func /(lhs: Self, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width/rhs, height: lhs.height/rhs)
    }
}

public extension CGPoint {
    var magnitude: CGFloat {
        return sqrt(x*x + y*y)
    }
    var size: CGSize {
        return CGSize(width: x, height: y)
    }
    static func +(lhs: Self, rhs: Self) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    static func -(lhs: Self, rhs: Self) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

public extension SCNVector3 {
    var maxDistance: CGFloat {
        return CGFloat(max(x, max(y, z))) 
    }
    func scaleFactor() -> SCNVector3 {
        return SCNVector3(1/maxDistance, 1/maxDistance, 1/maxDistance)
    }
}

extension CGAffineTransform {
    public init(quaternion: simd_quatd) {
        let w = quaternion.vector.w
        let x = quaternion.vector.x
        let y = quaternion.vector.y
        let z = quaternion.vector.z
        
        self.init(
            a: 1 - 2*y*y - 2*z*z,
            b: 2*x*y - 2*w*z,
            c: 2*x*y + 2*w*z,
            d: 1 - 2*x*x - 2*z*z,
            tx: 2*x*z - 2*w*y,
            ty: 2*y*z + 2*w*x
        )
    }
}

// MARK: - Miscellaneous

#if os(iOS)
public extension UIFont {
    func rounded() -> UIFont {
        guard let descriptor = fontDescriptor.withDesign(.rounded) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
#endif

public extension Int {
    var ordinalString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(for: self) ?? String(self)
    }
    var romanNumeral: String? {
        guard self < 4000 else { return nil }
        let romanValues = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"]
        let intValues = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
        var num = self
        var romanString = ""

        for (index, romanChar) in romanValues.enumerated() {
            let intVal = intValues[index]
            while num >= intVal {
                romanString += romanChar
                num -= intVal
            }
        }
        return romanString
    }
}

public extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

public extension Date {
    var string: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMM dd HH:mm:ss"
        return formatter.string(from: self)
    }
    
    static let reference2000: Date = {
        var components = DateComponents()
        components.year = 2000
        components.month = 1
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        return Calendar(identifier: .gregorian).date(from: components)!
    }()

    static let reference2050: Date = {
        var components = DateComponents()
        components.year = 2050
        components.month = 1
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        return Calendar(identifier: .gregorian).date(from: components)!
    }()

    static let j2000ReferenceDate: Date = {
        var components = DateComponents()
        components.timeZone = .gmt
        components.year = 2000
        components.month = 1
        components.day = 1
        components.hour = 11
        components.minute = 58
        components.second = 56
        return Calendar(identifier: .gregorian).date(from: components)!
    }()
    
    var j2000Date: Double {
        return timeIntervalSince(Self.j2000ReferenceDate) / 86400
    }
    var j2000Century: Double {
        return j2000Date / 36525
    }
}

#if os(macOS)
typealias ColorType = NSColor
typealias FontType = NSFont
#else
typealias ColorType = UIColor
typealias FontType = UIFont
#endif

public extension Color {
    
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
    
    var hex: UInt32 {
        // Convert SwiftUI Color to UIColor
        let uiColor = ColorType(self)

        // Extract RGBA components
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        #if os(macOS)
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #else
        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return 0
        }
        #endif

        // Convert components (0.0 - 1.0) to 0 - 255 range
        let a = UInt32(alpha * 255) << 24
        let r = UInt32(red * 255) << 16
        let g = UInt32(green * 255) << 8
        let b = UInt32(blue * 255) << 0

        // Combine into a single UInt32 value in RRGGBBAA format
        return a | r | g | b
    }
    
    func lighter(amount: CGFloat = 0.3) -> Color {
        let uiColor = ColorType(self)
        let r = uiColor.cgColor.components?[0] ?? 0
        let g = uiColor.cgColor.components?[1] ?? 0
        let b = uiColor.cgColor.components?[2] ?? 0
        
        // Blend with white
        let newR = r + (1 - r) * amount
        let newG = g + (1 - g) * amount
        let newB = b + (1 - b) * amount
        
        return Color(red: newR, green: newG, blue: newB)
    }
}

#if os(visionOS)
public extension Size3D {
    var reduced: CGSize {
        return CGSize(width: width, height: height)
    }
}
#endif

public extension simd_quatf {
    static var identity: simd_quatf {
        return simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
    }
}

public extension SIMD3<Double> {
    /// Converts Cartesian coordinates to Spherical coordinates.
    /// - Returns: A tuple (r, θ, φ) where:
    ///   - `r`: Radius (distance from the origin)
    ///   - `θ`: Azimuth angle in radians (angle from the positive x-axis in the xy-plane)
    ///   - `φ`: Elevation angle in radians (angle from the xy-plane)
    func toSphericalCoordinates() -> (radius: Double, azimuth: Double, elevation: Double) {
        let x = self.x
        let y = self.y
        let z = self.z

        // Radius: r = sqrt(x^2 + y^2 + z^2)
        let radius = sqrt(x * x + y * y + z * z)

        // Azimuth: θ = atan2(x, z)
        let azimuth = atan2(x, z)

        // Elevation: φ = atan2(y, sqrt(x^2 + z^2))
        let elevation = sqrt(x * x + z * z) != 0 ? atan2(y, sqrt(x * x + z * z)) : 0

        return (radius, azimuth, elevation)
    }
}

enum GeneralError: Error {
    case somethingWentWrong
}
