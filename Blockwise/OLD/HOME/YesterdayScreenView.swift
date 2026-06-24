//
//  YesterdayScreenView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 13/12/25.
//

import SwiftUI
import Lottie
import ManagedSettings
import CoreData

enum ReviewStoryStep: Int, CaseIterable {
    case one, two, three, four
}

struct YesterdayScreenView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: UserViewModel
    @EnvironmentObject var toastManager: ToastManager

    @FetchRequest(sortDescriptors: [])
    private var records: FetchedResults<RecordEntity>
    
    let blocks: FetchedResults<BlockEntity>

    @State private var filter: Date = .yesterday
    
    var data: [RecordEntity] {
        Array(records).filtered(by: filter).sortedByMostRecent()
    }
    
    var usage: TimeInterval {
        data.reduce(.zero) { $0 + $1.duration }
    }
    
    var goal: TimeInterval {
        vm.user?.goal(for: .yesterday) ?? 3600
    }
    
    @State private var appearAnimation: Bool = false
    
    @State private var currentStep: ReviewStoryStep = .one
    
    private var inviteText: String {
        """
        I’ve been using \(AppConfiguration.name) to stay off distracting apps 🔥

        Yesterday I spent only \(TimeFormatter.display(usage, style: .short)) on my apps.

        Want to try it with me?
        👉 https://apps.apple.com/us/app/blockr-screen-time-control/id6630375265
        
        """
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if currentStep == .one {
                    FirstStep()
                } else if currentStep == .two {
                    SecondStep(usage: usage, goal: goal)
                } else if currentStep == .three {
                    ThirdStep(data: data)
                } else if currentStep == .four {
                    FourthStep {
                        dismiss()
                        if let user = vm.user {
                            do {
                                try CoreDataStack.shared.markTodayReviewComplete(for: user)
                                Haptics.feedback(style: .light)
                            } catch {
                                toastManager.error("Error 102: \(error.localizedDescription)")
                                Logger.error(error.localizedDescription)
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
            .toolbar {

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.primary)
                }
            }
            .safeAreaInset(edge: .bottom) {
                ShareLink(
                    item: inviteText,
                    subject: Text("Join me on Focus"),
                    message: Text("Let’s stay focused together 🔥")
                ) {
                    HStack(spacing: 10) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.grotesk(size: 18, weight: .semibold))

                        Text("Invite a friend")
                            .font(.grotesk(size: 20, weight: .semibold))
                    }
                    .padding(8)
                }
                .tint(.primary)
            }
//            .safeAreaInset(edge: .bottom) {
//                Button {
//                    
//                } label: {
//                    HStack(spacing: 10) {
//                        Image(systemName: "square.and.arrow.up")
//                            .font(.grotesk(size: 18, weight: .semibold))
//
//                        Text("Invite a friend")
//                            .font(.grotesk(size: 20, weight: .semibold))
//                    }
//                }
//                .tint(.primary)
//                .padding(8)
//            }
            .overlay(alignment: .top) {
                HStack(spacing: 10) {
                    ForEach(ReviewStoryStep.allCases, id: \.self) { step in
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.secondary.opacity(0.15))
                            .overlay(alignment: .leading) {
                                if step.rawValue <= currentStep.rawValue {
                                    RoundedRectangle(cornerRadius: 10)
                                }
                            }
                            .frame(width: 44, height: 3)
                            .offset(y: -32)
                    }
                }
            }
            .onAppear(perform: setup)
        }
        .overlay {
            HStack(spacing: 0) {
                Rectangle()
                    .foregroundStyle(.clear)
                    .contentShape(.rect)
                    .onTapGesture {
                        if currentStep == .one {
                            nextStep()
                        } else {
                            previousStep()
                        }
                    }
                
                Rectangle()
                    .foregroundStyle(.clear)
                    .contentShape(.rect)
                    .onTapGesture {
                        nextStep()
                    }
            }
            .padding(.bottom, currentStep == .four ? 128 : 0)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .frame(height: 1.5)
                    .foregroundStyle(.secondary.opacity(0.1))
            }
            .padding(.vertical, 56)
        }
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.15) {
            withAnimation {
                appearAnimation = true
            }
        }
    }
    
    private func nextStep() {
        Logger.debug("NEXT")

        let nextRawValue = currentStep.rawValue + 1
        if let nextStep = ReviewStoryStep(rawValue: nextRawValue) {
            currentStep = nextStep
        }
    }

    private func previousStep() {
        Logger.debug("PREVIOUS")

        let previousRawValue = currentStep.rawValue - 1
        if let previousStep = ReviewStoryStep(rawValue: previousRawValue) {
            currentStep = previousStep
        }
    }
    
}

private struct YesterdayScreenViewPreview: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BlockEntity.dateCreated, ascending: false)],
        animation: .default
    )
    private var blocks: FetchedResults<BlockEntity>

    var body: some View {
        YesterdayScreenView(blocks: blocks)
    }
}

#Preview {
    YesterdayScreenViewPreview()
        .environmentObject(UserViewModel())
}

// MARK: - First step
private struct FirstStep: View {
    @State private var appearAnimation: Bool = false
    @State private var filter: Date = .yesterday

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Text(dayOfWeek)
                        .font(.grotesk(size: 28, weight: .bold))
                        .foregroundStyle(.orange)
                    
                    Text(month)
                        .font(.grotesk(size: 28, weight: .bold))
                        .foregroundStyle(.textC)
                }
                
                Text(day)
                    .font(.grotesk(size: 110, weight: .bold))
                    .frame(height: 100)
                    .foregroundStyle(.textC)
            }
            .padding(32)
            .background {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .foregroundStyle(Theme.foregroundC)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(lineWidth: 3.0)
                            .foregroundStyle(.secondary.opacity(0.15))
                    }
            }
            .scaleEffect(0.85)
            
            Text("Here’s how yesterday went:")
                .font(.grotesk(size: 30, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineSpacing(2.0)
                .foregroundStyle(.textC)
            
            Space(height: 44)
        }
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 32)
        .scaleEffect(appearAnimation ? 1 : 0.95)
        .animation(.smooth, value: appearAnimation)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottom) {
            Text("Tap anywhere to continue")
                .font(.grotesk(.subheadline, weight: .regular))
                .foregroundStyle(.secondary)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.1), value: appearAnimation)
                .phaseAnimator([true, false]) { view, phase in
                    view
                        .opacity(phase ? 1 : 0.5)
                } animation: { _ in
                        .smooth(duration: 1.0)
                }
        }
        .padding(32)
        .onAppear(perform: setup)
    }
    
    var dayOfWeek: String {
        filter.formatted(.dateTime.weekday(.abbreviated))
    }
    
    var month: String {
        filter.formatted(.dateTime.month(.abbreviated))
    }
    
    var day: String {
        filter.formatted(.dateTime.day())
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.1) {
            withAnimation(.smooth(duration: 0.8)) {
                appearAnimation = true
            }
        }
    }
}

// MARK: - Second step
private struct SecondStep: View {
    @State private var appearAnimation: Bool = false
    
    var usage: TimeInterval
    var goal: TimeInterval
    
    var body: some View {
        let remaining: TimeInterval = max(goal - usage, 0)
        let progress: CGFloat = min(1, usage / max(1, goal))
        
        let isLimit: Bool = progress >= 1
        
        let color: Color = isLimit ? .orange : .blueAccent

        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .stroke(lineWidth: 38)
                    .foregroundStyle(color.opacity(0.15))
                
                Circle()
                    .stroke(lineWidth: 2)
                    .foregroundStyle(color.opacity(0.15))
                
                Circle()
                    .trim(from: 0, to: appearAnimation ? progress : 0)
                    .stroke(style: .init(lineWidth: 30, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .foregroundStyle(color)
                
                if usage > 3600 {
                    Text(TimeFormatter.display(usage, style: .short))
                        .font(.grotesk(size: 38, weight: .semibold))
                        .foregroundStyle(.textC)
                } else {
                    Text(TimeFormatter.display(usage, style: .short))
                        .font(.grotesk(size: 48, weight: .semibold))
                        .foregroundStyle(.textC)
                }
            }
            .padding(.horizontal, 48)
            .padding(.bottom, 32)
            
            Text("You spent \(TimeFormatter.display(usage, style: .short)) on your apps")
                .font(.grotesk(size: 28, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineSpacing(2.0)
                .foregroundStyle(.textC)
            
            if progress == 1 {
                Text("You stayed under your daily limit!")
                    .font(.grotesk(size: 17, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2.0)
            } else if progress > 1, goal < usage {
                Text("That’s **\(TimeFormatter.display(usage - goal, style: .short))** over your daily limit.")
                    .font(.grotesk(size: 17, weight: .regular))
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2.0)
            } else {
                Text("That’s **\(TimeFormatter.display(remaining, style: .short))** under your daily limit!")
                    .font(.grotesk(size: 17, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2.0)
            }
        }
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 32)
        .scaleEffect(appearAnimation ? 1 : 0.95)
        .animation(.smooth, value: appearAnimation)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .onAppear(perform: setup)
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.1) {
            withAnimation(.smooth(duration: 0.8)) {
                appearAnimation = true
            }
        }
    }
}

// MARK: - Third step
private struct ThirdStep: View {
    @State private var appearAnimation: Bool = false
    
    let data: [RecordEntity]
    
    // Aggregate total duration per BlockEntity using NSManagedObjectID as key
    private var totalsByBlock: [(block: BlockEntity, total: TimeInterval)] {
        var dict: [NSManagedObjectID: (block: BlockEntity, total: TimeInterval)] = [:]
        
        for record in data {
            guard let block = record.block else { continue }
            let key = block.objectID
            let current = dict[key]?.total ?? 0
            dict[key] = (block, current + record.duration)
        }
        
        // Sort descending by total duration
        return dict.values.sorted { $0.total > $1.total }
    }
    
    // Convenience: top 3 blocks if needed
    private var topBlocks: ArraySlice<(block: BlockEntity, total: TimeInterval)> {
        totalsByBlock.prefix(3)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 56) {
                Text("Most used apps:")
                    .font(.grotesk(size: 28, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2.0)
                    .foregroundStyle(.textC)
                                
                HStack(alignment: .bottom, spacing: 14) {
                    VStack(spacing: 32) {
                        if topBlocks.indices.contains(1) {
                            let second = topBlocks[topBlocks.index(topBlocks.startIndex, offsetBy: 1)]
                            let token = ApplicationToken.fromRawValue(second.block.appTokenString ?? "")
                            
                            VStack(spacing: 14) {
                                if let token {
                                    Label(token)
                                        .scaleEffect(2.5)
                                        .labelStyle(.iconOnly)
                                        .frame(square: 44)
                                }
                                
                                Text(TimeFormatter.display(second.total, style: .short))
                                    .font(.grotesk(size: 18, weight: .medium))
                                    .foregroundStyle(.textC)
                            }
                        } else {
                            Image(systemName: "nosign")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundStyle(.secondary.opacity(0.5))
                        }

                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .frame(height: appearAnimation ? 88 : 0)
                            .foregroundStyle(Theme.foregroundC)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(lineWidth: 2.0)
                                    .foregroundStyle(.secondary.opacity(0.15))
                            }
                            .overlay {
                                Text("2nd")
                                    .font(.grotesk(size: 24, weight: .bold))
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }
                        
                    }

                    VStack(spacing: 32) {
                        if let first = topBlocks.first {
                            let token = ApplicationToken.fromRawValue(first.block.appTokenString ?? "")
                            
                            VStack(spacing: 14) {
                                if let token {
                                    Label(token)
                                        .scaleEffect(2.5)
                                        .labelStyle(.iconOnly)
                                        .frame(square: 44)
                                        .overlay(alignment: .top) {
                                            Image(systemName: "crown.fill")
                                                .font(.system(size: 24))
                                                .offset(y: -38)
                                                .foregroundStyle(Color.orange.opacity(0.8))
                                        }
                                }
                                
                                Text(TimeFormatter.display(first.total, style: .short))
                                    .font(.grotesk(size: 18, weight: .medium))
                            }
                        } else {
                            Image(systemName: "nosign")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundStyle(.secondary.opacity(0.5))
                        }
                        
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .frame(height: appearAnimation ? 128 : 0)
                            .foregroundStyle(Theme.foregroundC)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(lineWidth: 2.0)
                                    .foregroundStyle(.secondary.opacity(0.15))
                            }
                            .overlay {
                                Text("1st")
                                    .font(.grotesk(size: 28, weight: .bold))
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }
                    }

                    VStack(spacing: 32) {
                        if topBlocks.indices.contains(2) {
                            let third = topBlocks[topBlocks.index(topBlocks.startIndex, offsetBy: 2)]
                            let token = ApplicationToken.fromRawValue(third.block.appTokenString ?? "")

                            VStack(spacing: 14) {
                                if let token {
                                    Label(token)
                                        .scaleEffect(2.5)
                                        .labelStyle(.iconOnly)
                                        .frame(square: 44)
                                }

                                Text(TimeFormatter.display(third.total, style: .short))
                                    .font(.grotesk(size: 18, weight: .medium))
                            }
                        } else {
                            Image(systemName: "nosign")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundStyle(.secondary.opacity(0.5))
                        }

                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .frame(height: appearAnimation ? 64 : 0)
                            .foregroundStyle(Theme.foregroundC)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(lineWidth: 2.0)
                                    .foregroundStyle(.secondary.opacity(0.15))
                            }
                            .overlay {
                                Text("3rd")
                                    .font(.grotesk(size: 20, weight: .bold))
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }
                    }

                }
                .frame(height: 250)
                .padding(.top, 32)
                
//                Text("You can check more stats from yesterday from the weekly view in the Today tab.")
//                    .font(.grotesk(.subheadline, weight: .regular))
//                    .foregroundStyle(.secondary)
//                    .multilineTextAlignment(.center)
//                    .lineSpacing(4.0)
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth, value: appearAnimation)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(32)
        }
        .onAppear(perform: setup)
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.1) {
            withAnimation(.smooth(duration: 0.5)) {
                appearAnimation = true
            }
        }
    }
}

// MARK: - Fourth step
private struct FourthStep: View {
    @EnvironmentObject var vm: UserViewModel
    @State private var appearAnimation: Bool = false
    @State private var streakCount: Int = 0
    @State private var lastValue: Int = 5
    
    var completion: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            LottieView(animation: .named("fire"))
                .looping()
                .frame(square: 128)
                .background {
                    LottieView(animation: .named("fire"))
                        .looping()
                        .frame(square: 128)
                        .scaleEffect(1.1)
                        .brightness(1.0)
                        .shadow(radius: 8)
                        .offset(y: -2)
                }
                .scaleEffect(streakCount == lastValue ? 0.2 : 1.0)
                .offset(y: streakCount == lastValue ? 100 : 0)
                .opacity(streakCount == lastValue ? 0 : 1)
                .background {
//                    Image(.rays)
//                        .resizable()
//                        .scaledToFit()
//                        .scaleEffect(3)
//                        .offset(y: 4)
//                        .opacity(streakCount == lastValue ? 0 : 0.35)
//                        .animation(.smooth, value: streakCount)
//                        .rotationEffect(.degrees(appearAnimation ? 360 : 0))
//                        .animation(.linear(duration: 10.0).repeatForever(autoreverses: false), value: appearAnimation)
                }
                .padding(.bottom)

            VStack(spacing: 0) {
                Text(streakCount.description)
                    .font(.grotesk(size: 100, weight: .semibold))
                    .contentTransition(.numericText(value: Double(streakCount)))
                    .foregroundStyle(Color.primaryOrange)
                    .grayscale(streakCount == lastValue ? 1 : 0)
                    .scaleEffect(streakCount == lastValue ? 1.0 : 1.15)
                    .offset(y: streakCount == lastValue ? 0 : -32)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth, value: appearAnimation)
                    .frame(height: 90, alignment: .top)
                    .offset(y: streakCount == lastValue ? 16 : 0)
                
                Text("Day Streak")
                    .font(.grotesk(size: 32, weight: .bold))
                    .foregroundStyle(Color.primaryOrange)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.6 + 0.1), value: appearAnimation)
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .safeAreaInset(edge: .bottom) {
            GlassButton("Done", labelColor: .secondary, background: .secondary.opacity(0.15)) {
                completion()
            }
        }
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 32)
        .scaleEffect(appearAnimation ? 1 : 0.95)
        .animation(.smooth, value: appearAnimation)
        .onAppear(perform: setup)
    }
    
    private func setup() {
        streakCount = vm.currentStreak - 1
        
        SleepTask.sleep(seconds: 0.1) {
            withAnimation(.smooth(duration: 0.5)) {
                appearAnimation = true
            }
        }
        
        SleepTask.sleep(seconds: 0.6) {
            withAnimation(.snappy(duration: 0.5, extraBounce: 0.25)) {
                streakCount += 1
            }
            
            Haptics.successFeedback()
        }

    }
}

