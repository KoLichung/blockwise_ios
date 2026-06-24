//
//  ProfileScreenView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 01/12/25.
//

import SwiftUI
import RevenueCatUI

struct ProfileScreenView: View {
    @EnvironmentObject var vm: UserViewModel
    @EnvironmentObject var toastManager: ToastManager
    
    @State private var showCustomerCenter = false
    @State private var showFeedbackReportView = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        Circle()
                            .frame(square: 56)
                            .foregroundStyle(Color.secondary.gradient.opacity(0.5))
                            .overlay {
                                Text((vm.user?.name ?? "Guest").prefix(1).uppercased())
                                    .font(.grotesk(size: 28, weight: .medium))
                            }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(vm.user?.name ?? "Guest")
                                .font(.grotesk(.title3, weight: .medium))
                                .foregroundStyle(.textC)
                            
                            Group {
                                Text("Member since ") +
                                Text(vm.user?.dateCreated ?? .now, style: .date)
                            }
                            .font(.grotesk(.subheadline, weight: .regular))
                            .foregroundStyle(.secondary)
                        }
                    }
                }
                .listRowBackground(Theme.foregroundC)
                
                Section {
                    NavigationLink {
                        ScreenTimeSettingsView()
                    } label: {
                        Text("Screen Time")
                            .font(.grotesk(.body, weight: .medium))
                            .padding(.leading, 4)
                    }
                    
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        Text("Notifications")
                            .font(.grotesk(.body, weight: .medium))
                            .padding(.leading, 4)
                    }
                    
                }
                .listRowBackground(Theme.foregroundC)
                
                Section {
                    Button {
                        showFeedbackReportView = true
                    } label: {
                        Text("Report a problem")
                            .font(.grotesk(.body, weight: .medium))
                            .padding(.leading, 4)
                    }
                    
                    Button {
                        showCustomerCenter = true
                    } label: {
                        Text("Subscription")
                            .font(.grotesk(.body, weight: .medium))
                            .padding(.leading, 4)
                    }
                    
                }
                .listRowBackground(Theme.foregroundC)

                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Text("About \(AppConfiguration.name)")
                            .font(.grotesk(.body, weight: .medium))
                            .padding(.leading, 4)
                    }
                }
                .listRowBackground(Theme.foregroundC)

            }
            .scrollContentBackground(.hidden)
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(.grotesk(size: 20, weight: .semibold))
                }
            }
            .presentCustomerCenter(isPresented: $showCustomerCenter)
            .navigationBarTitleDisplayMode(.inline)
            .tint(.primary)
        }
        .sheet(isPresented: $showFeedbackReportView) {
            FeedbackReportView {
                Logger.success("Feedback Sent!")
                toastManager.success("Feedback Sent!")
            }
        }
    }
}

#Preview {
    ProfileScreenView()
        .environmentObject(UserViewModel())
        .environmentObject(ToastManager())
}

