//
//  View+Border.swift
//  Blockwise
//
//  Created by Ivan Sanna on 02/02/26.
//

import SwiftUI

extension View {
    func border(cornerRadius: CGFloat, color: Color = Color.secondary.opacity(0.1)) -> some View {
        self.modifier(BorderModifier(cornerRadius: cornerRadius, color: color))
    }
}

struct BorderModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let cornerRadius: CGFloat
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if colorScheme == .light {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(lineWidth: 2.0)
                        .foregroundStyle(color)
                }
            }
    }
}
