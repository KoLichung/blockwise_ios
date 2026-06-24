//
//  FocusSessionView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 17/12/25.
//

import SwiftUI

struct FocusSessionView: View {
    
    // MARK: - Shared Focus State
    @AppStorage("isFocusSession") private var isFocusSession: Bool = false
    @AppStorage("focusMinutes") private var focusMinutes: Int = 90
    @AppStorage("focusSessionStart") private var focusSessionStart: Double = 0
    @AppStorage("isHyperFocus") private var isHyperFocus: Bool = false

    // MARK: - Local UI State
    @State private var appearAnimation: Bool = false
    @State private var holdProgress: CGFloat = 0.0
    @State private var completedHolding: Bool = false
    @State private var holdTimer: Timer? = nil

    // MARK: - Computed Time Values
    private var focusStartDate: Date {
        Date(timeIntervalSince1970: focusSessionStart)
    }

    private var focusEndDate: Date {
        focusStartDate.addingTimeInterval(TimeInterval(focusMinutes * 60))
    }

    private var remainingTime: TimeInterval {
        max(focusEndDate.timeIntervalSinceNow, 0)
    }

    private var progress: CGFloat {
        let total = TimeInterval(focusMinutes * 60)
        let elapsed = max(Date.now.timeIntervalSince(focusStartDate), 0)
        return min(1, elapsed / total)
    }

    // MARK: - View
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
                .opacity(appearAnimation ? 1.0 : 0.0)
                .onLongPressGesture(
                    minimumDuration: 2.5,
                    maximumDistance: .infinity
                ) { pressing in
                    guard !isHyperFocus else { return }
                    
                    if pressing && !completedHolding {
                        triggerHaptics()
                        withAnimation(.linear(duration: 2.5)) {
                            holdProgress = 1.0
                        }
                    } else if !completedHolding {
                        stopHaptics()
                        withAnimation(.smooth(duration: 0.45)) {
                            holdProgress = 0
                        }
                    }
                } perform: {
                    guard !isHyperFocus else { return }

                    completedHolding = true
                    stopHaptics()
                    endFocusSession()
                }

            GeometryReader { geo in
                let width = geo.size.width

                Circle()
                    .stroke(lineWidth: 38)
                    .foregroundStyle(.secondary.opacity(0.15))
                    .overlay {
                        TimelineView(.periodic(from: .now, by: 0.1)) { context in
                            let now = context.date
                            let total = TimeInterval(focusMinutes * 60)
                            let elapsed = max(now.timeIntervalSince(focusStartDate), 0)
                            let progress = min(1, elapsed / total)

                            Circle()
                                .trim(from: 0.0, to: progress)
                                .stroke(
                                    style: .init(
                                        lineWidth: 38,
                                        lineCap: .round
                                    )
                                )
                                .rotationEffect(.degrees(-90))
                                .foregroundStyle(Color.primaryOrange)
                                .animation(.linear, value: progress)
                        }
                    }
                    .frame(width: width * 0.62)
                    .overlay {
                        Circle()
                            .stroke(lineWidth: 2)
                            .foregroundStyle(.secondary.opacity(0.15))
                            .scaleEffect(1.22)
                    }
                    .overlay {
                        Text(focusEndDate, style: .timer)
                            .font(
                                .grotesk(
                                    size: width * 0.14,
                                    weight: .regular
                                )
                            )
                            .foregroundStyle(.primary)
                    }
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .center
                    )
            }
            .aspectRatio(1, contentMode: .fit)
            .offset(y: -32)
            .opacity(appearAnimation ? 1 : 0)
            .scaleEffect(appearAnimation ? 1.0 : 1.1)
            .opacity(1 - holdProgress)
            .scaleEffect(1 - (holdProgress * 0.05))
            
            if !isHyperFocus {
                holdProgressView
                holdHintView
            }
        }
        .onAppear(perform: setup)
        .onReceive(
            Timer.publish(
                every: 1,
                on: .main,
                in: .common
            ).autoconnect()
        ) { _ in
            guard isFocusSession else { return }
            if remainingTime <= 0 {
                endFocusSession()
            }
        }
    }

    // MARK: - Hold UI
    private var holdProgressView: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .frame(width: 150)
            .foregroundStyle(.secondary.opacity(0.15))
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .frame(width: 150 * holdProgress)
                    .foregroundStyle(.secondary)
            }
            .frame(height: 4)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .offset(y: -56)
            .opacity(holdProgress > 0 ? 1 : 0)
    }

    private var holdHintView: some View {
        Text("Hold to quit")
            .font(.grotesk(.body, weight: .medium))
            .foregroundStyle(.secondary.opacity(0.35))
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding()
            .opacity(appearAnimation ? 1 : 0)
    }

    // MARK: - Lifecycle
    private func setup() {
        if remainingTime <= 0 {
            isFocusSession = false
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                appearAnimation = true
            }
        }
    }

    // MARK: - Focus Control
    private func endFocusSession() {
        withAnimation {
            isFocusSession = false
        }
        isHyperFocus = false
        holdTimer?.invalidate()
        holdTimer = nil
        Haptics.successFeedback()
    }

    // MARK: - Haptics
    private func triggerHaptics() {
        holdTimer = Timer.scheduledTimer(
            withTimeInterval: 0.1,
            repeats: true
        ) { _ in
            Haptics.feedback(style: .soft)
        }
    }

    private func stopHaptics() {
        holdTimer?.invalidate()
        holdTimer = nil
    }
}

#Preview {
    FocusSessionView()
}
