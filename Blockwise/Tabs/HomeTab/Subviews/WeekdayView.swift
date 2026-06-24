//
//  WeekdayView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 08/02/26.
//

import SwiftUI
import ManagedSettings

struct WeekdayView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userViewModel: UserViewModel
    
    @FetchRequest(sortDescriptors: [])
    private var allRecords: FetchedResults<RecordEntity>

    let day: Date
    
    var isToday: Bool {
        Calendar.current.isDateInToday(day)
    }
    
    var goal: TimeInterval {
        userViewModel.user?.goal(for: day) ?? 3600
    }
    
    var filteredRecords: [RecordEntity] {
        Array(allRecords).filtered(by: day)
    }
    
    var screenTime: TimeInterval {
        filteredRecords.reduce(0) { $0 + $1.duration }
    }
                    
    var isBeforeDownload: Bool {
        Calendar.current.startOfDay(for: day) < Calendar.current.startOfDay(for: userViewModel.user?.dateCreated ?? .now)
    }
    
    var underLimit: Bool {
        screenTime <= goal
    }
    
    var isFuture: Bool {
        day > Date.now
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    
                    VStack(spacing: 18) {
                        VStack(spacing: 10) {
                            HStack {
                                Text("Screen Time")
                                    .font(.grotesk(.body, weight: .regular))
                                
                                Spacer()
                                
                                Text(TimeFormatter.display(screenTime, style: .short))
                                    .font(.grotesk(.body, weight: .regular))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(24)
                        .background {
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .foregroundStyle(Theme.foregroundC)
                                .border(cornerRadius: 32)
                        }
                        
                        VStack(spacing: 10) {
                            HStack {
                                Text("Goal")
                                    .font(.grotesk(.body, weight: .regular))
                                
                                Spacer()
                                
                                Text(TimeFormatter.display(goal, style: .short))
                                    .font(.grotesk(.body, weight: .regular))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(24)
                        .background {
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .foregroundStyle(Theme.foregroundC)
                                .border(cornerRadius: 32)
                        }
                    }
                    
                    VStack(spacing: 18) {
                        VStack(spacing: 10) {
                            HStack {
                                Text("Usage history")
                                    .font(.grotesk(.body, weight: .regular))
                                
                                Spacer()
                                
                                Text(TimeFormatter.display(goal, style: .short))
                                    .font(.grotesk(.body, weight: .regular))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(24)
                        .background {
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .foregroundStyle(Theme.foregroundC)
                                .border(cornerRadius: 32)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                }
            }
            .navigationTitle(day.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview
#Preview {
    WeekdayView(day: .now)
        .environmentObject(UserViewModel())
}
