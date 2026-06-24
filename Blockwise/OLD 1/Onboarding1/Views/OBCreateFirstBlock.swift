//
//  OBCreateFirstBlock.swift
//  Blockwise
//
//  Created by Ivan Sanna on 12/09/25.
//

import SwiftUI
import Lottie
import FamilyControls

struct OBCreateFirstBlock: View {
//    @AppStorage(AppStorageKeys.tutorialShown.rawValue) var tutorialShown: Bool = false
    @StateObject private var vm = AddBlockUserViewModel()
    @EnvironmentObject var toastManager: ToastManager
    
    @State private var showFamilyControlPicker: Bool = false
    @State private var nextPage: Bool = false

    var body: some View {
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
                    
                    Text("Select the first app you want to block:")
                        .font(.grotesk(.title, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2.0)
                }
                
                LottieView(animation: .named("point-down"))
                    .looping()
                    .frame(square: 100)
                
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
            .padding(32)
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
            .safeAreaInset(edge: .bottom) {
                Text("The following list is provided by Apple and may occasionally crash.")
                    .multilineTextAlignment(.center)
                    .font(.grotesk(.footnote, weight: .regular))
                    .opacity(0.5)
                    .padding(.horizontal, 32)
                    .padding(.bottom)
            }
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
                OBCreateNext()
            }
            .environmentObject(vm)
    }
    
    @ViewBuilder
    private func OBCreateNext() -> some View {
        VStack(spacing: 56) {
            
            VStack(spacing: 56) {
                HStack(spacing: 32) {
                    
                    if let appToken = vm.familyActivitySelection.applicationTokens.first {
                        VStack(spacing: 8) {
                            Label(appToken)
                                .labelStyle(.iconOnly)
                                .scaleEffect(3.0)
                                .frame(square: 56)
                            
//                            Label(appToken)
//                                .labelStyle(.titleOnly)
//                                .scaleEffect(0.8)
                        }
                    }
                    
                }
                
                Text("Do you want to restrict access to this app?")
                    .font(.grotesk(.title, weight: .semibold))
                    .multilineTextAlignment(.center)
                                
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(Color.primaryBlue)
                        .offset(y: 1)

                    Text("We'll blur this app on your Home Screen and let you control how much time you spend on it.")
                        .font(.grotesk(.body, weight: .regular))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(Color.primaryBlue)
                        .lineSpacing(4.0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Theme.foregroundC, in: .rect(cornerRadius: 10, style: .continuous))
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 32) {
                GlassButton {
                    action()
                } label: {
                    HStack(spacing: 8) {
                        let checkSize: CGFloat = 36.0
                        
                        CheckmarkShape(trimEnd: 1.0)
                            .trim(from: 0.0, to: 1.0)
                            .stroke(
                                .white,
                                style: StrokeStyle(
                                    lineWidth: checkSize / 14,
                                    lineCap: .round,
                                    lineJoin: .round
                                )
                            )
                            .frame(square: checkSize / 2.0)
                        
                        Text("Confirm")
                    }
                    .font(.grotesk(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                }
                
                Button("No, switch app") {
                    nextPage = false
                    Haptics.feedback(style: .rigid)
                }
                .font(.grotesk(.body, weight: .medium))
                .opacity(0.65)
            }
        }
        .padding(32)
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)

    }
    
    private func action() {
        do {
            try vm.createBlock()
//            tutorialShown = true
            toastManager.info("Block applied.")
        } catch {
            Logger.error(error.localizedDescription)
            toastManager.error(error.localizedDescription)
        }
    }
}

#Preview {
    NavigationStack {
        OBCreateFirstBlock()
    }
    .tint(Color.primary)
}
