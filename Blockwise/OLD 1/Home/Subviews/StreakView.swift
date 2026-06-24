//
//  StreakView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 15/07/25.
//

import SwiftUI
import Lottie

struct SelectedDay: Identifiable {
    let id = UUID()
    let date: Date
}

struct StreakView: View {

    @EnvironmentObject var vm: UserViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @FetchRequest(sortDescriptors: [])
    private var records: FetchedResults<RecordEntity>
    
    var goal: TimeInterval {
        vm.user?.screenTimeGoal ?? 0
    }
    
    var dateJoined: Date {
        vm.user?.dateCreated ?? Date.now
    }
    
    let calendar = Calendar.current
    @State private var currentMonth = Date() // Or change to a specific month

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    @State private var selectedDate: SelectedDay?
    
    let sectionbackgrund: Color = Color(hex: 0xFAF6F4)
    let accentColor: Color = Color.primaryOrange

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    
                    VStack(spacing: 16) {
                        LottieView(animation: .named("fire"))
                            .looping()
                            .animationSpeed(vm.currentStreak == 0 ? 0.25 : 1.0)
                            .frame(square: 100)
                            .makeReflection(size: 100)
                        
                        VStack(spacing: 0) {
                            Text("\(vm.currentStreak)")
                                .font(.grotesk(size: 100, weight: .semibold))
//                                .font(.system(size: 100, weight: .bold))
                                .frame(height: 100)
                                .foregroundStyle(accentColor)
                            
                            Text("day streak")
                                .font(.grotesk(.title, weight: .semibold))
//                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(accentColor)
                        }
                    }
                    .grayscale(vm.currentStreak == 0 ? 1 : 0)
                    
                    Space(height: 10)
                    
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 16) {
                            LazyVGrid(columns: columns, spacing: 10) {
                                // Weekday labels
                                ForEach(Weekday.allCases, id: \.self) { day in
                                    Text(day.rawValue.prefix(1).uppercased())
                                        .font(.grotesk(.footnote, weight: .regular))
//                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity)
                                }
                                
                                ForEach(daysThisWeek(), id: \.self) { date in
                                    if let date = date {
                                        let total = totalDuration(for: date)
                                        let success = total <= goal
//                                        let hasRecord = hasAnyRecord(on: date)
                                        let today = calendar.isDateInToday(date)
                                        let isBeforeDownload = Calendar.current.startOfDay(for: date) < Calendar.current.startOfDay(for: dateJoined)
                                        let isFuture = Calendar.current.startOfDay(for: date) > Calendar.current.startOfDay(for: Date.now)
                                        let isInvalid = isInvalidDay(date)
                                        
                                        Button {
                                            selectedDate = SelectedDay(date: date)
                                        } label: {
                                            VStack(spacing: 10) {
                                                Circle()
                                                    .foregroundStyle(
                                                        isInvalid ? Color.red.opacity(0.15) :
                                                        isBeforeDownload ? Color.secondary.opacity(0.10) :
                                                            isFuture ?  Color.secondary.opacity(0.15) :
                                                            success ? Color.green.opacity(0.15) : Color.red.opacity(0.15)
                                                    )
                                                    .overlay {
                                                        if isInvalid {
                                                            Image(systemName: "xmark")
                                                                .font(.system(size: 18, weight: .medium))
                                                                .foregroundStyle(.red)
                                                        } else if isBeforeDownload {
                                                            Text("\(calendar.component(.day, from: date))")
                                                                .font(.grotesk(.subheadline, weight: .medium))
                                                                .foregroundStyle(Color.secondary.opacity(0.25))
                                                        } else if isFuture {
                                                            Text("\(calendar.component(.day, from: date))")
                                                                .font(.grotesk(.subheadline, weight: .medium))
                                                                .foregroundStyle(Color.secondary.opacity(0.65))
                                                        } else if success, !today {
                                                            let checkSize: CGFloat = 32.0
                                                            
                                                            CheckmarkShape(trimEnd: 1.0)
                                                                .trim(from: 0.0, to: 1.0)
                                                                .stroke(
                                                                    .green,
                                                                    style: StrokeStyle(
                                                                        lineWidth: checkSize / 14,
                                                                        lineCap: .round,
                                                                        lineJoin: .round
                                                                    )
                                                                )
                                                                .frame(square: checkSize / 2.0)

                                                        } else {
                                                            Text("\(calendar.component(.day, from: date))")
                                                                .font(.grotesk(.subheadline, weight: .medium))
                                                                .foregroundStyle(isFuture ? Color.secondary : success ? Color.green : Color.red)
                                                        }
                                                    }
                                                    .padding(2)
                                                
                                                Circle()
                                                    .frame(square: 6)
                                                    .opacity(today ? 1 : 0)
                                                    .foregroundStyle(isInvalid ? Color.red : success ? Color.green : Color.red)
                                            }
                                        }
                                        .tint(.primary)

                                    } else {
                                        Circle()
                                            .foregroundStyle(Color.clear)
                                            .padding(2)
                                    }
                                }
                            }
                                                        
                            if let user = vm.user {
                                let isInvalid = isInvalidDay(.now)
                                
                                if isInvalid {
                                    Divider()

                                    HStack(spacing: 8) {
                                        Image(systemName: "xmark")
                                            .font(.subheadline)
                                            .foregroundStyle(.red)
                                        
                                        Text("Streak got reset today")
                                            .font(.grotesk(.subheadline, weight: .regular))
//                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                } else if totalDuration(for: .now) <= user.screenTimeGoal {
                                    Divider()

                                    HStack(spacing: 8) {
                                        let checkSize: CGFloat = 32
                                        
                                        CheckmarkShape(trimEnd: 1.0)
                                            .trim(from: 0.0, to: 1.0)
                                            .stroke(
                                                .green,
                                                style: StrokeStyle(
                                                    lineWidth: checkSize / 14,
                                                    lineCap: .round,
                                                    lineJoin: .round
                                                )
                                            )
                                            .frame(square: checkSize / 2.0)
                                        
                                        Text("You're doing good today, keep going!")
                                            .font(.grotesk(.subheadline, weight: .regular))
//                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                } else {
                                    Divider()

                                    HStack(spacing: 8) {
                                        Image(systemName: "xmark")
                                            .font(.subheadline)
                                            .foregroundStyle(.red)
                                        
                                        Text("You surpassed the daily limit today")
                                            .font(.grotesk(.subheadline, weight: .regular))
//                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Theme.foregroundC, in: .rect(cornerRadius: 18))
                        
//                        HStack(spacing: 10) {
//                            Image(systemName: "lightbulb")
//
//                            Text("Stay under your daily screen time goal to keep your streak alive.")
//                                .font(.grotesk(.footnote, weight: .regular))
//    //                            .font(.footnote)
//                        }
//                        .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
//            .toolbar(edge: .trailing) {
//                Button {
//                    dismiss()
//                    Haptics.feedback(style: .rigid)
//                } label: {
//                    Image(systemName: "xmark")
//                }
//            }
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
            .sheet(item: $selectedDate) { date in
                SelectedDateView(date.date)
                    .presentationDetents([.height(300)])
            }
        }
    }
    
    private func isInvalidDay(_ date: Date) -> Bool {
        guard let user = vm.user else { return false }
        guard let lastStreakReset = user.lastStreakReset else { return false }
        return Calendar.current.startOfDay(for: date) == Calendar.current.startOfDay(for: lastStreakReset)
    }
        
    @ViewBuilder
    private func SelectedDateView(_ date: Date) -> some View {
        let total = totalDuration(for: date)
//        let success = total <= goal
//        let hasRecord = hasAnyRecord(on: date)
//        let today = calendar.isDateInToday(date)
//        let isBeforeDownload = Calendar.current.startOfDay(for: date) < Calendar.current.startOfDay(for: dateJoined)
//        let isFuture = Calendar.current.startOfDay(for: date) > Calendar.current.startOfDay(for: Date.now)
        
        NavigationStack {
            VStack(spacing: 32) {
                // Header section with improved spacing
//                VStack(spacing: 8) {
//                    Text(date.formatted(date: .abbreviated, time: .omitted))
//                        .font(.grotesk(.body, weight: .medium))
//                        .foregroundStyle(.secondary)
//                }
                                
                // Main content with enhanced presentation
                VStack(spacing: 16) {
                    Text(TimeFormatter.display(total, style: .short))
                        .font(.grotesk(size: 72, weight: .medium))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                    
                    // Optional: Add context or additional info
                    Text("Total Time")
                        .font(.grotesk(.caption, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        selectedDate = nil
                        Haptics.feedback(style: .rigid)
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
            .toolbarTitleDisplayMode(.inlineLarge)
        }
    }

    // MARK: - Helpers
    func totalDuration(for day: Date) -> TimeInterval {
        let start = calendar.startOfDay(for: day)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!

        return records
            .filter { record in
                guard let ts = record.timestamp else { return false }
                return ts >= start && ts < end
            }
            .reduce(0) { $0 + $1.duration }
    }

    func hasAnyRecord(on day: Date) -> Bool {
        let start = calendar.startOfDay(for: day)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!

        return records.contains { record in
            guard let ts = record.timestamp else { return false }
            return ts >= start && ts < end
        }
    }

    func paddedDaysInMonth(for month: Date) -> [Date?] {
        guard
            let range = calendar.range(of: .day, in: .month, for: month),
            let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))
        else {
            return []
        }

        let days = range.compactMap { day -> Date in
            calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)!
        }

        // Determine leading padding (weekday starts from Sunday=1 to Saturday=7, but we use Monday=1)
        let weekday = (calendar.component(.weekday, from: firstOfMonth) + 5) % 7 // 0=Monday

        let paddedDays: [Date?] = Array(repeating: nil, count: weekday) + days
        return paddedDays
    }

    func monthYearTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    func daysThisWeek() -> [Date?] {
        let today = calendar.startOfDay(for: Date())
        let weekdayIndex = calendar.component(.weekday, from: today) // 1=Sun ... 7=Sat
        // Convert to Monday-based offset: Monday -> 0, ..., Sunday -> 6
        let currentOffsetFromMonday = (weekdayIndex + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -currentOffsetFromMonday, to: today) else {
            return []
        }
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: monday)
        }
    }

}

#Preview {
    StreakView()
        .environmentObject(UserViewModel())
}
