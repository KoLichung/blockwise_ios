//
//  LiveActivitiesView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 12/02/26.
//

import SwiftUI

struct LiveActivitiesView: View {
        
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 14) {
                            Circle()
                                .foregroundStyle(LocalNotificationManager.shared.isAlarmAuthGranted ? .green : .red)
                                .frame(square: 10)
                            
                            Group {
                                Text("Alarm: ") +
                                Text("\(LocalNotificationManager.shared.isAlarmAuthGranted ? "ON" : "OFF")").foregroundStyle(LocalNotificationManager.shared.isAlarmAuthGranted ? .green : .red)
                            }
                            .font(.grotesk(.body, weight: .semibold))
                        }
                        
                        Text("Alarm helps you track the remaining time in any app you open. A countdown appears in the Dynamic Island and Lock Screen, and an alert notifies you when time runs out.")
                            .font(.grotesk(.subheadline, weight: .regular))
                            .opacity(0.65)
                            .padding(.leading, 10 + 14)
                            .lineSpacing(2.0)
                    }
                    
                    if !LocalNotificationManager.shared.isAlarmAuthGranted {
                        VStack(spacing: 14) {
                            Button {
                                // Deep link to app settings
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                RoundedRectangle(cornerRadius: 100)
                                    .frame(height: 40)
                                    .foregroundStyle(Color.accentBlue)
                                    .overlay {
                                        Text("Turn On Alarm")
                                            .font(.grotesk(.body, weight: .semibold))
                                            .foregroundStyle(.white)
                                    }
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
            .listRowBackground(Theme.foregroundC)
        }
        .scrollContentBackground(.hidden)
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        .navigationTitle("Live Activities")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LiveActivitiesView()
            .environmentObject(LocalNotificationManager())
    }
}
