//
//  SettingsTabView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 01/02/26.
//

import SwiftUI

struct SettingsTabView: View {
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    NavigationLink {
                        CustomizationView()
                    } label: {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .frame(height: 78)
                            .foregroundStyle(Theme.foregroundC)
                            .border(cornerRadius: 26)
                            .overlay {
                                HStack {
                                    Text("Appearance")
                                        .font(.grotesk(.title2, weight: .semibold))
                                        .foregroundStyle(.textC)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(.subheadline, weight: .semibold))
                                        .foregroundStyle(.secondary.opacity(0.5))
                                }
                                .padding(.horizontal, 24)
                            }
                    }
                    .tint(.primary)
                    
                    NavigationLink {
                        ScreenTimeView()
                    } label: {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .frame(height: 78)
                            .foregroundStyle(Theme.foregroundC)
                            .border(cornerRadius: 26)
                            .overlay {
                                HStack {
                                    Text("Screen Time")
                                        .font(.grotesk(.title2, weight: .semibold))
                                        .foregroundStyle(.textC)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(.subheadline, weight: .semibold))
                                        .foregroundStyle(.secondary.opacity(0.5))
                                }
                                .padding(.horizontal, 24)
                            }
                    }
                    .tint(.primary)
                    
                    NavigationLink {
                        LiveActivitiesView()
                    } label: {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .frame(height: 78)
                            .foregroundStyle(Theme.foregroundC)
                            .border(cornerRadius: 26)
                            .overlay {
                                HStack {
                                    Text("Live Activities")
                                        .font(.grotesk(.title2, weight: .semibold))
                                        .foregroundStyle(.textC)

                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(.subheadline, weight: .semibold))
                                        .foregroundStyle(.secondary.opacity(0.5))
                                }
                                .padding(.horizontal, 24)
                            }
                    }
                    .tint(.primary)
                    
                    VStack(alignment: .leading, spacing: 32) {
                        Text("FAQs")
                            .font(.grotesk(.title2, weight: .semibold))
                            .foregroundStyle(.textC)

                        Button {
                            settingsViewModel.showFAQ1 = true
                        } label: {
                            HStack {
                                Text("Apps are no longer blocked")
                                    .font(.grotesk(.body, weight: .regular))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(.subheadline, weight: .semibold))
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }
                            .contentShape(.rect)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Button {
                            settingsViewModel.showFAQ2 = true
                        } label: {
                            HStack {
                                Text("Screen Time data is incorrect")
                                    .font(.grotesk(.body, weight: .regular))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(.subheadline, weight: .semibold))
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }
                            .contentShape(.rect)
                        }

                        Button {
                            settingsViewModel.showFAQ3 = true
                        } label: {
                            HStack {
                                Text("The schedule didn’t start")
                                    .font(.grotesk(.body, weight: .regular))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(.subheadline, weight: .semibold))
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }
                            .contentShape(.rect)
                        }
                        
                        Button {
                            settingsViewModel.showFAQ4 = true
                        } label: {
                            HStack {
                                Text("The widget isn’t updating")
                                    .font(.grotesk(.body, weight: .regular))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(.subheadline, weight: .semibold))
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }
                            .contentShape(.rect)
                        }

                    }
                    .tint(.primary.opacity(0.75))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(24)
                    .background {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .foregroundStyle(Theme.foregroundC)
                            .border(cornerRadius: 26)
                    }

                    Button {
                        if let url = URL(string: "https://apps.apple.com/app/id6630375265?action=write-review") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 24) {
                            HStack {
                                Text("Rate \(AppConfiguration.name)")
                                    .font(.grotesk(.title2, weight: .semibold))
                                    .foregroundStyle(.textC)

                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(.subheadline, weight: .semibold))
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }

                            Text("Love \(AppConfiguration.name)? Please\nleave a review—thanks!")
                                .font(.grotesk(.body, weight: .regular))
                                .padding(.bottom)
                                .foregroundStyle(.textC)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(24)
                        .background {
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .foregroundStyle(Theme.foregroundC)
                                .border(cornerRadius: 26)
                        }
                    }

                    VStack(alignment: .leading, spacing: 32) {
                        Text("More")
                            .font(.grotesk(.title2, weight: .semibold))
                            .foregroundStyle(.textC)
                        
                        ContactSupportButton {
                            HStack {
                                Text("Contact Us")
                                    .font(.grotesk(.body, weight: .regular))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(.subheadline, weight: .semibold))
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }
                            .contentShape(.rect)
                        }
                        
                        ContactSupportButton(subject: "App Feedback", bodyText: "Please share your thoughts and suggestions") {
                            HStack {
                                Text("Give a Feedback")
                                    .font(.grotesk(.body, weight: .regular))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(.subheadline, weight: .semibold))
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }
                            .contentShape(.rect)
                        }

                        ContactSupportButton(subject: "Feature Request", bodyText: "Please describe the feature you'd like to see") {
                            HStack {
                                Text("Request a Feature")
                                    .font(.grotesk(.body, weight: .regular))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(.subheadline, weight: .semibold))
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }
                            .contentShape(.rect)
                        }

                        NavigationLink {
                            AboutView()
                        } label: {
                            HStack {
                                Text("About \(AppConfiguration.name)")
                                    .font(.grotesk(.body, weight: .regular))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(.subheadline, weight: .semibold))
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }
                            .contentShape(.rect)
                        }

                    }
                    .tint(.primary.opacity(0.75))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(24)
                    .background {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .foregroundStyle(Theme.foregroundC)
                            .border(cornerRadius: 26)
                    }

                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        settingsViewModel.showUserView = true
                    } label: {
                        Image(systemName: "person.fill")
                            .fontWeight(.semibold)
                    }
                    .tint(.primary)
                }
            }
            .sheet(isPresented: $settingsViewModel.showFAQ1) {
                FAQView(faq: .appsNotBlocked)
            }
            .sheet(isPresented: $settingsViewModel.showFAQ2) {
                FAQView(faq: .screenTimeIncorrect)
            }
            .sheet(isPresented: $settingsViewModel.showFAQ3) {
                FAQView(faq: .scheduleDidNotStart)
            }
            .sheet(isPresented: $settingsViewModel.showFAQ4) {
                FAQView(faq: .widgetNotUpdating)
            }
            .sheet(isPresented: $settingsViewModel.showUserView) {
                UserView()
            }
            .navigationTitle("Settings")
            .toolbarTitleDisplayMode(.inlineLarge)
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        }
    }
}

#Preview {
    RootView(tabSelection: 2)
        .environmentObject(LocalNotificationManager())
}
