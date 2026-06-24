//
//  CustomizationView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 02/02/26.
//

import SwiftUI

struct CustomizationView: View {
    @AppStorage(AppStorageKeys.Settings.appTheme.key) var appTheme: AppTheme = .light

    @State private var showThemePicker: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Button {
                    showThemePicker = true
                } label: {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .frame(height: 78)
                        .foregroundStyle(Theme.foregroundC)
                        .overlay {
                            HStack {
                                Text("Theme")
                                    .font(.grotesk(.title2, weight: .semibold))
                                    .foregroundStyle(.textC)
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    Text(appTheme.rawValue.capitalized)
                                        .font(.grotesk(.body, weight: .regular))
                                        .foregroundStyle(.secondary)
                                    
                                    Image(systemName: "chevron.up.chevron.down")
                                        .foregroundStyle(.secondary).opacity(0.5)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                }
                .tint(.primary)
            }
            .padding()
        }
        .sheet(isPresented: $showThemePicker) {
            ThemePicker()
                .presentationDetents([.height(160)])
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)

    }
    
    @ViewBuilder
    private func ThemePicker() -> some View {
        VStack(spacing: 32) {
            Text("Change theme")
                .font(.grotesk(.title3, weight: .semibold))
            
            Picker(selection: $appTheme) {
                ForEach(AppTheme.allCases, id: \.rawValue) { theme in
                    Text(theme.rawValue.capitalized)
                        .tag(theme)
                }
            } label: {
                Text("Theme selection")
            }
            .pickerStyle(.segmented)
        }
        .padding(32)
    }
    
}

#Preview {
    CustomizationView()
}
