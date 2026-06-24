//
//  OBSeventeenView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 13/05/25.
//

import SwiftUI

struct OBSeventeenView: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    @State private var progress: CGFloat = 0.0
    
    @State private var showEmojiOne: Bool = false
    @State private var showEmojiTwo: Bool = false
    
    var body: some View {
        VStack {
            LineChart()
                .offset(y: 22)
        }
        .background {
            ZStack {
                Rectangle()
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.pink, Color.primaryBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .blur(radius: 64)
                    .opacity(showEmojiOne ? 0.15 : 0.0)
                
                LinearGradient(
                    colors: [.clear, Color(UIColor.systemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .top) {
            VStack(spacing: 14) {
                Text("Proven Results".uppercased())
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .kerning(1.0)

                Text("Backed by Real Data and Research")
                    .font(.system(size: 30).weight(.bold))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 48)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .center, spacing: 32) {
                VStack(spacing: 18) {
//                    Text("Backed by Research".uppercased())
//                        .font(.footnote.weight(.semibold))
//                        .foregroundStyle(.secondary)
//                        .kerning(1.0)
                    
                    ScrollView(.horizontal) {
                        HStack(spacing: 10) {
                            HStack(spacing: 12) {
                                Circle()
                                    .frame(square: 48)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Stanford University")
                                    Text("Cognitive Behavioural Therapy")
                                        .lineLimit(1)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "link")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal)
                            .padding(.vertical)
                            .background {
                                RoundedRectangle(cornerRadius: 15, style: .continuous)
                                    .foregroundStyle(.thinMaterial)
                            }
                            .containerRelativeFrame(.horizontal, count: 1, spacing: 10)
                            
                            HStack(spacing: 12) {
                                Circle()
                                    .frame(square: 48)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Stanford University")
                                    Text("Cognitive Behavioural Therapy")
                                        .lineLimit(1)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()
                                
                                Image(systemName: "link")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal)
                            .padding(.vertical)
                            .background {
                                RoundedRectangle(cornerRadius: 15, style: .continuous)
                                    .foregroundStyle(.thinMaterial)
                            }
                            .containerRelativeFrame(.horizontal, count: 1, spacing: 10)
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollIndicators(.hidden)
                    .contentMargins(.horizontal, 32, for: .scrollContent)
                }

//                VStack(spacing: 14) {
//                    Text("Benefits".uppercased())
//                        .font(.footnote.weight(.semibold))
//                        .foregroundStyle(.secondary)
//                        .kerning(1.0)
//
//                    Text("Rewire your brain")
//                        .font(.system(size: 30).weight(.bold))
//                        .multilineTextAlignment(.center)
//
//                    Text("Reducing screen time has been linked to better sleep, more energy, and increased productivity.")
//                        .font(.subheadline.weight(.medium))
//                        .foregroundStyle(.secondary)
//                        .multilineTextAlignment(.center)
//                        .lineSpacing(2.0)
//                }
                
                Button("Continue", action: action)
                    .padding(.horizontal)
                    .padding([.bottom, .horizontal])
                
            }
        }
        .onAppear(perform: setup)
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.15) {
            withAnimation(.timingCurve(0.4, 0.8, 0.2, 0.8, duration: 1.0)) {
                progress = 1.0
            }
            
            SleepTask.sleep(seconds: 0.1) {
                withAnimation(.bouncy(duration: 0.45, extraBounce: 0.1)) {
                    showEmojiOne = true
                }
            }
            
            SleepTask.sleep(seconds: 0.5) {
                withAnimation(.bouncy(duration: 0.45, extraBounce: 0.1)) {
                    showEmojiTwo = true
                }
            }
        }
    }
    
    private func action() {
        vm.goToNextStep(step: 18)
//        vm.showSetupStep = true
    }
    
    @ViewBuilder
    private func LineChart() -> some View {
        Rectangle()
            .foregroundStyle(
                .linearGradient(
                    colors: [.pink, Color.primaryBlue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .mask {
                LineChartPath()
                    .trim(from: 0, to: progress)
                    .stroke(Color.primaryBlue, lineWidth: 4)
                    .frame(height: 180)
                    .overlay(alignment: .topLeading) {
                        VStack(spacing: 20) {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(lineWidth: 2.0)
                                .frame(square: 50)
                                .opacity(0.5)
                            
                            Circle()
                                .frame(square: 14)
                                .overlay(alignment: .top) {
                                    VStack {
                                        ForEach(0..<10) { index in
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .opacity(showEmojiTwo ? 1 - (Double(index) * 0.1) : 0)
                                                .animation(.smooth.delay(Double(index) * 0.1), value: showEmojiTwo)
                                        }
                                    }
                                    .frame(width: 2, height: 200)
                                }
                        }
                        .offset(x: 40.0, y: -74)
                        .scaleEffect(showEmojiOne ? 1.0 : 0.6)
                        .opacity(showEmojiOne ? 1.0 : 0.0)
                    }
                    .overlay(alignment: .bottomTrailing) {
                        VStack(spacing: 20) {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(lineWidth: 2.0)
                                .frame(square: 50)
                                .opacity(0.5)
                            
                            ZStack {
                                Circle()
                                    .frame(square: 18)
                                    .blur(radius: 16)
                                
                                Circle()
                                    .frame(square: 18)
                            }
                        }
                        .offset(x: -40.0, y: 4)
                        .scaleEffect(showEmojiTwo ? 1.0 : 0.6)
                        .opacity(showEmojiTwo ? 1.0 : 0.0)
                    }
            }
            .overlay(alignment: .leading) {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .foregroundStyle(.secondary.opacity(0.15))
                        .frame(square: 50)
                        .overlay {
                            if showEmojiOne {
                                Text("😣")
                                    .font(.system(size: 33))
                            }
                        }
                        .offset(x: 40.0, y: -139)
                        .scaleEffect(showEmojiOne ? 1.0 : 0.6)
                        .opacity(showEmojiOne ? 1.0 : 0.0)
                    
                    Text("Overwhelmed, stressed, and drained.")
                        .font(.footnote.weight(.medium))
                        .offset(x: 105.0, y: -139)
                        .scaleEffect(showEmojiOne ? 1.0 : 0.6)
                        .opacity(showEmojiOne ? 1.0 : 0.0)
                        .frame(width: 100)
                    
                    Text("Before".uppercased())
                        .foregroundStyle(.secondary)
                        .font(.footnote.weight(.medium))
                        .offset(x: 40, y: -185)
                        .scaleEffect(showEmojiOne ? 1.0 : 0.6)
                        .opacity(showEmojiOne ? 1.0 : 0.0)
                }
            }
            .overlay(alignment: .trailing) {
                ZStack(alignment: .trailing) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .foregroundStyle(.secondary.opacity(0.15))
                        .frame(square: 50)
                        .overlay {
                            if showEmojiTwo {
                                Text("😌")
                                    .font(.system(size: 33))
                            }
                        }
                        .offset(x: -40.0, y: 31)
                        .scaleEffect(showEmojiTwo ? 1.0 : 0.6)
                        .opacity(showEmojiTwo ? 1.0 : 0.0)
                    
                    Text("Calm, focused, and energized.")
                        .font(.footnote.weight(.medium))
                        .offset(x: -20.0, y: 130)
                        .scaleEffect(showEmojiTwo ? 1.0 : 0.6)
                        .opacity(showEmojiTwo ? 1.0 : 0.0)
                        .frame(width: 100)
                        .multilineTextAlignment(.trailing)
                    
                    Text("Today".uppercased())
                        .foregroundStyle(.secondary)
                        .font(.footnote.weight(.medium))
                        .offset(x: -45.0, y: -15)
                        .scaleEffect(showEmojiTwo ? 1.0 : 0.6)
                        .opacity(showEmojiTwo ? 1.0 : 0.0)
                }
            }
            .background {
                Rectangle()
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.pink.opacity(0.2), Color.primaryBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .mask {
                        LineChartPath()
                            .trim(from: 0, to: progress)
                            .stroke(Color.primaryBlue, lineWidth: 6)
                            .frame(height: 180)
                            .blur(radius: 10)
                    }
            }
    }
}

#Preview {
    OBSeventeenView()
        .environmentObject(OBUserViewModel())
}

struct LineChartPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.0007 * width, y: 0.00549 * height))
        path.addCurve(
            to: CGPoint(x: 0.99965 * width, y: 0.99687 * height),
            control1: CGPoint(x: 0.63112 * width, y: -0.0431 * height),
            control2: CGPoint(
                x: 0.32308 * width,
                y: 0.99687 * height
            )
        )
        return path
    }
}
