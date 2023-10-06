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
    
    var string: String {
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
                numberFormatter.maximumFractionDigits = 2
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
    // the center point of an area that is our size
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
}

public extension SCNVector3 {
    var maxDistance: CGFloat {
        return CGFloat(max(x, max(y, z))) 
    }
    func scaleFactor() -> SCNVector3 {
        return SCNVector3(1/maxDistance, 1/maxDistance, 1/maxDistance)
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

public extension PresentationDetent {
    
    static var small: PresentationDetent {
        .height(95)
    }
    static var preview: PresentationDetent {
        .fraction(0.4)
    }
    
    func height(size: CGSize) -> CGFloat {
        if self == .small {
            return 100
        } else {
            return size.height*0.4
        }
    }
}
