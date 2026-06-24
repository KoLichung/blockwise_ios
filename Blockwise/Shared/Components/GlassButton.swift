//
//  GlassButton.swift
//  Blockwise
//
//  Created by Ivan Sanna on 23/11/25.
//

import SwiftUI

struct GlassButton: View {
    let action: () -> Void
    
    let label: String
    let labelColor: Color
    let color: Color
    private let customLabel: AnyView?
    
    init(_ label: String, labelColor: Color = Color(UIColor.systemBackground), background: Color = .fillAccent, action: @escaping () -> Void) {
        self.action = action
        self.label = label
        self.labelColor = labelColor
        self.color = background
        self.customLabel = nil
    }
    
    // Fully custom label initializer
    init(action: @escaping () -> Void, background: Color = .fillAccent, @ViewBuilder label: () -> some View) {
        self.action = action
        self.label = "" // Unused when custom label is provided
        self.labelColor = .clear // Unused when custom label is provided
        self.color = background
        self.customLabel = AnyView(label())
    }

    var body: some View {
        if #available(iOS 26, *) {
            Button {
                action()
                Haptics.feedback(style: .light)
            } label: {
                if let customLabel {
                    customLabel
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                } else {
                    Text(label)
                        .font(.grotesk(size: 20, weight: .semibold))
                        .foregroundStyle(labelColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                }
            }
            .buttonStyle(.glassProminent)
            .tint(color)
        } else {
            Button {
                action()
                Haptics.feedback(style: .light)
            } label: {
                if let customLabel {
                    customLabel
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                } else {
                    Text(label)
                        .font(.grotesk(size: 20, weight: .semibold))
                        .foregroundStyle(labelColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                }
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .tint(color)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        GlassButton("Hello") {
            // Action
        }
        .padding(.horizontal, 32)
        
        GlassButton {
            //
        } label: {
            Text("hee")
        }
        
        GlassButton(action: {
            // Action
        }, background: .primaryBlue) {
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                Text("Custom Label")
                    .font(.grotesk(size: 20, weight: .semibold))
            }
            .foregroundStyle(.white)
        }
        .padding(.horizontal, 32)
    }
    .padding(.vertical, 24)
}
