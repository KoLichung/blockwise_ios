//
//  OBQuizView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 23/06/25.
//

import SwiftUI

struct OBQuizView: View {
    @EnvironmentObject var vm: OBUserViewModel
    @StateObject private var toastManager = ToastManager()
    
    let height: CGFloat = UIScreen.main.bounds.height

    var body: some View {
        NavigationStack(path: $vm.path) {
            OBQuizOne()
                .navigationDestination(
                    for: Int.self,
                    destination: destination
                )
        }
        .overlay(alignment: .top) {
            Toolbar()
        }
        .overlay(alignment: .top) {
            ReportToolbar()
        }
        .overlay(alignment: .top) {
            SetupToolbar()
        }
        .overlay {
            FamilyAuthRequest()
        }
        .environmentObject(vm)
        .environmentObject(toastManager)
        .toast(manager: toastManager)
    }
    
    @ViewBuilder
    private func SetupToolbar() -> some View {
        HStack(spacing: 10) {
            ForEach(SetupPhase.allCases, id: \.self) { phase in
                let isCurrent: Bool = phase.rawValue <= vm.currentSetupProgress.rawValue
                
                HStack(spacing: 10) {
                    Image(systemName: "\(phase.rawValue + 1).circle.fill")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(.white, isCurrent ? Color.primaryBlue : .secondary.opacity(0.15))
                    
                    if phase.rawValue != SetupPhase.allCases.last!.rawValue {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.secondary.opacity(0.15))
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color.primaryBlue)
                                    .opacity(vm.currentSetupProgress.rawValue > phase.rawValue ? 1 : 0)
                            }
                            .frame(height: 4)
                    }
                }
                .opacity(vm.showSetupProgress ? 1 : 0)
                .offset(y: vm.showSetupProgress ? 0 : -64)
                .animation(.smooth(duration: 0.3, extraBounce: 0.35).delay(TimeInterval(Double(phase.rawValue) * 0.05)), value: vm.showSetupProgress == true)
                .animation(.smooth(duration: 0.3), value: vm.currentSetupProgress)
                
            }
        }
        .frame(height: 28)
        .padding(.horizontal, 64)
        .padding(.top, 10)
    }
    
    @ViewBuilder
    private func ReportToolbar() -> some View {
        HStack(spacing: 8) {
            ForEach(ReportPhase.allCases, id: \.self) { phase in
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.secondary.opacity(0.15))
                    .overlay {
                        if vm.currentReportProgress == phase || vm.currentReportProgress.rawValue > phase.rawValue {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.pink)
                        }
                    }
                    .frame(height: 4)
            }
        }
        .opacity(vm.showReportProgress ? 1 : 0)
        .animation(.smooth(duration: 0.25), value: vm.showReportProgress)
        .frame(height: 28)
        .padding(.horizontal, 64)
        .padding(.top, 10)
    }
    
    @ViewBuilder
    private func Toolbar() -> some View {
        ZStack {
//            DismissButton(
//                systemName: "arrow.left.circle.fill",
//                size: 28,
//                action: vm.goToPreviousStep
//            )
//            .opacity(vm.path.count > 0 ? 1 : 0)
//            .scaleEffect(vm.path.count > 0 ? 1.0 : 0.6)
//            .animation(.smooth(duration: 0.35, extraBounce: 0.1), value: vm.path)
//            .frame(maxWidth: .infinity, alignment: .leading)
            
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 200, height: 4)
                .foregroundStyle(.secondary.opacity(0.15))
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 200 * vm.progress, height: 4)
                        .foregroundStyle(Color.primaryBlue)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .animation(.smooth(duration: 0.3, extraBounce: 0.15), value: vm.progress)
                .opacity(vm.path.count >= 0 ? 1 : 0)
                .offset(y: vm.path.count >= 0 ? 0 : -32)
                .scaleEffect(x: vm.path.count >= 0 ? 1 : 0.5)
                .animation(.smooth(duration: 0.35, extraBounce: 0.1), value: vm.path)
        }
        .frame(height: 28)
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .opacity(vm.hideTabbar ? 0 : 1)
        .animation(.smooth(duration: 0.25), value: vm.hideTabbar)
    }
    
    @ViewBuilder
    private func FamilyAuthRequest() -> some View {
            ZStack {
                Color.black.opacity(0.8).ignoresSafeArea()
                
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .frame(square: 76)
                    .foregroundStyle(.thinMaterial)
                    .overlay {
                        ProgressView()
                            .controlSize(.large)
                            .foregroundStyle(.white)
                    }
                    .scaleEffect(vm.isLoading ? 1 : 0.9)
                    .animation(.smooth(duration: 0.35, extraBounce: 0.15), value: vm.isLoading)
                
                if vm.showChevronHint {
                    Image(systemName: "chevron.compact.up")
                        .font(.system(size: 64))
                        .foregroundStyle(.white)
                        .phaseAnimator([true, false]) { view, phase in
                            view
                                .offset(y: phase ? -24 : 0)
                                .opacity(phase ? 1 : 0.75)
                        } animation: { _ in
                                .smooth(duration: 0.5)
                        }
                        .offset(
                            x: -75,
                            y: height * 0.2
                        )
                }

            }
            .opacity(vm.isLoading ? 1 : 0)
    }
    
    @ViewBuilder
    private func destination(_ step: Int) -> some View {
        Group {
            if step >= 0 && step < navigationSteps.count {
                navigationSteps[step]
            } else {
                AnyView(EmptyView())
            }
        }
        .navigationBarBackButtonHidden()
    }

    // Define your navigation steps as an array
    private let navigationSteps: [AnyView] = [
//        AnyView(OBQuizWelcome()),
        AnyView(OBQuizOne()),
        AnyView(OBQuizTwo()),
        AnyView(OBQuizThree()),
        AnyView(OBQuizFour()),
        AnyView(OBQuizFive()),
        AnyView(OBPause()),
        AnyView(OBQuizSix()),
        AnyView(OBQuizSeven()),
        AnyView(OBQuizEight()),
        AnyView(OBQuizNine()),
        AnyView(OBQuizTen()),
        AnyView(OBQuizName()),
        AnyView(OBQuizLoading()),
        AnyView(OBQuizResultOne()),
        AnyView(OBQuizResultTwo()),
        AnyView(OBQuizResultThree()),
        AnyView(OBQuizSymptom()),
        AnyView(OBQuizCarousel()),
        AnyView(OBQuizLoadingTwo()),
        AnyView(OBQuizReaffirm()),
        AnyView(OBQuizCarouselTwo()),
        AnyView(OBQuizSetupOne()),
        AnyView(OBQuizSetupTwo()),
        AnyView(OBQuizSetupThree()),
        AnyView(OBQuizReaffirmTwo()),
        AnyView(OBRatingPrompt()),
        AnyView(OBQuizCommit()),
        AnyView(EmptyView())
    ]


}

#Preview {
    OBQuizView()
        .environmentObject(OBUserViewModel())
}
