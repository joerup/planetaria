//
//  UtilityExtensions.swift
//  Planetaria
//
//  Created by Joe Rupertus on 1/12/23.
//

import Foundation
import SwiftUI
import SceneKit

// MARK: - Gradients

public extension View {
    func gradientForeground(colors: [Color]) -> some View {
        self.overlay(
            LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
        )
        .mask(self)
    }
}

// MARK: - Math Stuff

public let G: Double = 6.67259E-11 // N * m^2 / kg^2

public extension Double {
    
    func string(_ unit: Unit?) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 3
        numberFormatter.maximumSignificantDigits = unit is TimeU || unit is AngleU ? 3 : 2
        
        let quadrillion = 1E+15
        let trillion = 1E+12
        let billion = 1E+9
        let million = 1E+6
        
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
    
    var j2000Date: Double {
        let j2000ReferenceDate = DateComponents(timeZone: .gmt, year: 2000, month: 1, day: 1, hour: 11, minute: 58, second: 56)
        let calendar = Calendar(identifier: .gregorian)
        let referenceDate = calendar.date(from: j2000ReferenceDate)!
        return timeIntervalSince(referenceDate) / 86400
    }
    var j2000Century: Double {
        return j2000Date / 36525
    }
}

public extension Color {
    
    // Initialize Color from a hex string (e.g., "#FF0000" for red)
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
}

#if os(visionOS)
public extension Size3D {
    var reduced: CGSize {
        return CGSize(width: width, height: height)
    }
}
#endif
