//
//  PressButton.swift
//  Blockwise
//
//  Created by Ivan Sanna on 18/01/26.
//

import SwiftUI

enum PressShadowStyle {
    case ligher
    case darker
    
    var brightness: Double {
        switch self {
        case .ligher:
            return 0.10
        case .darker:
            return -0.25
        }
    }
}

struct PressButton<Content: View>: View {
    
    let action: () -> Void
    let content: () -> Content
    
    let background: Color
    let labelColor: Color
    let shadowStyle: PressShadowStyle
    
    init(
        _ label: String,
        background: Color = .fillAccent,
        labelColor: Color = .white,
        shadowStyle: PressShadowStyle = .darker,
        action: @escaping () -> Void
    ) where Content == AnyView {
        self.content = {
            AnyView(
                RoundedRectangle(cornerRadius: 100, style: .continuous)
                    .foregroundStyle(background)
                    .frame(height: 55.0)
                    .overlay {
                        Text(label)
                            .font(.grotesk(size: 20, weight: .semibold))
                            .foregroundStyle(labelColor)
                    }
            )
        }
        self.action = action
        self.background = background
        self.labelColor = labelColor
        self.shadowStyle = shadowStyle
    }
    
    var body: some View {
        content()
            .onTapGesture(perform: action)
            .modifier(PressButtonViewModifier(shadowStyle: shadowStyle))
    }
}

struct PressButtonViewModifier: ViewModifier {
    @State private var offsetY: CGFloat = 0.0
    @State private var isPressed: Bool = false
    
    let shadowStyle: PressShadowStyle
    
    private let offsetYAxis: CGFloat = 4
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        withAnimation(.snappy(duration: 0.2)) {
                            offsetY = offsetYAxis
                            isPressed = true
                        }
                    }
                    .onEnded { value in
                        if isPressed {
                            // Avoid haptic if gesture already returned
                            Haptics.feedback(style: .medium)
                        }
                        
                        withAnimation(.snappy(duration: 0.2)) {
                            offsetY = 1.0
                            isPressed = false
                        }
                    }
            )
            .brightness(isPressed ? -0.01 : 0.0)
            .offset(y: offsetY)
            .background {
                content
                    .brightness(shadowStyle.brightness)
                    .offset(y: offsetYAxis)
            }
            .sensoryFeedback(.selection, trigger: isPressed)
    }
}

#Preview {
    PressButton("Continue") {
        
    }
    .foregroundStyle(Color.primaryBlue)
    .padding(32)
}
