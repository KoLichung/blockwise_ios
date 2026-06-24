//
//  CreateBlockOneView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 12/08/25.
//

import SwiftUI
import Lottie
import FamilyControls

struct CreateBlockOneView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm = AddBlockUserViewModel()
    
    @State private var showFamilyControlPicker: Bool = false
    
    @State private var nextPage: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 56) {
                
                VStack(spacing: 32) {
                    let assetSize: CGFloat = 72

                    RoundedRectangle(cornerRadius: assetSize / 4.4, style: .continuous)
                        .frame(square: assetSize)
                        .opacity(0.15)
                        .overlay {
                            Image(systemName: "nosign")
                                .font(.system(size: 38, weight: .semibold))
                                .opacity(0.5)
                        }
                    
                    Text("Select the app you want to block:")
                        .font(.grotesk(.title, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2.0)
                }
                
                LottieView(animation: .named("point-down"))
                    .looping()
                    .frame(square: 100)
                    .frame(square: 150)
                
                GlassButton {
                    showFamilyControlPicker = true
                    vm.familyActivitySelection = FamilyActivitySelection()
                    Haptics.feedback(style: .light)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .fontWeight(.semibold)
                        Text("Search app")
                    }
                    .font(.grotesk(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                }

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 32)
            .padding(.vertical)
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
            .sheet(isPresented: $showFamilyControlPicker) {
                ActivityPickerView { selection in
                    vm.familyActivitySelection = selection
                    Logger.debug("App: \(vm.familyActivitySelection.applications.count)")
                    Logger.debug("App Tokens: \(vm.familyActivitySelection.applicationTokens.count)")
                    Logger.debug("Category: \(vm.familyActivitySelection.categories.count)")
                    Logger.debug("Category Tokens: \(vm.familyActivitySelection.categoryTokens.count)")
                    nextPage = true
                }
            }
            .navigationDestination(isPresented: $nextPage) {
                CreateBlockTwoView()
            }
        }
        .onAppear(perform: setup)
        .environmentObject(vm)
    }
    
    private func setup() {
        vm.dismiss = dismiss
    }
}

#Preview {
    NavigationStack {
        CreateBlockOneView()
    }
    .tint(Color.primary)
}
