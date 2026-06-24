//
//  TimeSlider.swift
//  Blockwise
//
//  Created by Ivan Sanna on 17/12/25.
//

import SwiftUI

struct TimeSlider: View {
    @Binding var value: Int

    let range: ClosedRange<Int>
    let stepWidth: CGFloat
    let foreground: Color

    // Internal state
    @State private var tempValue: Int
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    private let elasticFactor: CGFloat = 0.65

    init(
        value: Binding<Int>,
        range: ClosedRange<Int>,
        stepWidth: CGFloat = 20,
        foreground: Color = .white
    ) {
        self._value = value
        self.range = range
        self.stepWidth = stepWidth
        self.foreground = foreground
        self._tempValue = State(initialValue: value.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 10) {
            VStack(spacing: 0) {
                Text("\(tempValue)")
                    .font(.grotesk(size: 64, weight: .semibold))
                    .contentTransition(.numericText(value: Double(tempValue)))
                    .animation(.smooth, value: tempValue)
                    .foregroundStyle(.white)
                
                Text("MINS")
                    .font(.grotesk(.subheadline, weight: .semibold))
                    .kerning(1.5)
                    .foregroundStyle(.white)
            }

            GeometryReader { geo in
                let center = geo.size.width / 2

                ForEach(range, id: \.self) { tick in
                    let x = center
                        + CGFloat(tick - min(range.upperBound, value)) * stepWidth
                        + dragOffset

                    RoundedRectangle(cornerRadius: 10)
                        .fill(tick == tempValue ? foreground : foreground.opacity(0.35))
                        .frame(
                            width: tick == tempValue ? 6 : tick % 5 == 0 ? 3 : 2,
                            height: tick % 5 == 0 ? 14 : 10
                        )
                        .scaleEffect(
                            y: tick == tempValue ? 2.5 : 1,
                            anchor: .bottom
                        )
                        .opacity(isDragging && tick != tempValue ? 0.85 : 1)
                        .position(x: x, y: geo.size.height / 2)
                }
            }
            .contentShape(Rectangle())
            .gesture(dragGesture)
            .frame(height: 128)
        }
        .sensoryFeedback(.selection, trigger: tempValue)
    }

    // MARK: - Gesture

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { gesture in
                guard value <= range.upperBound else { return }

                withAnimation(.snappy(duration: 0.25)) {
                    isDragging = true
                }

                let rawOffset = gesture.translation.width * elasticFactor
                let offsetSteps = rawOffset / stepWidth
                var projected = CGFloat(value) - offsetSteps

                let lower = CGFloat(range.lowerBound)
                let upper = CGFloat(range.upperBound)

                if projected < lower {
                    let overshoot = lower - projected
                    projected = lower - log(overshoot + 1) * 0.5
                } else if projected > upper {
                    let overshoot = projected - upper
                    projected = upper + log(overshoot + 1) * 0.5
                }

                dragOffset = (CGFloat(value) - projected) * stepWidth
                tempValue = Int(projected.rounded()).clamped(to: range)
            }
            .onEnded { gesture in
                withAnimation(.snappy(duration: 0.25)) {
                    isDragging = false
                }

                let velocity = gesture.velocity.width
                let offsetSteps = (gesture.translation.width * elasticFactor) / stepWidth
                let projected = CGFloat(value) - offsetSteps
                let final = Int(projected.rounded()).clamped(to: range)

                withAnimation(.interpolatingSpring(stiffness: 120, damping: 20)) {
                    if abs(velocity) > 1250 {
                        value = roundToNearestFive(final)
                    } else {
                        value = final
                    }
                    tempValue = value
                    dragOffset = 0
                }
            }
    }

    // MARK: - Helpers

    private func roundToNearestFive(_ value: Int) -> Int {
        max(1, Int((Double(value) / 5).rounded() * 5))
    }
}


#Preview {
    TimeSliderPreview()
}

private struct TimeSliderPreview: View {
    @State private var value: Int = 5
    
    var body: some View {
                    
        TimeSlider(value: $value, range: 1...100)
            
    }
}
