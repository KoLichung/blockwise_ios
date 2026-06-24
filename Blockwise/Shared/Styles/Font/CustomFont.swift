//
//  CustomFont.swift
//  Blockwise
//
//  Created by Ivan Sanna on 08/07/25.
//

import SwiftUI

enum GroteskFontWeight: String {
    case regular = "HankenGrotesk-Regular"
    case medium = "HankenGrotesk-Medium"
    case semibold = "HankenGrotesk-SemiBold"
    case bold = "HankenGrotesk-Bold"
}

extension Font {
    static func grotesk(size: CGFloat, weight: GroteskFontWeight = .regular) -> Font {
        .custom(weight.rawValue, size: size)
    }
    
    static func grotesk(_ style: CustomFontSize = .body, weight: GroteskFontWeight = .regular) -> Font {
        .custom(weight.rawValue, size: style.rawValue)
    }
}

// For the widget
extension UIFont {
    static func grotesk(size: CGFloat, weight: GroteskFontWeight = .regular) -> UIFont {
        UIFont(name: weight.rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func grotesk(_ style: CustomFontSize = .body, weight: GroteskFontWeight = .regular) -> UIFont {
        UIFont(name: weight.rawValue, size: style.rawValue) ?? UIFont.systemFont(ofSize: style.rawValue)
    }
}

enum CustomFontSize: CGFloat {
    case largeTitle = 34
    case title = 28
    case title2 = 22
    case title3 = 20
    case body = 17
    case callout = 16
    case subheadline = 15
    case footnote = 13
    case caption = 12
    case caption2 = 11
}
