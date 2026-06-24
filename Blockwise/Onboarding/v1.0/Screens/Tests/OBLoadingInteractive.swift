//
//  OBLoadingInteractive.swift
//  Blockwise
//
//  Created by Ivan Sanna on 01/01/26.
//

import SwiftUI

struct OBLoadingInteractive: View {
    @EnvironmentObject var vm: OBVM
    @State private var appearAnimation: Bool = false
    
    // Progress values for the bars (0...1)
    @State private var progressOne: CGFloat = 0.0
    @State private var progressTwo: CGFloat = 0.0
    @State private var progressThree: CGFloat = 0.0
    
    // Percentage labels that tick 1-by-1 via Timer
    @State private var percentOne: Int = 0
    @State private var percentTwo: Int = 0
    @State private var percentThree: Int = 0
    
    // Questions visibility
    @State private var questionOne: Bool = false
    @State private var questionTwo: Bool = false
    @State private var questionThree: Bool = false
    
    // Progress visibility
    @State private var showProgressTwo: Bool = false
    @State private var showProgressThree: Bool = false
    
    // Duration for each half-step (0 -> 0.5 or 0.5 -> 1.0)
    let timeTo50Percent: TimeInterval = 1.5
    
    // Keep references to timers so we can invalidate when needed
    @State private var timerOne: Timer?
    @State private var timerTwo: Timer?
    @State private var timerThree: Timer?
    
    var body: some View {
        VStack(spacing: 32) {
            Group {
                Text("We are crafting your\n") +
                Text("focus experience...").foregroundStyle(Color.blueAccent)
            }
            .font(.grotesk(size: 30, weight: .semibold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 12)
            .padding(.top, 20)
            
            VStack(spacing: 56) {
                // Stage 1
                VStack(spacing: 10) {
                    HStack(spacing: 0) {
                        Text("Understanding your answers")
                            .font(.grotesk(.body, weight: .semibold))
                        
                        Spacer()
                        
                        Text("\(percentOne)%")
                            .font(.grotesk(.subheadline, weight: .medium))
                            .foregroundStyle(.secondary)
                            .contentTransition(.numericText())
                    }
                    
                    GeometryReader { geo in
                        let width = geo.size.width
                        
                        Capsule(style: .continuous)
                            .frame(height: 8)
                            .foregroundStyle(.secondary.opacity(0.15))
                            .overlay(alignment: .leading) {
                                Capsule(style: .continuous)
                                    .frame(height: 8)
                                    .foregroundStyle(Color.blueAccent)
                                    .frame(width: width * progressOne)
                            }
                    }
                    .frame(height: 8)
                }
                
                // Stage 2
                VStack(spacing: 10) {
                    HStack(spacing: 0) {
                        Text("Calculating report")
                            .font(.grotesk(.body, weight: .semibold))
                        
                        Spacer()
                        
                        Text("\(percentTwo)%")
                            .font(.grotesk(.subheadline, weight: .medium))
                            .foregroundStyle(.secondary)
                            .contentTransition(.numericText())
                    }
                    
                    GeometryReader { geo in
                        let width = geo.size.width
                        
                        Capsule(style: .continuous)
                            .frame(height: 8)
                            .foregroundStyle(.secondary.opacity(0.15))
                            .overlay(alignment: .leading) {
                                Capsule(style: .continuous)
                                    .frame(height: 8)
                                    .foregroundStyle(Color.blueAccent)
                                    .frame(width: width * progressTwo)
                            }
                    }
                    .frame(height: 8)
                }
                .opacity(showProgressTwo ? 1 : 0)
                .offset(y: showProgressTwo ? 0 : 32)

                // Stage 3
                VStack(spacing: 10) {
                    HStack(spacing: 0) {
                        Text("Finalising results")
                            .font(.grotesk(.body, weight: .semibold))
                        
                        Spacer()
                        
                        Text("\(percentThree)%")
                            .font(.grotesk(.subheadline, weight: .medium))
                            .foregroundStyle(.secondary)
                            .contentTransition(.numericText())
                    }
                    
                    GeometryReader { geo in
                        let width = geo.size.width
                        
                        Capsule(style: .continuous)
                            .frame(height: 8)
                            .foregroundStyle(.secondary.opacity(0.15))
                            .overlay(alignment: .leading) {
                                Capsule(style: .continuous)
                                    .frame(height: 8)
                                    .foregroundStyle(Color.blueAccent)
                                    .frame(width: width * progressThree)
                            }
                    }
                    .frame(height: 8)
                }
                .opacity(showProgressThree ? 1 : 0)
                .offset(y: showProgressThree ? 0 : 32)

            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(32)
        .overlay(alignment: .bottom) {
            if questionOne {
                Question(
                    title: "Do you find yourself reaching for your phone without thinking?",
                    onYes: { continueOne() },
                    onNo: { continueOne() }
                )
                .transition(.move(edge: .bottom))
            } else if questionTwo {
                Question(
                    title: "Do your goals ever feel unclear or overwhelming?",
                    onYes: { continueTwo() },
                    onNo: { continueTwo() }
                )
                .transition(.move(edge: .bottom))
            } else if questionThree {
                Question(
                    title: "Do you feel mentally tired from constantly switching tasks?",
                    onYes: { continueThree() },
                    onNo: { continueThree() }
                )
                .transition(.move(edge: .bottom))
            }
        }
        .onAppear(perform: setup)
        .onDisappear {
            invalidateTimers()
        }
    }
    
    // MARK: - Flow
    private func setup() {
        SleepTask.sleep(seconds: 0.15) {
            appearAnimation = true
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Reset labels and bars
        percentOne = 0; percentTwo = 0; percentThree = 0
        progressOne = 0; progressTwo = 0; progressThree = 0
        
        // Stage 1: 0 -> 50% (bar) + percent 0 -> 50
        withAnimation(.linear(duration: timeTo50Percent)) {
            progressOne = 0.5
        }
        startPercentTimer(for: .one, from: 0, to: 50, duration: timeTo50Percent)
        
        // Show question at 50%
        SleepTask.sleep(seconds: timeTo50Percent) {
            withAnimation(.smooth(duration: 0.35)) {
                questionOne = true
            }
        }
    }
    
    private func continueOne() {
        // Hide Q1
        withAnimation(.smooth(duration: 0.35)) {
            questionOne = false
        }
        
        // Stage 1: 50% -> 100% (bar) + percent 50 -> 100
        withAnimation(.linear(duration: timeTo50Percent)) {
            progressOne = 1.0
        }
        startPercentTimer(for: .one, from: 50, to: 100, duration: timeTo50Percent)
        
        // Stage 2: 0 -> 50% (bar) + percent 0 -> 50, then show Q2
        SleepTask.sleep(seconds: timeTo50Percent + 0.1) {
            withAnimation(.smooth(duration: 0.25)) {
                showProgressTwo = true
            }
            
            withAnimation(.linear(duration: timeTo50Percent)) {
                progressTwo = 0.5
            }
            startPercentTimer(for: .two, from: 0, to: 50, duration: timeTo50Percent)
            
            SleepTask.sleep(seconds: timeTo50Percent) {
                withAnimation(.smooth(duration: 0.35)) {
                    questionTwo = true
                }
            }
        }
    }
    
    private func continueTwo() {
        // Hide Q2
        withAnimation(.smooth(duration: 0.35)) {
            questionTwo = false
        }
        
        // Stage 2: 50% -> 100% (bar) + percent 50 -> 100
        withAnimation(.linear(duration: timeTo50Percent)) {
            progressTwo = 1.0
        }
        startPercentTimer(for: .two, from: 50, to: 100, duration: timeTo50Percent)
        
        // Stage 3: 0 -> 50% (bar) + percent 0 -> 50, then show Q3
        SleepTask.sleep(seconds: timeTo50Percent + 0.1) {
            withAnimation(.smooth(duration: 0.25)) {
                showProgressThree = true
            }

            withAnimation(.linear(duration: timeTo50Percent)) {
                progressThree = 0.5
            }
            startPercentTimer(for: .three, from: 0, to: 50, duration: timeTo50Percent)
            
            SleepTask.sleep(seconds: timeTo50Percent) {
                withAnimation(.smooth(duration: 0.35)) {
                    questionThree = true
                }
            }
        }

    }

    private func continueThree() {
        // Hide Q3
        withAnimation(.smooth(duration: 0.35)) {
            questionThree = false
        }
        
        // Stage 3: 50% -> 100% (bar) + percent 50 -> 100
        withAnimation(.linear(duration: timeTo50Percent)) {
            progressThree = 1.0
        }
        startPercentTimer(for: .three, from: 50, to: 100, duration: timeTo50Percent)
        
        // Complete flow
        SleepTask.sleep(seconds: timeTo50Percent + 0.25) {
            action()
        }
    }
    
    private func action() {
        vm.showReportBar = true
        vm.calculateReport()
        vm.nextPage()
    }
    
    // MARK: - Timers
    private enum Stage {
        case one, two, three
    }
    
    private func startPercentTimer(for stage: Stage, from start: Int, to end: Int, duration: TimeInterval) {
        let steps = max(1, end - start)
        let interval = duration / Double(steps)
        
        // Invalidate existing timer for this stage
        switch stage {
        case .one:
            timerOne?.invalidate()
        case .two:
            timerTwo?.invalidate()
        case .three:
            timerThree?.invalidate()
        }
        
        var current = start
        let newTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { t in
            current += 1
            switch stage {
            case .one:
                percentOne = min(current, end)
            case .two:
                percentTwo = min(current, end)
            case .three:
                percentThree = min(current, end)
            }
            
            if current >= end {
                t.invalidate()
            }
        }
        
        // Store timer reference
        switch stage {
        case .one:
            timerOne = newTimer
        case .two:
            timerTwo = newTimer
        case .three:
            timerThree = newTimer
        }
        
        // Ensure timer runs on common modes so it’s not paused during UI updates
        RunLoop.main.add(newTimer, forMode: .common)
    }
    
    private func invalidateTimers() {
        timerOne?.invalidate(); timerOne = nil
        timerTwo?.invalidate(); timerTwo = nil
        timerThree?.invalidate(); timerThree = nil
    }
    
    // MARK: - Question UI
    @ViewBuilder
    private func Question(
        title: String,
        onYes: @escaping () -> Void,
        onNo: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 24) {
            Text(title)
                .font(.grotesk(.title3, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.textC)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                Button {
                    onNo()
                } label: {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .frame(height: 80)
                        .foregroundStyle(.secondary.opacity(0.15))
                        .overlay {
                            VStack(spacing: 6) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 30, weight: .semibold))
                                
                                Text("No")
                                    .font(.grotesk(.subheadline, weight: .semibold))
                            }
                            .foregroundStyle(.textC)
                        }
                }
                
                Button {
                    onYes()
                } label: {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .frame(height: 80)
                        .foregroundStyle(.secondary.opacity(0.15))
                        .overlay {
                            VStack(spacing: 6) {
                                let checkSize: CGFloat = 60.0
                                
                                CheckmarkShape(trimEnd: 1.0)
                                    .trim(from: 0.0, to: 1.0)
                                    .stroke(
                                        .textC,
                                        style: StrokeStyle(
                                            lineWidth: checkSize / 14,
                                            lineCap: .round,
                                            lineJoin: .round
                                        )
                                    )
                                    .frame(square: checkSize / 2.0)

                                Text("Yes")
                                    .font(.grotesk(.subheadline, weight: .semibold))
                            }
                            .foregroundStyle(.textC)

                        }
                }
            }
            .padding()
        }
        .frame(height: 250)
        .background(Theme.foregroundC, in: .rect(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 32)
        .padding(.vertical)
    }


}

#Preview {
    OBLoadingInteractive()
        .environmentObject(OBVM())
}
