//
//  SettingsView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 02/12/24.
//

import SwiftUI
import RevenueCatUI
import SuperwallKit

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
        
    @EnvironmentObject var vm: UserViewModel
    @EnvironmentObject var toastManager: ToastManager
    @EnvironmentObject var lnManager: LocalNotificationManager
    
//    @AppStorage(AppStorageKeys.showAlarmWarning.rawValue) var showAlarmWarning: Bool = true
    
    @StateObject private var superwall = Superwall.shared
        
    @State private var showFeedbackReportView = false
    @State private var mailErrorAlert = false
    
    @State private var showOB = false
    @State private var showCustomerCenter = false
    
    var body: some View {
        NavigationStack {
            List {
                                
                Section {
                    HStack(spacing: 14) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 56))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.secondary)
                            .frame(square: 56)
                        
                        if let user = vm.user, let dateCreated = user.dateCreated {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(vm.user?.name ?? "unknown")")
                                    .font(.grotesk(.title3, weight: .medium))
                                
                                Text("Joined \(dateCreated.formatted(components: [.monthFull, .day, .year]))")
                                    .font(.grotesk(.footnote, weight: .medium))
                                    .foregroundStyle(Color.secondary)
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("unknown")
                                    .font(.grotesk(.title3, weight: .medium))
                                
                                Text("there was an error loading your profile")
                                    .font(.grotesk(.footnote, weight: .medium))
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                    }
                }
                .listRowBackground(Theme.foregroundC)
                .listRowSeparatorTint(Color.tertiaryBlue)
                
                Section {
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        SettingRow(
                            systemName: "bell.badge.fill",
                            color: Color.red,
                            label: "Notifications"
                        )
                        .overlay(alignment: .trailing) {
//                            if !lnManager.isAlarmAuthGranted && showAlarmWarning {
//                                Image(systemName: "exclamationmark.circle.fill")
//                                    .font(.system(size: 20, weight: .semibold))
//                                    .foregroundStyle(.white, .red)
//                            }
                        }
                    }
                    
                    NavigationLink {
                        ScreenTimeSettingsView()
                    } label: {
                        SettingRow(
                            systemName: "hourglass.tophalf.filled",
                            color: Color.indigo,
                            label: "Screen Time"
                        )
                    }

                    NavigationLink {
                        AdvancedSettingsView()
                    } label: {
                        SettingRow(
                            systemName: "gearshape.fill",
                            color: Color.tertiaryBlue,
                            label: "Advanced Settings"
                        )
                    }
                }
                .listRowBackground(Theme.foregroundC)
                .listRowSeparatorTint(Color.tertiaryBlue)
                
                Section {
                    Button {
                        showFeedbackReportView = true
                    } label: {
                        SettingRow(
                            systemName: "envelope.fill",
                            color: .pink,
                            label: "Report a problem",
                            chevron: true
                        )
                    }
                    
                    Button {
                        showCustomerCenter = true
                    } label: {
                        SettingRow(
                            systemName: "person.fill.viewfinder",
                            color: Color.tertiaryBlue,
                            label: "Customer center",
                            chevron: true
                        )
                    }
                }
                .listRowBackground(Theme.foregroundC)
                .listRowSeparatorTint(Color.tertiaryBlue)
                
                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        SettingRow(
                            systemName: "info",
                            color: Color.primaryBlue,
                            label: "About \(AppConfiguration.name)"
                        )

                    }
                }
                .listRowBackground(Theme.foregroundC)
                .listRowSeparatorTint(Color.tertiaryBlue)
                
//                Button {
//                    Superwall.shared.register(placement: Placements.paywallDiscount.rawValue)
//                } label: {
//                    Text("Discount Paywall")
//                }
            }
            .contentMargins(.top, 14)
            .scrollContentBackground(.hidden)
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
            .sheet(isPresented: $showFeedbackReportView) {
                FeedbackReportView {
                    Logger.success("Feedback Sent!")
                    toastManager.success("Feedback Sent!")
                }
            }
            .fullScreenCover(isPresented: $showOB) {
                OBQuizView()
            }
            .navigationTitle("Profile")
            .alert("Mail services are not available", isPresented: $mailErrorAlert) {
                Button("OK", role: .cancel) { }
            }
            .presentCustomerCenter(isPresented: $showCustomerCenter)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toast(manager: toastManager)
    }
    
    @ViewBuilder
    private func SettingRow(systemName icon: String, color: Color, label: String, chevron: Bool = false) -> some View {
        HStack(spacing: 12) {
//            Icon(size: 30, systemName: icon)
//                .foregroundStyle(color)
//                .fontWeight(.semibold)
            
            Text(label)
                .font(.grotesk())
            
            if chevron {
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14).weight(.semibold))
                    .foregroundStyle(.secondary.opacity(0.45))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}

#Preview {
    SettingsView()
        .tint(.primary)
        .environmentObject(ToastManager())
        .environmentObject(UserViewModel())
        .environmentObject(LocalNotificationManager())
}

/*
 
 Section("Advanced") {
     NavigationLink {
         AdvancedSettingsView()
     } label: {
         SettingRow(
             systemName: "gearshape.fill",
             color: Color.secondaryOrange,
             label: "Advanced Settings"
         )
     }
 }
 .listRowBackground(Theme.foregroundC)
 .listRowSeparatorTint(Color.tertiaryBlue)
                 
 Section {
     
     NavigationLink {

     } label: {
         SettingRow(
             systemName: "lightbulb.fill",
             color: .brown,
             label: "Feature Requests"
         )

     }
     
     Button {
         showOB = true
     } label: {
         SettingRow(
             systemName: "arrow.counterclockwise",
             color: .indigo,
             label: "Redo Quiz"
         )
     }

 } header: {
     Text("Help & Support")
 } footer: {
     Text("Spotted a bug? Got a genius idea? You hate this app? Drop us a message, we read everything.")
 }
 .listRowBackground(Theme.foregroundC)
 .listRowSeparatorTint(Color.tertiaryBlue)

 Section("More") {
     Button {
         showOBSlider = true
     } label: {
         SettingRow(
             systemName: "megaphone.fill",
             color: .indigo,
             label: "What's New"
         )

     }
     .tint(.primary)
     
     NavigationLink {
         AboutView()
     } label: {
         SettingRow(
             systemName: "info",
             color: .purple,
             label: "About"
         )

     }
     
 }
 .listRowBackground(Theme.foregroundC)
 .listRowSeparatorTint(Color.tertiaryBlue)
 
 Button {
     showFeedbackReportView = true
 } label: {
     SettingRow(
         systemName: "info",
         color: Color.primaryBlue,
         label: "Feedback"
     )
 }
 .listRowBackground(Theme.foregroundC)
 .listRowSeparatorTint(Color.tertiaryBlue)

 
 */
