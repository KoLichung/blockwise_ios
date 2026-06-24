//
//  HomescreenView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 25/11/25.
//

import SwiftUI
import Lottie
import ManagedSettings
import SuperwallKit

struct DateSelection: Identifiable {
    let id = UUID()
    let date: Date
}

enum HomeTab: String, CaseIterable {
    case block = "Blocks"
    case schedule = "Schedules"
}

struct HomeScreenView: View {
    @EnvironmentObject var vm: UserViewModel

    let blocks: FetchedResults<BlockEntity>
    @Binding var tabSelection: Int
    
    // Computed properties
    var totalUsageToday: TimeInterval {
        blocks.reduce(0) { usage, block in
            usage + block.records.filtered(by: .now).reduce(0) { $0 + $1.duration }
        }
    }
    
    var screenTimeGoal: TimeInterval {
        vm.user?.goal(for: .now) ?? 3600
    }
    
    var isAnyOpen: Bool {
        (blocks.first(where: { $0.isOpen == true }) != nil)
    }
    
    var sortedBlocksByUsage: [BlockEntity] {
        blocks.sorted {
            $0.records.filtered(by: .now).reduce(0) { $0 + $1.duration } > $1.records.filtered(by: .now).reduce(0) { $0 + $1.duration }
        }
    }
    
    var isYesterdayReviewed: Bool {
        if let user = vm.user {
            return CoreDataStack.shared.isReviewed(from: user)
        } else {
            return false
        }
    }
    
    @State private var showYesterdayReview: Bool = false
    
    @State private var showProfile: Bool = false
    
    @State private var appearAnimation: Bool = false
    
    @State private var selectedTab: HomeTab = .block
    
    @State private var selectedDate: DateSelection? = nil
    
    @State private var showFocusSession: Bool = false
    
    @State private var showStreak: Bool = false
    
    @Namespace var nspace
                
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                                        
                    VStack(spacing: 14) {
                        
                        WeekView()
                        
                        VStack(spacing: 0) {
                            ProgressCircle()
                            
                            FocusSessionButton()
                                .padding([.horizontal, .bottom])
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .foregroundStyle(Theme.foregroundC)
                        }
                        .padding(.top)
                    }
                                        
                    YesterdayReview()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("My Blocks")
                                .font(.grotesk(.title3, weight: .semibold))
                                .foregroundStyle(.textC)
                            
                            Spacer()
                            
                            Button {
                                tabSelection = 1
                            } label: {
                                Text("See all")
                                    .font(.grotesk(.subheadline, weight: .medium))
                                    .foregroundStyle(.secondary.opacity(0.8))
                            }
                            .tint(.primary)
                        }

                        HStack(spacing: 6) {
                            HStack(spacing: -16) {
                                ForEach(blocks.prefix(3)) { block in
                                    if let string = block.appTokenString, let token = ApplicationToken.fromRawValue(string) {
                                        Label(token)
                                            .labelStyle(.iconOnly)
                                            .scaleEffect(2.0)
                                            .frame(square: 40)
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .stroke(lineWidth: 2.0)
                                                    .foregroundStyle(Theme.foregroundC)
                                            }
                                    }
                                }
                            }
                            
                            if blocks.count > 3 {
                                Text("+ \(blocks.count - 3)")
                                    .font(.grotesk(size: 14, weight: .semibold))
                                    .foregroundStyle(.secondary)
                            }
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .foregroundStyle(Theme.foregroundC)
                    }
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Today")
                        .font(.grotesk(size: 20, weight: .semibold))
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
//                        showProfile = true
                    } label: {
                        Image(systemName: "person.fill")
                            .fontWeight(.medium)
                    }
                    .tint(Color.primary)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showStreak = true
                    } label: {
                        HStack(spacing: 4) {
                            Text("\(vm.currentStreak)")
                                .font(.grotesk(size: 16, weight: .semibold))
                            
                            LottieView(animation: .named("fire"))
                                .looping()
                                .frame(square: 18)
                        }
                    }
                    .tint(.orange)
                }
            }
            .sheet(isPresented: $showFocusSession) {
                FocusSessionPicker(blocks: blocks)
                    .presentationDetents([.height(650)])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showYesterdayReview) {
                YesterdayScreenView(blocks: blocks)
            }
            .sheet(isPresented: $showProfile) {
                ProfileScreenView()
            }
            .sheet(isPresented: $showStreak) {
                StreaksView()
            }
            .sheet(item: $selectedDate) { selection in
                DayScreenView(blocks: blocks, selection: selection)
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.height(650)])
            }
            .onAppear(perform: setup)
        }
    }
    
    // MARK: - Functions
    private func setup() {        
        SleepTask.sleep(seconds: 0.1) {
            withAnimation(.smooth(duration: 0.6, extraBounce: 0.25)) {
                appearAnimation = true
            }
        }
    }
    
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
                let goal: TimeInterval = vm.user?.goal(for: weekday) ?? 3600
                
                let screenTime = blocks.reduce(0) { usage, block in
                    usage + block.records.filtered(by: weekday).reduce(0) { $0 + $1.duration }
                }
                
                let isBeforeDownload: Bool = calendar.startOfDay(for: weekday) < calendar.startOfDay(for: vm.user?.dateCreated ?? .now)
                let underLimit: Bool = screenTime <= goal
                let isFuture: Bool = weekday > Date.now
                
                VStack(spacing: 10) {
                    Text(weekday.formatted(components: [.weekday]).uppercased())
                        .kerning(1.0)
                        .font(.grotesk(.caption2, weight: .semibold))
                        .foregroundStyle(isToday ? Color.primary : Color.secondary.opacity(0.65))
                    
                    Circle()
                        .foregroundStyle(isBeforeDownload || isFuture ? Color.secondary.opacity(0.5) : isToday ? Color.secondary : underLimit ? Color.blueAccent : Color.red)
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
                                        Color.blueAccent,
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
//                .onTapGesture {
//                    selectedDate = .init(date: weekday)
//                }
            }
        }
        .padding(.horizontal, 8)
    }
    
    @ViewBuilder
    private func ProgressCircle() -> some View {
        let remaining: TimeInterval = max(screenTimeGoal - totalUsageToday, 0)
        let progress: CGFloat = min(1, totalUsageToday / max(1, screenTimeGoal))
        
        let isLimit: Bool = progress >= 1
        let rotation = 360 * progress
        
        let color: Color = isLimit ? .gray : progress > 0.8 ? .orange : .blueAccent

        GeometryReader { geometry in
            let width = geometry.size.width
            
            Circle()
                .stroke(lineWidth: 48)
                .frame(square: width * 0.75)
                .foregroundStyle(color.opacity(0.15))
                .overlay {
                    Circle()
                        .stroke(lineWidth: 2)
                        .foregroundStyle(color.opacity(0.15))
                                        
                    Circle()
                        .trim(from: appearAnimation ? progress : 0.0, to: 1)
                        .stroke(style: .init(lineWidth: 38, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .foregroundStyle(color)
                        .brightness(isAnyOpen ? 0.15 : 0.0)
                        .animation(.smooth, value: isAnyOpen)
                }
                .overlay {
                    Circle()
                        .frame(square: 32)
                        .brightness(-0.3)
                        .overlay {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(color)
                        }
                        .offset(y: -(width * 0.75) / 2)
                        .rotationEffect(.degrees(appearAnimation ? rotation : 0.0))
                        .foregroundStyle(color)
                }
                .overlay {
                    Circle()
                        .frame(square: 32)
                        .brightness(-0.3)
                        .overlay {
                            Image(systemName: "flag.pattern.checkered")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(color)
                        }
                        .offset(y: -(width * 0.75) / 2)
                        .foregroundStyle(color)
                        .opacity(progress > 0.05 && progress < 0.95 ? 1.0 : 0.0)
                }
                .overlay {
                    VStack(spacing: 2) {
                        Text("\(TimeFormatter.display(screenTimeGoal, style: .short)) limit".uppercased())
                            .font(.grotesk(size: 12, weight: .semibold))
                            .kerning(1.0)
                            .foregroundStyle(.secondary)
                        
                        Text("\(TimeFormatter.display(remaining, style: .short))")
                            .font(.grotesk(size: 48, weight: .semibold))
                            .foregroundStyle(.textC)
                            .contentTransition(.numericText(value: totalUsageToday))
                            .animation(.smooth, value: totalUsageToday)
                        
                        Text(isLimit ? "Limit reached" :  progress > 0.8 ? "Approaching Limit" : "Remaining")
                            .font(.grotesk(size: 16, weight: .semibold))
                            .foregroundStyle(color.opacity(0.65))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(maxHeight: .infinity, alignment: .center)
        }
        .aspectRatio(1/1, contentMode: .fit)
    }
    
    @ViewBuilder
    private func FocusSessionButton() -> some View {
        Button {
            showFocusSession = true
        } label: {
            Capsule(style: .continuous)
                .foregroundStyle(.secondary.opacity(0.15))
                .frame(height: 48)
                .overlay {
                    Text("Start a Focus Session")
                        .font(.grotesk(size: 17, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
        }
        .tint(.primary)
    }
    
    @ViewBuilder
    private func YesterdayReview() -> some View {
        let dateCreated = vm.user?.dateCreated ?? .now
        
        if (Date().timeIntervalSince(dateCreated) >= 48 * 3600) {
            let yesterdayTotalUsage: TimeInterval = blocks.reduce(0) { usage, block in
                usage + block.records.filtered(by: .yesterday).reduce(0) { $0 + $1.duration }
            }
            let dailyGoal: TimeInterval = vm.user?.goal(for: .yesterday) ?? 3600

            // The account is at least 48 hours old, show the yesterday review.
            VStack(alignment: .trailing, spacing: 16) {
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Yesterday's Review")
                            .font(.grotesk(.title3, weight: .semibold))
                            .foregroundStyle(.textC)
                        
                        Text(yesterdayUsageMessage(usage: yesterdayTotalUsage, dailyGoal: dailyGoal))
                            .font(.grotesk(.body, weight: .regular))
                            .lineSpacing(4.0)
                            .foregroundStyle(.textC)
                            .opacity(0.8)
                    }
                    .padding(.trailing, 128)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 6)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .overlay(alignment: .trailing) {
                    Circle()
                        .stroke(lineWidth: 20)
                        .frame(square: 100)
                        .foregroundStyle(Color.secondary.opacity(0.15))
                        .overlay {
                            Circle()
                                .stroke(lineWidth: 2)
                                .foregroundStyle(Color.secondary.opacity(0.15))
                        }
                        .overlay {
                            if yesterdayTotalUsage <= 3600 {
                                Text(TimeFormatter.display(yesterdayTotalUsage, style: .short))
                                    .font(.grotesk(size: 28, weight: .semibold))
                                    .foregroundStyle(.textC)
                            } else {
                                Text(TimeFormatter.display(yesterdayTotalUsage, style: .short))
                                    .font(.grotesk(size: 18, weight: .semibold))
                                    .foregroundStyle(.textC)
                            }
                        }
                        .padding(.trailing, 8)
                }
                .frame(height: 128)

                HStack(spacing: 12) {
                    if isYesterdayReviewed {
                        Button {
                            showYesterdayReview = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "play.fill")
                                    .font(.grotesk(size: 14, weight: .semibold))
                                
                                Text("Review again")
                            }
                        }
                        .buttonStyle(.bordered)
                        .tint(.gray)
                        .font(.grotesk(size: 16, weight: .semibold))
                    } else {
                        Button {
                            showYesterdayReview = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "play.fill")
                                    .font(.grotesk(size: 14, weight: .semibold))
                                
                                Text("Review")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .font(.grotesk(size: 16, weight: .semibold))
                    }
                }
                .padding(.horizontal, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .foregroundStyle(Theme.foregroundC)
            }

        } else {
            let interval = max(0, 48 * 3600 - Date().timeIntervalSince(dateCreated))
            let hoursLeft = Int(ceil(interval / 3600))
            
            VStack(alignment: .trailing, spacing: 16) {
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Review Coming Soon")
                            .font(.grotesk(.title3, weight: .semibold))
                            .foregroundStyle(.textC)
                        
                        Text("We will start showing you your daily review in \(hoursLeft) hours.")
                            .font(.grotesk(.body, weight: .regular))
                            .lineSpacing(4.0)
                            .foregroundStyle(.textC)
                            .opacity(0.8)
                    }
                    .padding(.trailing, 128)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 6)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .overlay(alignment: .trailing) {
                    Circle()
                        .stroke(lineWidth: 20)
                        .frame(square: 100)
                        .foregroundStyle(Color.indigo.opacity(0.15))
                        .overlay {
                            Circle()
                                .stroke(lineWidth: 2)
                                .foregroundStyle(Color.indigo.opacity(0.15))
                        }
                        .overlay {
                            Text("\(hoursLeft)h")
                                .font(.grotesk(size: 28, weight: .semibold))
                                .foregroundStyle(.indigo)
                        }
                        .padding(.trailing, 8)
                }
                .frame(height: 128)
                
                ProgressView(
                    timerInterval: dateCreated...dateCreated.addingTimeInterval(48 * 3600),
                    countsDown: true
                )
                .tint(.indigo)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .foregroundStyle(Theme.foregroundC)
            }

        }

    }
    
    func yesterdayUsageMessage(
        usage: TimeInterval,
        dailyGoal: TimeInterval
    ) -> String {

        let formatted = TimeFormatter.display(usage, style: .short)

        // 1. Perfect day
        if usage <= 0 {
            return "You didn’t use any apps yesterday. Great job staying focused."
        }

        // 2. Under goal
        if usage < dailyGoal {
            return "You used your apps for \(formatted) yesterday. Nice work staying under your limit."
        }

        // 3. Slightly over goal
        if usage < dailyGoal * 1.25 {
            return "You used your apps for \(formatted) yesterday. A little over your limit."
        }

        // 4. Well over goal
        return "You used your apps for \(formatted) yesterday. Let’s aim for less today."
    }

}

#Preview {
    TabNavView()
        .environmentObject(UserViewModel())
        .environmentObject(ToastManager())
}
