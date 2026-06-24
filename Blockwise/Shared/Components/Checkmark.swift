//
//  Checkmark.swift
//  Blockwise
//
//  Created by Ivan Sanna on 19/03/25.
//

import SwiftUI

/// A view displaying an animated checkmark within a circular outline, suitable for indicating a selection or completion state.
///
/// The `Checkmark` view can be customized with size and color, and it animates its appearance based on a bound boolean trigger.
///
/// - Parameters:
///   - size: The size of the checkmark circle.
///   - trigger: A binding to a boolean value that triggers the checkmark animation when toggled.
///   - primary: An optional primary color for the checkmark. If not provided, defaults to the system background color.
///
/// - Usage:
/// ```swift
/// struct ContentView: View {
///     @State private var isChecked = false
///
///     var body: some View {
///         Checkmark(size: 40, trigger: $isChecked, primary: .green)
///             .onTapGesture {
///                 isChecked.toggle()
///             }
///     }
/// }
/// ```
///
struct Checkmark: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    /// The diameter of the checkmark's circular frame.
    let size: CGFloat
    
    /// A binding to a boolean that triggers the checkmark's animation.
    @Binding var trigger: Bool
    
    /// Optional color for the checkmark stroke. If nil, defaults to system background color.
    let checkmarkColor: Color?
    
    let backgroundColor: Color?
    
    /// Controls the length of the checkmark stroke during animation.
    @State private var trimEnd: CGFloat = 0.0
    
    init(size: CGFloat, trigger: Binding<Bool>, checkmarkColor: Color? = nil, backgroundColor: Color? = nil) {
        self.size = size
        self._trigger = trigger
        self.checkmarkColor = checkmarkColor
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        ZStack {
            // Circle outline with dynamic opacity and stroke width based on `trigger`
            Circle()
                .stroke(lineWidth: trigger ? size : size / 5)
                .frame(square: size)
                .opacity(trigger ? 1.0 : 0.1)
                .foregroundStyle(trigger ? backgroundColor ?? .primary : .primary)
            
            // Checkmark path with optional color, size, and animation based on `trigger`
            CheckmarkShape(trimEnd: 1.0)
                .trim(from: 0.0, to: trimEnd)
                .stroke(
                    checkmarkColor ?? Color(UIColor.systemBackground),
                    style: StrokeStyle(
                        lineWidth: size / 7.5,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .frame(square: size / 2.0)
                .scaleEffect(trigger ? 1.0 : 0.5)
                .onChange(of: trigger) {
                    trimEnd = trigger ? 1.0 : 0.0
                }
                .opacity(trimEnd)
        }
        .animation(.snappy(duration: 0.25, extraBounce: 0.10), value: trigger)
        .animation(.snappy(duration: 0.35, extraBounce: 0.10).delay(0.05), value: trimEnd)
        .clipShape(Circle())
        .checkmarkAnimation(trigger)
    }
}

// MARK: - Preview
#Preview {
    CheckmarkPreview()
}

/// A preview view demonstrating the `Checkmark` component.
private struct CheckmarkPreview: View {
    @State private var trigger: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            Checkmark(
                size: 32,
                trigger: $trigger,
                checkmarkColor: .white,
                backgroundColor: Color.primaryBlue
            )
            
            Button("Toggle") {
                trigger.toggle()
            }
        }
        .padding()
    }
}

// MARK: - Checkmark Shape
/// A custom shape representing a checkmark.
struct CheckmarkShape: Shape {
    /// The end point of the trim for the checkmark path.
    var trimEnd: CGFloat
    
    var animatableData: CGFloat {
        get { trimEnd }
        set { trimEnd = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Define the checkmark path
        path.move(to: CGPoint(x: rect.width * 0.1, y: rect.height * 0.5))
        path.addLine(to: CGPoint(x: rect.width * 0.4, y: rect.height * 0.8))
        path.addLine(to: CGPoint(x: rect.width * 0.9, y: rect.height * 0.2))
        
        return path
    }
}

// MARK: - Checkmark Animation
private extension View {
    /// Applies a keyframe animation to scale the view based on the `trigger` state.
    ///
    /// - Parameter trigger: A binding to the trigger state that starts the animation.
    /// - Returns: A modified view with the applied keyframe animation.
    func checkmarkAnimation(_ trigger: Bool) -> some View {
        self
            .keyframeAnimator(initialValue: CheckKeyframe(), trigger: trigger) { view, frame in
                view
                    .scaleEffect(trigger ? frame.scale : 1.0)
            } keyframes: { frame in
                KeyframeTrack(\.scale) {
                    CubicKeyframe(1.0, duration: 0.05)
                    CubicKeyframe(1.2, duration: 0.15)
                    SpringKeyframe(1.0, duration: 0.30, spring: .snappy(duration: 0.35, extraBounce: 0.40))
                }
            }
    }
}

/// A data structure representing keyframes for checkmark animation.
struct CheckKeyframe {
    var scale: CGFloat = 1.0
}
