//
//  ScreenTimeHistoryView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 19/08/25.
//

import SwiftUI
import ManagedSettings

struct ScreenTimeHistoryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: UserViewModel
    
    @State private var path: [Date] = [Date.now]
        
    @FetchRequest(sortDescriptors: [])
    private var records: FetchedResults<RecordEntity>
    
    var dateJoined: Date {
        vm.user?.dateCreated ?? Date.now
    }

    var body: some View {
        NavigationStack(path: $path) {
            DaysListView()
                .navigationDestination(for: Date.self) { value in
                    DayDetailView(day: value)
                }
        }
    }
    
    @ViewBuilder
    private func DaysListView() -> some View {
        let dates: [Date] = datesFromNow(to: dateJoined)
        
        List {
            ForEach(dates, id: \.self) { date in
                let isToday: Bool = Calendar.current.isDateInToday(date)
                let isYesterday: Bool = Calendar.current.isDateInYesterday(date)
                let data: [RecordEntity] = Array(records).filtered(by: date).sortedByMostRecent()
                let usage: TimeInterval = data.reduce(.zero) { $0 + $1.duration }

                Section {
                    NavigationLink(value: date) {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                if isToday {
                                    Text("Today")
                                        .font(.grotesk(.title, weight: .semibold))
                                } else if isYesterday {
                                    Text("Yesterday")
                                        .font(.grotesk(.title, weight: .semibold))
                                } else {
                                    Text(date.formatted(components: [.weekday, .separator, .day, .month]))
                                        .font(.grotesk(.title, weight: .semibold))
                                }
                                
                                Spacer()
                                
                                Text(TimeFormatter.display(usage, style: .short))
                                    .font(.grotesk(.body, weight: .regular))
                                    .opacity(0.65)
                            }
                        }
                    }
                }
                .listRowBackground(Theme.foregroundC)
            }
        }
        .scrollContentBackground(.hidden)
        .contentMargins(.top, 14)
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("History")
//        .toolbar(edge: .trailing) {
//            Button {
//                dismiss()
//                Haptics.feedback(style: .rigid)
//            } label: {
//                Image(systemName: "xmark")
//            }
//        }

    }
    
    @ViewBuilder
    private func DayDetailView(day: Date) -> some View {
//        let isToday: Bool = Calendar.current.isDateInToday(day)
//        let isYesterday: Bool = Calendar.current.isDateInYesterday(day)
        let data: [RecordEntity] = Array(records).filtered(by: day).sortedByMostRecent()
        let usage: TimeInterval = data.reduce(.zero) { $0 + $1.duration }
        
        List {
            
            if data.isEmpty {
                Section {
                    Text("No usage")
                        .font(.grotesk(.body, weight: .semibold))
                }
                .listRowBackground(Theme.foregroundC)
                .listRowSeparatorTint(Color.tertiaryBlue)
            }
        
            Section {
                ForEach(data) { record in
                    let timestamp = record.timestamp ?? Date.now
                    let endTime = timestamp.addingTimeInterval(record.duration)
                    
                    HStack(spacing: 10) {
                        if let block = record.block, let tokenString = block.appTokenString, let  appToken = ApplicationToken.fromRawValue(tokenString) {
                            Label(appToken)
                                .labelStyle(.iconOnly)
                                .scaleEffect(2.0)
                                .frame(square: 50)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
//                            Text(timeAgoString(from: endTime))
//                                .font(.grotesk(.body, weight: .semibold))
                            
                            if let block = record.block, let tokenString = block.appTokenString, let  appToken = ApplicationToken.fromRawValue(tokenString) {
                                Label(appToken)
                                    .labelStyle(.titleOnly)
                                    .scaleEffect(0.85, anchor: .leading)
                            }
                            
                            HStack(spacing: 6) {
                                Text(timestamp, style: .time)
                                    .font(.grotesk(.footnote, weight: .regular))
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 10))
                                
                                Text(endTime, style: .time)
                                    .font(.grotesk(.footnote, weight: .regular))
                            }
                            .foregroundStyle(.white.opacity(0.65))
                        }
                        
                        Spacer()
                        
                        Text(TimeFormatter.display(record.duration, style: .clock))
                            .font(.grotesk(size: 32, weight: .regular))
                            .foregroundStyle(.orange)

                    }
                }
                
            }
            .listRowBackground(Theme.foregroundC)
            .listRowSeparatorTint(Color.tertiaryBlue)
                            
        }
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .contentMargins(.top, 14)
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
//        .toolbar(edge: .center) {
//            Text(TimeFormatter.display(usage, style: .short))
//                .font(.grotesk(.body, weight: .semibold))
//        }
//        .toolbar(edge: .trailing) {
//            Button {
//                dismiss()
//                Haptics.feedback(style: .rigid)
//            } label: {
//                Image(systemName: "xmark")
//            }
//        }
    }
    
    func datesFromNow(to dayCreated: Date) -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.startOfDay(for: dayCreated)
        
        guard let daysBetween = calendar.dateComponents([.day], from: start, to: today).day else {
            return []
        }
        
        // Build array: [today, yesterday, ..., dayCreated]
        return (0...daysBetween).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: today)
        }
    }
    
    @ViewBuilder
    private func FormattedTimeWindow(record: RecordEntity) -> some View {
        let timestamp = record.timestamp ?? Date.now
        let endTime = timestamp.addingTimeInterval(record.duration)
        
        HStack(spacing: 6) {
            Text(timestamp, style: .time)
                .font(.grotesk(.footnote, weight: .regular))
            
            Image(systemName: "arrow.right")
                .font(.system(size: 10))
            
            Text(endTime, style: .time)
                .font(.grotesk(.footnote, weight: .regular))
        }
        .foregroundStyle(.white.opacity(0.65))
    }
    
    func timeAgoString(from date: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: date, to: now)
        
        if let day = components.day, day >= 1 {
            let formatter = DateFormatter()
            formatter.dateFormat = "E, d MMM" // Mon, 18 Aug
            return formatter.string(from: date)
        }
        
        if let hour = components.hour, hour >= 1 {
            return "\(hour) hr\(hour > 1 ? "s" : "") ago"
        }
        
        if let minute = components.minute, minute >= 1 {
            return "\(minute) min\(minute > 1 ? "s" : "") ago"
        }
        
        if let second = components.second {
            return "\(second) sec\(second > 1 ? "s" : "") ago"
        }
        
        return "just now"
    }

}

#Preview {
    ScreenTimeHistoryView()
        .environmentObject(UserViewModel())
}
