//
//  SettingScreenView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 02/12/25.
//

import SwiftUI

struct SettingScreenView: View {
        
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .frame(height: 78)
                        .foregroundStyle(Theme.foregroundC)
                        .overlay {
                            HStack {
                                Text("Customization")
                                    .font(.grotesk(.title2, weight: .semibold))
                                    .foregroundStyle(.textC)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(.subheadline, weight: .semibold))
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }
                            .padding(.horizontal, 24)
                        }
                    
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .frame(height: 78)
                        .foregroundStyle(Theme.foregroundC)
                        .overlay {
                            HStack {
                                Text("Health Data")
                                    .font(.grotesk(.title2, weight: .semibold))
                                    .foregroundStyle(.textC)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(.subheadline, weight: .semibold))
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }
                            .padding(.horizontal, 24)
                        }
                    
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .frame(height: 78)
                        .foregroundStyle(Theme.foregroundC)
                        .overlay {
                            HStack {
                                Text("Widgets")
                                    .font(.grotesk(.title2, weight: .semibold))
                                    .foregroundStyle(.textC)

                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(.subheadline, weight: .semibold))
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }
                            .padding(.horizontal, 24)
                        }
                    
                    VStack(alignment: .leading, spacing: 32) {
                        Text("FAQs")
                            .font(.grotesk(.title2, weight: .semibold))
                            .foregroundStyle(.textC)

                        Button {
                            
                        } label: {
                            HStack {
                                Text("Common issue")
                                    .font(.grotesk(.body, weight: .regular))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(.subheadline, weight: .semibold))
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }
                            .contentShape(.rect)
                        }
                        
                        Button {
                            
                        } label: {
                            HStack {
                                Text("Common issue")
                                    .font(.grotesk(.body, weight: .regular))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(.subheadline, weight: .semibold))
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }
                            .contentShape(.rect)
                        }

                        Button {
                            
                        } label: {
                            HStack {
                                Text("Common issue")
                                    .font(.grotesk(.body, weight: .regular))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(.subheadline, weight: .semibold))
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }
                            .contentShape(.rect)
                        }
                        
                        Button {
                            
                        } label: {
                            HStack {
                                Text("Common issue")
                                    .font(.grotesk(.body, weight: .regular))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(.subheadline, weight: .semibold))
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }
                            .contentShape(.rect)
                        }

                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(24)
                    .background {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .foregroundStyle(Theme.foregroundC)
                    }

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
                    }

                    VStack(alignment: .leading, spacing: 32) {
                        Text("More")
                            .font(.grotesk(.title2, weight: .semibold))
                            .foregroundStyle(.textC)

                        Button {
                            
                        } label: {
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
                        
                        Button {
                            
                        } label: {
                            HStack {
                                Text("Feature Requests")
                                    .font(.grotesk(.body, weight: .regular))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(.subheadline, weight: .semibold))
                                    .foregroundStyle(.secondary.opacity(0.5))
                            }
                            .contentShape(.rect)
                        }
                        
                        Button {
                            
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(24)
                    .background {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .foregroundStyle(Theme.foregroundC)
                    }

                }
                .padding()
            }
            .navigationTitle("Settings")
            .toolbarTitleDisplayMode(.inlineLarge)
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        }
    }

}

#Preview {
    SettingScreenView()
        .onAppear {
            //Use this if NavigationBarTitle is with Large Font
            UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: GroteskFontWeight.semibold.rawValue, size: 34)!]

            //Use this if NavigationBarTitle is with displayMode = .inline
            UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: GroteskFontWeight.semibold.rawValue, size: 17)!]
        }
}
