//
//  HomeTabView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 01/02/26.
//

import SwiftUI
import Lottie
import ManagedSettings

struct HomeTabView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var toastManager: ToastManager
    @EnvironmentObject var focusViewModel: FocusViewModel

    @StateObject private var homeViewModel = HomeViewModel()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BlockEntity.dateCreated, ascending: false)],
        animation: .default
    )
    private var blocks: FetchedResults<BlockEntity>
    
    @FetchRequest(sortDescriptors: [], predicate: .today(for: "timestamp"))
    private var todaysRecords: FetchedResults<RecordEntity>
    
    @FetchRequest(sortDescriptors: [])
    private var allRecords: FetchedResults<RecordEntity>
    
    @AppStorage("hasTakenSurvey1") var hasTakenSurvey1: Bool = false
    @State private var showSurvey = false

    var body: some View {
        NavigationStack {
            ScrollView {                
                VStack(spacing: 32) {
                    
                    SurveyView()
                    
                    VStack(spacing: 20) {
                        WeekView()
                        
                        VStack(spacing: 18) {

                            CircularProgress()
                                                        
                            Button {
                                Haptics.feedback(style: .light)
                                focusViewModel.showSetup = true
                            } label: {
                                Capsule(style: .continuous)
                                    .frame(height: 55)
                                    .foregroundStyle(.secondary.opacity(0.15))
                                    .overlay {
                                        Text("Start Focus Session")
                                            .foregroundStyle(.secondary)
                                            .font(.grotesk(size: 18.5, weight: .semibold))
                                    }
                            }
                            .tint(.primary)

                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .foregroundStyle(Theme.foregroundC)
                                .border(cornerRadius: 32)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        if sortedBlocksByUsage.isEmpty {
                            emptyState
                        } else {
                            ForEach(sortedBlocksByUsage) { block in
                                if let string = block.appTokenString,
                                   let token = ApplicationToken.fromRawValue(string) {
                                    BlockEntityRow(block: block, token: token)
                                }
                            }
                        }
                    }

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        homeViewModel.showStreakView = true
                    } label: {
                        HStack(spacing: 4) {
                            Text("\(userViewModel.currentStreak)")
                                .font(.grotesk(size: 16, weight: .semibold))
                            
                            LottieView(animation: .named("fire"))
                                .looping()
                                .frame(square: 18)
                        }
                    }
                    .tint(.fillOrange)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        homeViewModel.showCreateView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .tint(.primary)
                }
            }
            .toolbar {
                ToolbarItem(placement: .title) {
                    Text("\(AppConfiguration.name)")
                        .font(.grotesk(size: 22, weight: .semibold))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
            .sheet(item: $homeViewModel.selectedBlock) { block in
                BlockView(block: block)
            }
            .sheet(isPresented: $homeViewModel.showStreakView) {
                StreaksView()
            }
            .sheet(isPresented: $homeViewModel.showCreateView) {
                FamilySelectionView()
            }
            .sheet(item: $homeViewModel.selectedDate) { date in
                WeekdayView(day: date.date)
            }
            .sheet(isPresented: $focusViewModel.showSetup) {
                FocusSetupView()
            }
        }
        .sheet(isPresented: $showSurvey) {
            NavigationStack {
                if let url = URL(string: AppConfiguration.tallyFeedbackURL) {
                    TallyWebView(url: url) {
                        showSurvey = false
                        hasTakenSurvey1 = true
                        toastManager.info("🎉 Survey Submitted!")
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func SurveyView() -> some View {
        if (userViewModel.user?.dateCreated?.distance(to: .now) ?? 0) > (3 * 86400) {
            if !hasTakenSurvey1 {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .frame(height: 128)
                    .foregroundStyle(.blue.gradient)
                    .overlay {
                        HStack {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("\(userViewModel.user?.name ?? ""), take a quick survey to improve the app :)")
                                    .font(.grotesk(.title3, weight: .semibold))
                                
                                HStack(spacing: 6) {
                                    Image(systemName: "clock")
                                        .font(.grotesk(.subheadline, weight: .regular))
                                        .opacity(0.75)

                                    Text("Takes less than a minute")
                                        .font(.grotesk(.subheadline, weight: .regular))
                                        .opacity(0.85)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 32, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(20)
                    }
                    .onTapGesture {
                        showSurvey = true
                    }
            }
        }
    }
    
    // MARK: - View components
    @ViewBuilder
    private func WeekView() -> some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        // Build last 7 days left-to-right: [today-6, ..., today-1, today]
        let last7Days: [Date] = (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: -(6 - offset), to: today)
        }
        
        HStack(spacing: 16) {
            ForEach(last7Days, id: \.self) { weekday in
                let isToday: Bool = calendar.isDateInToday(weekday)
                let goal: TimeInterval = userViewModel.user?.goal(for: weekday) ?? 3600
                
                let filteredRecords = Array(allRecords).filtered(by: weekday)
                let screenTime = filteredRecords.reduce(0) { $0 + $1.duration }
                                
                let isBeforeDownload: Bool = calendar.startOfDay(for: weekday) < calendar.startOfDay(for: userViewModel.user?.dateCreated ?? .now)
                let underLimit: Bool = screenTime <= goal
                let isFuture: Bool = weekday > Date.now
                
                VStack(spacing: 10) {
                    Text(weekday.formatted(components: [.weekday]).uppercased())
                        .kerning(1.0)
                        .font(.grotesk(.caption2, weight: .semibold))
                        .foregroundStyle(isToday ? Color.primary : Color.secondary.opacity(0.65))
                    
                    Circle()
                        .foregroundStyle(isBeforeDownload || isFuture ? Color.secondary.opacity(0.5) : isToday ? Color.secondary : underLimit ? Color.skyBlue : Color.red)
                        .opacity(0.15)
                        .overlay {
                            if isToday {
                                // No inner glyph for today (keeps your existing behavior)
                            } else if isBeforeDownload || isFuture {
                                // No glyph for days before account or in the future
                            } else if underLimit {
                                let checkSize: CGFloat = 32.0
                                
                                CheckmarkShape(trimEnd: 1.0)
                                    .trim(from: 0.0, to: 1.0)
                                    .stroke(
                                        Color.skyBlue,
                                        style: StrokeStyle(
                                            lineWidth: checkSize / 12,
                                            lineCap: .round,
                                            lineJoin: .round
                                        )
                                    )
                                    .frame(square: checkSize / 2.0)
                            } else {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.red)
                            }
                        }
                        .padding(.horizontal, 2)
                }
            }
        }
        .padding(.horizontal, 8)
    }
    
    @ViewBuilder
    private func CircularProgress() -> some View {
        let remaining: TimeInterval = max(screenTimeGoal - totalUsageToday, 0)
        
        #if targetEnvironment(simulator)
        let progress: CGFloat = 0.75
        #else
        let progress: CGFloat = min(1, totalUsageToday / max(1, screenTimeGoal))
        #endif
        

        let linewidth: CGFloat = 48
        
        GeometryReader { geometry in
            let width = geometry.size.width
            
            ZStack {
                Circle()
                    .stroke(lineWidth: linewidth)
                    .foregroundStyle(.secondary.opacity(0.1))
                
                Circle()
                    .stroke(lineWidth: 2)
                    .foregroundStyle(.secondary.opacity(0.15))
                
                Circle()
                    .trim(from: progress, to: 1)
                    .stroke(style: .init(lineWidth: linewidth * 0.8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .foregroundStyle(.skyBlue)
                
                Circle()
                    .trim(from: progress, to: 1)
                    .stroke(lineWidth: 2)
                    .rotationEffect(.degrees(-90))
                    .foregroundStyle(.skyBlue)
                    .brightness(0.8)
                    .opacity(0.15)

                VStack(spacing: 4) {
                    Text("Daily goal: \(TimeFormatter.display(screenTimeGoal, style: .short))".uppercased())
                        .font(.grotesk(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .kerning(1.0)
                    
                    Text("\(TimeFormatter.display(remaining, style: .short))")
                        .font(.grotesk(size: width * 0.18, weight: .semibold))
                        .foregroundStyle(.textC)
                        .contentTransition(.numericText(value: totalUsageToday))
                        .animation(.smooth, value: totalUsageToday)
                    
                    Text("Remaining")
                        .font(.grotesk(size: 16, weight: .medium))
                        .foregroundStyle(.secondary).opacity(0.75)
                }
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
        .padding(32)
        .frame(maxWidth: .infinity, alignment: .center)

    }
        
    // When no app is added to the block list, this view will show up
    @ViewBuilder
    private var emptyState: some View {
        Button {
            homeViewModel.showCreateView = true
        } label: {
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    Circle()
                        .foregroundStyle(.secondary.opacity(0.15))
                        .overlay {
                            Image(systemName: "plus")
                                .font(.system(size: 32, weight: .medium))
                                .foregroundStyle(.secondary.opacity(0.8))
                        }
                        .frame(square: 64)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Choose an App")
                            .font(.grotesk(.title3, weight: .semibold))
                            .foregroundStyle(.textC)
                        
                        Text("Start monitoring your usage")
                            .font(.grotesk(.subheadline, weight: .regular))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .foregroundStyle(Theme.foregroundC)
                    .border(cornerRadius: 32)
            }
        }
        .tint(.primary)

    }
    
    @ViewBuilder
    private func BlockEntityRow(block: BlockEntity, token: ApplicationToken) -> some View {
        var todaysUsage: TimeInterval { todaysRecords.reduce(.zero) { $0 + $1.duration } }
        var todaysRecords: [RecordEntity] { block.records.filtered(by: .now) }
        var todaysOpens: Int { todaysRecords.count }
        var isAppOpen: Bool {
            if let endTime = block.openEndTime {
                return Date.now <= endTime
            }
            return false
        }
        var progressToTotalUsage: CGFloat { totalUsageToday == 0 ? 0 : min(1, max(todaysUsage / totalUsageToday, 0)) }
        
        var superlink: Superlink? {
            if let superlinkId = block.superlinkId, let slink = Superlink.find(by: superlinkId) {
                return slink
            }
            
            return nil
        }
        
        Button {
            homeViewModel.selectedBlock = block
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 14) {
                    if let superlink {
                        Image(superlink.asset)
                            .resizable()
                            .scaledToFit()
                            .appIconStyle(size: 40)
                    } else {
                        Label(token)
                            .labelStyle(.iconOnly)
                            .scaleEffect(2.0)
                            .frame(square: 40)
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            if let superlink {
                                Text(superlink.name)
                                    .font(.grotesk(size: 18.5, weight: .regular))
                            } else {
                                Label(token)
                                    .labelStyle(.titleOnly)
                                    .scaleEffect(0.9, anchor: .leading)
                            }

                            Spacer()
                            
                            Text(TimeFormatter.display(todaysUsage, style: .spaced))
                                .font(.grotesk(.caption, weight: .regular))
                                .foregroundStyle(.secondary)
                        }
                        
                        if let endTime = block.openEndTime, Date.now <= endTime {
                            // App is currently open - show time remaining
                            TimelineView(.animation(minimumInterval: 0.016)) { timeline in // ~60fps
                                let now = timeline.date
                                let totalDuration = endTime.timeIntervalSince(block.openStartTime ?? now)
                                let remaining = endTime.timeIntervalSince(now)
                                let progress = max(0, min(1, remaining / totalDuration))
                                
                                ProgressView(value: progress)
                                    .tint(.orange)
                                    .frame(height: 5)
                            }
                        } else if let nextAvailableDate = block.nextAvailableDate, Date.now < nextAvailableDate {
                            // Recharging - show recharge progress
                            TimelineView(.animation(minimumInterval: 0.016)) { timeline in // ~60fps
                                let now = timeline.date
                                let rechargeTime = block.cooldown
                                let remaining = nextAvailableDate.timeIntervalSince(now)
                                let progress = max(0, min(1, 1 - (remaining / rechargeTime)))

                                ProgressView(value: progress)
                                    .tint(.indigo)
                                    .frame(height: 5)
                            }
                        } else {
                            // Normal usage bar
                            GeometryReader { geo in
                                let width = geo.size.width
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color.secondary.opacity(progressToTotalUsage == 0 ? 0.15 : 0.0))
                                    .overlay(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 2)
                                            .frame(width: width * progressToTotalUsage)
                                            .foregroundStyle(Color.skyBlue)
                                    }
                            }
                            .frame(height: 5)
                        }
                                                
                    }
                }
                
                ZStack(alignment: .leading) {
                    Group {
                        if let endTime = block.openEndTime, Date.now <= endTime {
                            if block.isOpenForToday {
                                // App is currently open for the entire day
                                Group {
                                    Text("Open for today • ") +
                                    Text(timerInterval: Date.now...endTime) +
                                    Text("s")
                                }
                                .foregroundStyle(.orange)
                            } else {
                                // App is currently open
                                Group {
                                    Text("Closes in ") +
                                    Text(timerInterval: Date.now...endTime) +
                                    Text("s")
                                }
                                .foregroundStyle(.orange)
                            }
                        } else if let nextAvailableDate = block.nextAvailableDate, Date.now < nextAvailableDate {
                            // Recharging
                            Group {
                                Text("Recharging • Available in ") +
                                Text(timerInterval: Date.now...nextAvailableDate) +
                                Text("s")
                            }
                            .foregroundStyle(.indigo)
                        } else {
                            // Default state - not open, not recharging
                            Text(todaysOpens < 1 ? "Never opened today" : "Opened \(todaysOpens) times")
                                .foregroundStyle(.textC.opacity(0.5))
                        }
                    }
                    .font(.grotesk(.footnote, weight: .medium))
                }
                .padding(.leading, 40 + 14)
                                
                if let endTime = block.openEndTime, Date.now < endTime, block.isOpen {
                    // Block is currently open and time hasn't ended yet
                    Button {
                        homeViewModel.closeEarly(block: block, token: token)
                    } label: {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.secondary.opacity(0.15))
                            .frame(height: 40)
                            .overlay {
                                HStack(spacing: 6) {
                                    Image(systemName: "lock.fill")
                                        .font(.subheadline.weight(.medium))
                                    
                                    Text("Close Now")
                                }
                                .font(.grotesk(.body, weight: .semibold))
                                .foregroundStyle(.secondary)
                            }
                    }
                    .padding(.leading, 14 + 40)
                    
                } else if shouldShowRestoreButton(for: block, token: token, endTime: block.openEndTime) {
                    // Time ended but block is still open (not shielded)
                    Button {
                        homeViewModel.restoreBlock(block: block, token: token)
                        toastManager.success("Block Restored")
                    } label: {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.secondary.opacity(0.15))
                            .frame(height: 40)
                            .overlay {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.subheadline.weight(.medium))
                                    
                                    Text("Restore Block")
                                }
                                .font(.grotesk(.body, weight: .semibold))
                                .foregroundStyle(.secondary)
                            }
                    }
                    .padding(.leading, 14 + 40)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .foregroundStyle(Theme.foregroundC)
                    .border(cornerRadius: 32)
            }
            .onChange(of: scenePhase) { oldValue, newValue in
                homeViewModel.handleSceneUpdated(
                    block: block,
                    oldValue: oldValue,
                    newValue: newValue
                )
            }
        }
        .tint(.primary)
    }
    
    // Helper function
    private func shouldShowRestoreButton(for block: BlockEntity, token: ApplicationToken, endTime: Date?) -> Bool {
        let timeHasEnded = if let endTime {
            Date.now > endTime
        } else {
            !block.isOpenForToday
        }
        
        return timeHasEnded && !DeviceActivityManager.shared.isCurrentlyShielded(token: token)
    }
    
    // MARK: - Computed properties
    
    var totalUsageToday: TimeInterval {
        todaysRecords.reduce(0) { $0 + $1.duration }
    }
    
    var screenTimeGoal: TimeInterval {
        userViewModel.user?.goal(for: .now) ?? 3600 // 1 hour if any error
    }
    
    var sortedBlocksByUsage: [BlockEntity] {
        blocks.sorted {
            $0.records.filtered(by: .now).reduce(0) { $0 + $1.duration } > $1.records.filtered(by: .now).reduce(0) { $0 + $1.duration }
        }
    }

}

#Preview {
    RootView()
        .environmentObject(UserViewModel())
        .environmentObject(ToastManager())
        .environmentObject(FocusViewModel())
}
