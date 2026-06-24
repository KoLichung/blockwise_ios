//
//  Color+Extension.swift
//  Blockwise
//
//  Created by Ivan Sanna on 28/10/24.
//

import SwiftUI

extension Color {
    /// Initializes a `Color` instance using a hexadecimal color value.
    ///
    /// - Parameters:
    ///   - hex: A 32-bit unsigned integer representing the RGB color in hexadecimal format.
    ///   - alpha: A `Double` value representing the opacity of the color. Default is `1.0` (fully opaque).
    ///
    /// - Important:
    ///     - The hex value should be in the format `0xRRGGBB`.
    ///     - The alpha value should be between `0.0` (fully transparent) and `1.0` (fully opaque).
    ///
    /// - Example:
    ///     ```
    ///     let redColor = Color(hex: 0xFF0000) // Red color
    ///     let semiTransparentBlue = Color(hex: 0x0000FF, alpha: 0.5) // Blue color with 50% opacity
    ///     ```
    init(hex: UInt32, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex & 0xFF0000) >> 16) / 255.0,
            green: Double((hex & 0x00FF00) >> 8) / 255.0,
            blue: Double(hex & 0x0000FF) / 255.0,
            opacity: alpha
        )
    }
}

extension Color {
    static let coral: Color = Color(hex: 0xFB5A12)
    static let primaryOrange: Color = Color(hex: 0xFB8C00)
    static let secondaryOrange: Color = Color(hex: 0xE65100)
    
    static let backgroundBlue: Color = Color(hex: 0x050726)
    static let primaryBlue: Color = Color.blue
    static let accentBlue: Color = Color(hex: 0x084FFF)
    static let secondaryBlue: Color = Color(hex: 0x101340)
    static let tertiaryBlue: Color = Color(hex: 0x2A2D55)
}
