//
//  OB4_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 18/01/26.
//

import SwiftUI
//import SDWebImageSwiftUI

struct OB4_V2: View {
    @EnvironmentObject var vm: OBVM_V2

    @State private var appearAnimation: Bool = false
    @State private var checkmark1: Bool = false
    @State private var checkmark2: Bool = false
    
    let question: String = "We help you build real and lasting healthy habits"
    let subheadline: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 32) {
                Space(height: 18)
                
                VStack(alignment: .center, spacing: 10) {
                    
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
                    Text("\(AppConfiguration.name)")
                        .font(.grotesk(size: 14, weight: .semibold))
                        .foregroundColor(.green)
                    
                    SteadyProgressChart(animate: appearAnimation)
                        .frame(height: 120)
                        .padding(.horizontal, 4)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                            .font(.system(size: 12, weight: .semibold))
                        
                        Text("Sustainable")
                            .font(.grotesk(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.green.opacity(0.05))
                )
                .padding(.horizontal, 8)
                .opacity(appearAnimation ? 1 : 0)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth(duration: 1.0).delay(0.1), value: appearAnimation)
                
                VStack(alignment: .leading, spacing: 44) {
                    HStack(spacing: 24) {
//                        Checkmark(
//                            size: 36,
//                            trigger: $checkmark1,
//                            backgroundColor: .green
//                        )
                        
                        Image(systemName: "1.circle.fill")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(.white, Color.primaryOrange)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("With \(AppConfiguration.name), you **don't need to quit** your phone.")
                                .font(.grotesk(size: 17, weight: .regular))
                        }
                    }
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth, value: appearAnimation)
                    
                    HStack(spacing: 24) {
//                        Checkmark(
//                            size: 36,
//                            trigger: $checkmark2,
//                            backgroundColor: .green
//                        )
                        
                        Image(systemName: "2.circle.fill")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(.white, Color.primaryOrange)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("We help you build a **healthier and more intentional** relationship with your phone.")
                                .font(.grotesk(size: 17, weight: .regular))
                        }
                    }
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.1), value: appearAnimation)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

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
        
        SleepTask.sleep(seconds: 0.2) {
            checkmark1 = true
        }

        SleepTask.sleep(seconds: 0.3) {
            checkmark2 = true
        }

    }
    
    private func action() {
        vm.nextPage(progress: 0.5)
        
        // Mixpanel
        AnalyticsService.shared.track("OBV2 > We help you...")
    }
}

#Preview {
    OB4_V2()
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

// MARK: - Steady Progress Chart (Blockwise)
struct SteadyProgressChart: View {
    let animate: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            // Calculate week positions
            let week1X: CGFloat = 0.05
            let week1Y: CGFloat = 0.8 - (0.6 * (1 - exp(-2.5 * week1X)))
            
            let week4X: CGFloat = 0.95
            let week4Y: CGFloat = 0.8 - (0.6 * (1 - exp(-2.5 * week4X)))
            
            ZStack(alignment: .topLeading) {
                // Main curve
                Path { path in
                    // Generate exponential curve points
                    let numPoints = 50
                    var points: [(x: CGFloat, y: CGFloat)] = []
                    
                    for i in 0...numPoints {
                        let x = CGFloat(i) / CGFloat(numPoints)
                        // Exponential decay formula: starts high, ends low
                        let y = 0.8 - (0.6 * (1 - exp(-2.5 * x)))
                        points.append((x, y))
                    }
                    
                    path.move(to: CGPoint(x: 0, y: height * points[0].y))
                    
                    // Create smooth curve through all points
                    for i in 1..<points.count {
                        let current = points[i]
                        let previous = points[i - 1]
                        
                        let distance = current.x - previous.x
                        
                        let controlPoint1 = CGPoint(
                            x: width * (previous.x + distance * 0.33),
                            y: height * previous.y
                        )
                        
                        let controlPoint2 = CGPoint(
                            x: width * (current.x - distance * 0.33),
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
                .stroke(Color.green, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                
                // Week 1 marker
                if animate {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .position(x: width * week1X, y: height * week1Y)
                        .opacity(animate ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.8), value: animate)
                    
                    Text("Week 1")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.green)
                        .position(x: width * week1X, y: height * week1Y + 18)
                        .opacity(animate ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.8), value: animate)
                }
                
                // Week 4 marker
                if animate {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .position(x: width * week4X, y: height * week4Y)
                        .opacity(animate ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(1.0), value: animate)
                    
                    Text("Week 4")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.green)
                        .position(x: width * week4X, y: height * week4Y + 18)
                        .opacity(animate ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(1.0), value: animate)
                }
            }
        }
    }
}
