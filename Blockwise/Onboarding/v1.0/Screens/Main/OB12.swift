//
//  OB12.swift
//  Blockwise
//
//  Created by Ivan Sanna on 23/11/25.
//

import SwiftUI

struct OB12: View {
    @EnvironmentObject var vm: OBVM
    @State private var appearAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            
            VStack(spacing: 14) {
                Text("Set your daily\nScreen Time limit")
                    .font(.grotesk(.title, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2.0)
                
                Text("Don't worry, you can change it later")
                    .font(.grotesk(.subheadline, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .lineSpacing(4.0)
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth, value: appearAnimation)
                        
            Picker("", selection: selectedMinutesBinding) {
                ForEach(Array(stride(from: minMinutes, through: maxMinutes, by: stepMinutes)), id: \.self) { minutes in
                    Text(TimeFormatter.display(TimeInterval(minutes * 60), style: .short))
                        .font(.grotesk(size: 19.0, weight: .regular))
                        .tag(minutes)
                }
            }
            .pickerStyle(.wheel)
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.1), value: appearAnimation)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 32) {
                HStack(spacing: 10) {
                    Bubble(direction: .right,
                           fill: Color.primaryBlue.opacity(0.15),
                           stroke: Color.primaryBlue.opacity(0.5)) {
                        Text("We suggest between **1 hour** and **3 hours** to start.")
                            .font(.grotesk(.subheadline, weight: .medium))
                            .foregroundStyle(Color.primaryBlue)
                    }

//                    Image(.mascotteWriting)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(square: 128)
                }
                .padding(.horizontal, -16)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.25), value: appearAnimation)
                
                GlassButton("Continue") {
                    action()
                }
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.3), value: appearAnimation)
            }
            .padding(.horizontal, 32)
            .padding()
        }
        .onAppear(perform: setup)
    }
    
    // MARK: - More properties
    // Minutes range (upper bound is exclusive)
    let range: Range<Int> = 15..<(6 * 60)
    // Derived bounds in minutes
    private var minMinutes: Int { range.lowerBound }
    private var maxMinutes: Int { range.upperBound - 1 }
    // Snapping step in minutes (5-minute increments)
    private let stepMinutes: Int = 5
    
    // Selection binding that always snaps/clamps to 5-minute steps within bounds
    private var selectedMinutesBinding: Binding<Int> {
        Binding<Int>(
            get: {
                let currentMinutes = Int(round(vm.screenTimeGoal / 60.0))
                let clamped = min(max(currentMinutes, minMinutes), maxMinutes)
                return ((clamped + stepMinutes / 2) / stepMinutes) * stepMinutes
            },
            set: { newValue in
                let clamped = min(max(newValue, minMinutes), maxMinutes)
                let snapped = ((clamped + stepMinutes / 2) / stepMinutes) * stepMinutes
                vm.screenTimeGoal = TimeInterval(snapped * 60)
            }
        )
    }
    
    // MARK: - Functions
    private func setup() {
        // Snap any pre-existing value to the nearest step within bounds
        let currentMinutes = Int(round(vm.screenTimeGoal / 60.0))
        let clampedMinutes = min(max(currentMinutes, minMinutes), maxMinutes)
        let roundedToStep = ((clampedMinutes + stepMinutes / 2) / stepMinutes) * stepMinutes
        vm.screenTimeGoal = TimeInterval(roundedToStep * 60)
        
        SleepTask.sleep(seconds: 0.1) {
            withAnimation {
                appearAnimation = true
            }
        }
    }
    
    private func action() {        
        vm.nextPage(progressBar: 0.7)
        
        // Mixpanel
        AnalyticsService.shared.track("Onboarding > Set Goal")
    }
}

#Preview {
    OB12()
        .environmentObject(OBVM())
}

// MARK: - More components (Chat Bubble)

struct ChatBubble: Shape {
    enum Direction { case left, right }
    
    var direction: Direction = .right
    var cornerRadius: CGFloat = 12
    var tailSize: CGSize = CGSize(width: 16, height: 18)
    var tailOffset: CGFloat = 0 // + moves tail downward, - upward
    
    func path(in rect: CGRect) -> Path {
        // The main rounded-rect area (we reserve space for the tail on its side)
        let tailW = tailSize.width
        let tailH = tailSize.height
        
        let bubbleRect: CGRect = {
            switch direction {
            case .right:
                return CGRect(x: rect.minX,
                              y: rect.minY,
                              width: rect.width - tailW,
                              height: rect.height)
            case .left:
                return CGRect(x: rect.minX + tailW,
                              y: rect.minY,
                              width: rect.width - tailW,
                              height: rect.height)
            }
        }()
        
        let r = min(cornerRadius, min(bubbleRect.width, bubbleRect.height) / 2)
        let minX = bubbleRect.minX
        let maxX = bubbleRect.maxX
        let minY = bubbleRect.minY
        let maxY = bubbleRect.maxY
        let midY = bubbleRect.midY + tailOffset
        
        let yStart = max(minY + r, min(maxY - r, midY - tailH * 0.5))
        let yEnd   = max(minY + r, min(maxY - r, midY + tailH * 0.5))
        
        var p = Path()
        
        switch direction {
        case .right:
            // Start at top-left corner
            p.move(to: CGPoint(x: minX + r, y: minY))
            // Top edge to top-right corner
            p.addLine(to: CGPoint(x: maxX - r, y: minY))
            // Top-right corner
            p.addQuadCurve(to: CGPoint(x: maxX, y: minY + r),
                           control: CGPoint(x: maxX, y: minY))
            // Right edge down to start of tail
            p.addLine(to: CGPoint(x: maxX, y: yStart))
            // Tail outward and back
            p.addQuadCurve(to: CGPoint(x: maxX + tailW, y: midY),
                           control: CGPoint(x: maxX, y: midY - tailH * 0.15))
            p.addQuadCurve(to: CGPoint(x: maxX, y: yEnd),
                           control: CGPoint(x: maxX + tailW * 0.7, y: midY + tailH * 0.25))
            // Continue right edge to bottom-right corner
            p.addLine(to: CGPoint(x: maxX, y: maxY - r))
            // Bottom-right corner
            p.addQuadCurve(to: CGPoint(x: maxX - r, y: maxY),
                           control: CGPoint(x: maxX, y: maxY))
            // Bottom edge
            p.addLine(to: CGPoint(x: minX + r, y: maxY))
            // Bottom-left corner
            p.addQuadCurve(to: CGPoint(x: minX, y: maxY - r),
                           control: CGPoint(x: minX, y: maxY))
            // Left edge
            p.addLine(to: CGPoint(x: minX, y: minY + r))
            // Top-left corner
            p.addQuadCurve(to: CGPoint(x: minX + r, y: minY),
                           control: CGPoint(x: minX, y: minY))
            p.closeSubpath()
            
        case .left:
            // Start at top-left corner (of the bubbleRect)
            p.move(to: CGPoint(x: minX + r, y: minY))
            // Top edge to top-right corner
            p.addLine(to: CGPoint(x: maxX - r, y: minY))
            // Top-right corner
            p.addQuadCurve(to: CGPoint(x: maxX, y: minY + r),
                           control: CGPoint(x: maxX, y: minY))
            // Right edge
            p.addLine(to: CGPoint(x: maxX, y: maxY - r))
            // Bottom-right corner
            p.addQuadCurve(to: CGPoint(x: maxX - r, y: maxY),
                           control: CGPoint(x: maxX, y: maxY))
            // Bottom edge
            p.addLine(to: CGPoint(x: minX + r, y: maxY))
            // Bottom-left corner
            p.addQuadCurve(to: CGPoint(x: minX, y: maxY - r),
                           control: CGPoint(x: minX, y: maxY))
            // Left edge up to tail start
            p.addLine(to: CGPoint(x: minX, y: yEnd))
            // Tail outward and back (to the left)
            p.addQuadCurve(to: CGPoint(x: minX - tailW, y: midY),
                           control: CGPoint(x: minX, y: midY + tailH * 0.25))
            p.addQuadCurve(to: CGPoint(x: minX, y: yStart),
                           control: CGPoint(x: minX - tailW * 0.7, y: midY - tailH * 0.15))
            // Continue to top-left corner
            p.addLine(to: CGPoint(x: minX, y: minY + r))
            p.addQuadCurve(to: CGPoint(x: minX + r, y: minY),
                           control: CGPoint(x: minX, y: minY))
            p.closeSubpath()
        }
        
        return p
    }
}

// Convenience wrapper that applies the fill and stroke and fixes padding on the tail side
struct Bubble<Content: View>: View {
    var direction: ChatBubble.Direction = .right
    var fill: Color
    var stroke: Color
    var lineWidth: CGFloat = 2
    var cornerRadius: CGFloat = 12
    var tailSize: CGSize = CGSize(width: 16, height: 18)
    var tailOffset: CGFloat = 0
    var basePadding: CGFloat = 14
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        let extra = tailSize.width
        let insets = EdgeInsets(
            top: basePadding,
            leading: basePadding + (direction == .left ? extra : 0),
            bottom: basePadding,
            trailing: basePadding + (direction == .right ? extra : 0)
        )
        
        content()
            .padding(insets)
            .background {
                ChatBubble(direction: direction,
                           cornerRadius: cornerRadius,
                           tailSize: tailSize,
                           tailOffset: tailOffset)
                    .fill(fill)
            }
            .overlay {
                ChatBubble(direction: direction,
                           cornerRadius: cornerRadius,
                           tailSize: tailSize,
                           tailOffset: tailOffset)
                    .stroke(stroke, lineWidth: lineWidth)
            }
    }
}

