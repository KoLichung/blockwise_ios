//
//  OB3_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 18/01/26.
//

import SwiftUI

struct OB3_V2: View {
    @EnvironmentObject var vm: OBVM_V2
    
    @State private var appearAnimation: Bool = false
    
    let question: String = "Most app blockers can produce a yo-yo effect"
    let subheadline: String = "Research on habit formation shows that extreme restrictions can trigger cycles of control and relapse, instead of lasting change."
        
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 32) {
                Space(height: 18)
                
                VStack(alignment: .center, spacing: 14) {
                    
                    if vm.hasTriedBefore {
                        Text("It's not your fault".uppercased())
                            .font(.grotesk(size: 14, weight: .semibold))
                            .foregroundStyle(Color.primaryOrange)
                            .kerning(1.5)
                    }
                    
                    Text(question)
                        .font(.grotesk(size: 26, weight: .semibold))
                        .lineSpacing(2.0)
                        .multilineTextAlignment(.center)

                }
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth, value: appearAnimation)
                .frame(maxWidth: .infinity, alignment: .center)
                
                VStack(spacing: 12) {
                    Text("Most App Blockers")
                        .font(.grotesk(size: 14, weight: .semibold))
                        .foregroundColor(.red)
                    
                    YoYoChart(animate: appearAnimation)
                        .frame(height: 120)
                        .padding(.horizontal, 4)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                            .font(.system(size: 12, weight: .semibold))
                        
                        Text("Unsustainable")
                            .font(.grotesk(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.red.opacity(0.05))
                )
                .padding(.horizontal, 8)
                .opacity(appearAnimation ? 1 : 0)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth(duration: 1.0).delay(0.1), value: appearAnimation)

                if !subheadline.isEmpty {
                    Text(subheadline)
                        .foregroundStyle(.secondary)
                        .font(.grotesk(.body, weight: .regular))
                        .lineSpacing(4.0)
                        .multilineTextAlignment(.center)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 32)
                        .scaleEffect(appearAnimation ? 1 : 0.95)
                        .animation(.smooth.delay(0.2), value: appearAnimation)
                }
                
            }
            .padding(32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .safeAreaInset(edge: .bottom) {
            GlassButton("Continue") {
                action()
            }
            .padding(.horizontal, 32)
            .padding()
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.3), value: appearAnimation)
            .background {
                LinearGradient(
                    colors: [.clear, Color(UIColor.systemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
        }
        .onAppear(perform: setup)

    }
    
    // MARK: - Functions
    private func setup() {
        SleepTask.sleep(seconds: 0.1) {
            appearAnimation = true
        }
    }
        
    private func action() {
        vm.nextPage(progress: 0.4)
        
        // Mixpanel
        AnalyticsService.shared.track("OBV2 > Most app...")
    }
    
}

#Preview {
    OB3_V2()
        .environmentObject(OBVM_V2())
        .overlay(alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.secondary.opacity(0.15))
                .frame(height: 12)
                .padding(.vertical, 10)
                .padding(.horizontal, 32)
                .frame(height: 32)
        }
}


// MARK: - Yo-Yo Chart (App Blockers)
struct YoYoChart: View {
    let animate: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            Path { path in
                let points: [(x: CGFloat, y: CGFloat)] = [
                    (0, 0.7),
                    (0.15, 0.2),  // Drop
                    (0.3, 0.65),  // Spike back up
                    (0.45, 0.25), // Drop again
                    (0.6, 0.7),   // Spike back up
                    (0.75, 0.3),  // Drop
                    (0.9, 0.65),  // Spike back up
                    (1.0, 0.7)
                ]
                
                path.move(to: CGPoint(x: 0, y: height * points[0].y))
                
                // Use smooth cubic curves for wave-like effect
                for i in 1..<points.count {
                    let current = points[i]
                    let previous = points[i - 1]
                    
                    // Control points for smooth wave
                    let distance = current.x - previous.x
                    
                    let controlPoint1 = CGPoint(
                        x: width * (previous.x + distance * 0.4),
                        y: height * previous.y
                    )
                    
                    let controlPoint2 = CGPoint(
                        x: width * (current.x - distance * 0.4),
                        y: height * current.y
                    )
                    
                    path.addCurve(
                        to: CGPoint(x: width * current.x, y: height * current.y),
                        control1: controlPoint1,
                        control2: controlPoint2
                    )
                }
            }
            .trim(from: 0, to: animate ? 1 : 0)
            .stroke(Color.red, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            
            // Add dots at peaks and valleys
            if animate {
                ForEach([0.15, 0.3, 0.45, 0.6, 0.75, 0.9], id: \.self) { x in
                    let y: CGFloat = {
                        switch x {
                        case 0.15: return 0.2
                        case 0.3: return 0.65
                        case 0.45: return 0.25
                        case 0.6: return 0.7
                        case 0.75: return 0.3
                        case 0.9: return 0.65
                        default: return 0.5
                        }
                    }()
                    
                    Circle()
                        .fill(Color.red)
                        .frame(width: 6, height: 6)
                        .position(x: width * x, y: height * y)
                }
            }
        }
    }
}
