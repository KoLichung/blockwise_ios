//
//  StrokedPressButton.swift
//  Blockwise
//
//  Created by Ivan Sanna on 18/01/26.
//

import SwiftUI

struct StrokedPressButton<Content: View>: View {
    
    let action: () -> Void
    let content: () -> Content
    
    let alignment: HorizontalAlignment
    let cornerRadius: CGFloat
    let color: Color
    
    let height: CGFloat
    
    init(
        cornerRadius: CGFloat = 100,
        height: CGFloat = 55.0,
        color: Color = .fillGray,
        @ViewBuilder label: @escaping () -> some View,
        action: @escaping () -> Void
    ) where Content == AnyView {
        self.content = {
            AnyView(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .foregroundStyle(.background)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(lineWidth: 3.0)
                            .foregroundStyle(color)
                    }
                    .frame(height: height)
                    .overlay {
                        AnyView(label())
                    }
            )
        }
        self.alignment = .center
        self.cornerRadius = cornerRadius
        self.action = action
        self.color = color
        self.height = height
    }
    
    init(
        _ label: String,
        alignment: HorizontalAlignment = .center,
        cornerRadius: CGFloat = 100,
        action: @escaping () -> Void
    ) where Content == AnyView {
        self.content = {
            AnyView(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .foregroundStyle(.background)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(lineWidth: 3.0)
                            .foregroundStyle(.fillGray)
                    }
                    .frame(height: 55.0)
                    .overlay {
                        Text(label)
                            .font(.grotesk(size: 20, weight: .semibold))
                            .foregroundStyle(Color.primary)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity, alignment: .init(horizontal: alignment, vertical: .center))
                    }
            )
        }
        self.alignment = alignment
        self.cornerRadius = cornerRadius
        self.action = action
        self.color = .fillGray
        self.height = 55.0
    }
    
    var body: some View {
        content()
            .onTapGesture(perform: action)
            .modifier(StrokedPressButtonViewModifier(cornerRadius: cornerRadius, color: color))
    }
}

struct StrokedPressButtonViewModifier: ViewModifier {
    @State private var offsetY: CGFloat = 0.0
    @State private var isPressed: Bool = false
    
    let cornerRadius: CGFloat
    let color: Color
    
    private let offsetYAxis: CGFloat = 3
    
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
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .foregroundStyle(color)
                    .offset(y: offsetYAxis)
            }
            .sensoryFeedback(.selection, trigger: isPressed)
    }
}

#Preview {
    VStack {
        StrokedPressButton("Sign in with Apple", alignment: .trailing) {
            
        }
        .padding(32)
        
        StrokedPressButton(cornerRadius: 20) {
            HStack {
                Text("label")
                    .font(.grotesk(size: 20, weight: .semibold))
                    .foregroundStyle(Color.primary)
                
                let checkSize: CGFloat = 32.0
                
                CheckmarkShape(trimEnd: 1.0)
                    .trim(from: 0.0, to: 1.0)
                    .stroke(
                        .green,
                        style: StrokeStyle(
                            lineWidth: checkSize / 12,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .frame(square: checkSize / 2.0)
            }
        } action: {
            
        }
        .padding(32)

    }
}

