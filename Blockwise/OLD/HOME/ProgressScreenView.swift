//
//  ProgressScreenView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 13/12/25.
//

import SwiftUI

struct ProgressScreenView: View {
    @EnvironmentObject var vm: UserViewModel
    @State private var showSettings: Bool = false
    
    let blocks: FetchedResults<BlockEntity>
    
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    @State private var showFullCalendar: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 10) {
                        Text(vm.user?.name ?? "Guest")
                            .font(.grotesk(size: 20, weight: .semibold))
                            .foregroundStyle(.textC)
                                                
                        HStack(spacing: 0) {
                            VStack(spacing: 4) {
                                Text("Best Streak")
                                    .font(.grotesk(.footnote, weight: .medium))
                                    .foregroundStyle(.secondary)
                                
                                Text("\(vm.bestStreak)")
                                    .font(.grotesk(size: 32, weight: .semibold))
                                    .foregroundStyle(.textC)
                            }
                            .frame(maxWidth: .infinity)

                            VStack(spacing: 4) {
                                Text("Achievements")
                                    .font(.grotesk(.footnote, weight: .medium))
                                    .foregroundStyle(.secondary)
                                
                                Text("0")
                                    .font(.grotesk(size: 32, weight: .semibold))
                                    .foregroundStyle(.textC)
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(spacing: 4) {
                                Text("Current Streak")
                                    .font(.grotesk(.footnote, weight: .medium))
                                    .foregroundStyle(.secondary)
                                
                                Text("\(vm.currentStreak)")
                                    .font(.grotesk(size: 32, weight: .semibold))
                                    .foregroundStyle(.textC)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .overlay(alignment: .top) {
                        Circle()
                            .frame(square: 88)
                            .foregroundStyle(Color(UIColor.secondarySystemGroupedBackground))
                            .overlay {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 80, weight: .medium))
                                    .foregroundStyle(Color(UIColor.secondarySystemBackground), .gray.opacity(0.5))
                            }
                            .offset(y: -94)
                    }
                    .padding(.top, 32)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .foregroundStyle(Theme.foregroundC)
                    }
                    .padding(.top, 24)
                    
                    VStack(spacing: 14) {
                        HStack {
                            Text("Calendar")
                                .font(.grotesk(.title3, weight: .semibold))
                                .foregroundStyle(.textC)
                            
                            Spacer()
                            
                            Button {
                                showFullCalendar = true
                            } label: {
                                Text("See all")
                                    .font(.grotesk(.subheadline, weight: .medium))
                                    .foregroundStyle(.secondary.opacity(0.8))
                            }
                            .tint(.primary)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 18) {
                            LazyVGrid(columns: columns, spacing: 18) {
                                ForEach(Calendar.current.last14Days(), id: \.self) { date in
                                    let isToday = Calendar.current.isDateInToday(date)
                                    let goal: TimeInterval = vm.user?.goal(for: date) ?? 3600
                                    
                                    let screenTime = blocks.reduce(0) { usage, block in
                                        usage + block.records.filtered(by: date).reduce(0) { $0 + $1.duration }
                                    }
                                    let underLimit: Bool = screenTime <= goal
                                    let isBeforeDownload: Bool = Calendar.current.startOfDay(for: date) < Calendar.current.startOfDay(for: vm.user?.dateCreated ?? .now)

                                    VStack(spacing: 10) {
                                        Text(date.formatted(.dateTime.day()))
                                            .font(.grotesk(.subheadline, weight: .semibold))
                                            .foregroundStyle(isToday ? Color.textC : Color.secondary.opacity(0.7))

                                        Circle()
                                            .foregroundStyle(isBeforeDownload ? Color.secondary.opacity(0.5) : isToday ? Color.secondary : underLimit ? Color.blueAccent : Color.red)
                                            .opacity(0.15)
                                            .overlay {
                                                if isToday {
                                                    
                                                } else if isBeforeDownload {
                                                    
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
                                            .padding(.horizontal, 4)
                                    }
                                }
                            }
                            
                            HStack(spacing: 18) {
                                HStack {
                                    Circle()
                                        .frame(square: 8)
                                        .foregroundStyle(Color.blueAccent)
                                    Text("Under Limit")
                                        .font(.grotesk(.caption, weight: .regular))
                                        .foregroundStyle(.secondary)
                                }

                                HStack {
                                    Circle()
                                        .frame(square: 8)
                                        .foregroundStyle(Color.red)
                                    Text("Over Limit")
                                        .font(.grotesk(.caption, weight: .regular))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .foregroundStyle(Theme.foregroundC)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .tint(.primary)
                }

            }
            .sheet(isPresented: $showFullCalendar) {
                FullCalendarView(blocks: blocks)
            }
            .sheet(isPresented: $showSettings) {
                SettingScreenView()
            }
        }
    }
}

#Preview {
    ProgressScreenViewPreview()
}

private struct ProgressScreenViewPreview: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BlockEntity.dateCreated, ascending: false)],
        animation: .default
    )
    private var blocks: FetchedResults<BlockEntity>
    
    var body: some View {
        ProgressScreenView(blocks: blocks)
            .environmentObject(UserViewModel())
    }
}

extension Calendar {
    func last14Days() -> [Date] {
        let today = startOfDay(for: Date())
        return (0..<14)
            .compactMap { date(byAdding: .day, value: -$0, to: today) }
            .reversed()
    }
}

extension Calendar {
    
    func startOfMonth(for date: Date) -> Date? {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components)
    }
    
    func daysInMonth(for date: Date) -> Int {
        range(of: .day, in: .month, for: date)?.count ?? 0
    }
    
    func weekdayOffset(for date: Date) -> Int {
        guard let firstDay = startOfMonth(for: date) else { return 0 }
        let weekday = component(.weekday, from: firstDay)
        return max(weekday - 1, 0) // Sunday = 0
    }
    
    func datesForMonthGrid(for date: Date) -> [Date?] {
        guard let start = startOfMonth(for: date) else { return [] }
        
        let days = daysInMonth(for: date)
        let offset = weekdayOffset(for: date)
        
        var grid: [Date?] = Array(repeating: nil, count: offset)
        
        for day in 0..<days {
            if let nextDate = self.date(byAdding: .day, value: day, to: start) {
                grid.append(nextDate)
            }
        }
        
        return grid
    }
}

struct FullCalendarView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: UserViewModel
    
    let blocks: FetchedResults<BlockEntity>
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    @State private var displayedMonth: Date = Calendar.current.startOfMonth(for: .now) ?? .now
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - Month Header
                    HStack {
                        Button {
                            if let prev = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonth),
                               let normalized = Calendar.current.startOfMonth(for: prev) {
                                displayedMonth = normalized
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        
                        Spacer()
                        
                        Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                            .font(.grotesk(.title3, weight: .semibold))
                        
                        Spacer()
                        
                        Button {
                            if let next = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonth),
                               let normalized = Calendar.current.startOfMonth(for: next) {
                                displayedMonth = normalized
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Weekday Labels
                    LazyVGrid(columns: columns) {
                        ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { day in
                            Text(day.uppercased())
                                .font(.grotesk(.caption2, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // MARK: - Calendar Grid
                    VStack(spacing: 18) {
                        LazyVGrid(columns: columns, spacing: 18) {
                            let gridDates = Calendar.current.datesForMonthGrid(for: displayedMonth)
                            
                            ForEach(gridDates.indices, id: \.self) { index in
                                if let date = gridDates[index] {
                                    
                                    let isToday = Calendar.current.isDateInToday(date)
                                    let goal = vm.user?.goal(for: date) ?? 3600
                                    
                                    let screenTime = blocks.reduce(0) { usage, block in
                                        usage + block.records.filtered(by: date).reduce(0) { $0 + $1.duration }
                                    }
                                    
                                    let underLimit = screenTime <= goal
                                    let isBeforeDownload =
                                        Calendar.current.startOfDay(for: date) <
                                        Calendar.current.startOfDay(for: vm.user?.dateCreated ?? .now)
                                    let isFuture: Bool = date > Date.now
                                    
                                    VStack(spacing: 8) {
                                        Text(date.formatted(.dateTime.day()))
                                            .font(.grotesk(.subheadline, weight: .semibold))
                                            .foregroundStyle(isToday ? .textC : .secondary)
                                        
                                        Circle()
                                            .foregroundStyle(isBeforeDownload || isFuture ? Color.secondary.opacity(0.5) : isToday ? Color.secondary : underLimit ? Color.blueAccent : Color.red)
                                            .opacity(0.15)
                                            .overlay {
                                                if !isBeforeDownload && !isToday && !isFuture {
                                                    if underLimit {
                                                        CheckmarkShape(trimEnd: 1.0)
                                                            .stroke(
                                                                Color.blueAccent,
                                                                style: StrokeStyle(
                                                                    lineWidth: 3,
                                                                    lineCap: .round,
                                                                    lineJoin: .round
                                                                )
                                                            )
                                                            .frame(square: 16)
                                                    } else {
                                                        Image(systemName: "xmark")
                                                            .font(.system(size: 14, weight: .semibold))
                                                            .foregroundStyle(.red)
                                                    }
                                                }
                                            }
                                            .padding(.horizontal, 4)
                                    }
                                } else {
                                    Color.clear
                                        .frame(height: 44)
                                }
                            }
                        }
                        
                        HStack(spacing: 18) {
                            HStack {
                                Circle()
                                    .frame(square: 8)
                                    .foregroundStyle(Color.blueAccent)
                                Text("Under Limit")
                                    .font(.grotesk(.caption, weight: .regular))
                                    .foregroundStyle(.secondary)
                            }

                            HStack {
                                Circle()
                                    .frame(square: 8)
                                    .foregroundStyle(Color.red)
                                Text("Over Limit")
                                    .font(.grotesk(.caption, weight: .regular))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .foregroundStyle(Theme.foregroundC)
                    }
                }
                .padding()
            }
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
        }
    }
}
