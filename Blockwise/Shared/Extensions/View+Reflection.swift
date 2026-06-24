//
//  View+Reflection.swift
//  Blockwise
//
//  Created by Ivan Sanna on 13/05/25.
//

import SwiftUI

struct ReflectionModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let size: CGFloat
    
    let fixedBlur: CGFloat?
    
    func body(content: Content) -> some View {
        content
            .background {
                content
                    .blur(radius: fixedBlur != nil ? fixedBlur! : size / 85.3)
                    .rotation3DEffect(
                        .degrees(180), axis: (x: 1.0, y: 0.0, z: 0.0)
                    )
                    .mask {
                        LinearGradient(
                            colors: [
                                .white.opacity(colorScheme == .dark ? 0.3 : 0.5),
                                .white.opacity(colorScheme == .dark ? 0.1 : 0.2),
                                .white.opacity(colorScheme == .dark ? 0.02 : 0.05),
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom)
                        .frame(width: size * 1.5, height: size * 1.5)
                    }
                    .offset(y: size/* * 1.05*/)
                    .scaleEffect(1.1)
                    .opacity(0.8)
            }
    }
}

// Convinience Extension
extension View {
    func makeReflection(size: CGFloat, fixedBlur: CGFloat? = nil) -> some View {
        self.modifier(ReflectionModifier(size: size, fixedBlur: fixedBlur))
    }
}
