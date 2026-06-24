//
//  OBView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 13/05/25.
//

import SwiftUI

struct OBView: View {
    @StateObject private var vm = OBUserViewModel()

    var body: some View {
        NavigationStack(path: $vm.path) {
            OBWelcome()
                .navigationDestination(
                    for: Int.self,
                    destination: destination
                )
        }
        .environmentObject(vm)
        .overlay(alignment: .top) {
            Toolbar()
        }
        .overlay(alignment: .top) {
            ReportToolbar()
        }
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
                        }
                    }
                    .frame(height: 4)
                    .opacity(vm.showReportProgress ? 1 : 0)
                    .offset(y: vm.showReportProgress ? 0 : -64)
                    .animation(.smooth(duration: 0.3, extraBounce: 0.35).delay(TimeInterval(Double(phase.rawValue) * 0.05)), value: vm.showReportProgress)
            }
        }
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
                .frame(width: 200, height: 5)
                .foregroundStyle(.thinMaterial)
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 200 * vm.progress, height: 5)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .animation(.smooth(duration: 0.3, extraBounce: 0.15), value: vm.progress)
                .opacity(vm.path.count >= 0 ? 1 : 0)
                .offset(y: vm.path.count >= 0 ? 0 : -32)
                .scaleEffect(x: vm.path.count >= 0 ? 1 : 0.5)
                .animation(.smooth(duration: 0.35, extraBounce: 0.1), value: vm.path)
            
//            Text("\(vm.path.count)/\(vm.progressSteps.count)")
//                .font(.subheadline.weight(.medium))
//                .foregroundStyle(.secondary)
//                .opacity(vm.path.count > 1 ? 1 : 0)
//                .scaleEffect(vm.path.count > 1 ? 1.0 : 0.6)
//                .animation(.smooth(duration: 0.35, extraBounce: 0.1), value: vm.path)
//                .contentTransition(.numericText(value: Double(vm.path.count)))
//                .frame(maxWidth: .infinity, alignment: .trailing)

        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .opacity(vm.hideTabbar ? 0 : 1)
        .animation(.smooth(duration: 0.25), value: vm.hideTabbar)
    }
    
    @ViewBuilder
    private func destination(_ step: Int) -> some View {
        Group {
            switch step {
            case 0: EmptyView()
            case 1: OBOneView()
            case 2: OBTwoView()
            case 3: OBThreeView()
            case 4: OBFourView()
            case 5: OBFiveView()
            case 6: OBSixView()
            case 7: OBSevenView()
            case 8: OBEightView()
            case 9: OBNineView()
            case 10: OBNameView()
            case 11: OBLoadingView()
            case 12: OBReportOneView()
            case 13: OBReportTwoView()
            case 14: OBReportThreeView()
            case 15: OBSymptomView()
            case 16: OBFifteenView()
            case 17: OBSeventeenView()
            case 18: OBSliderView()
            case 19: OBGoalView()
            case 20: EmptyView()
            case 21: EmptyView()
            case 22: EmptyView()
            default: EmptyView()
            }
        }
        .navigationBarBackButtonHidden()
    }

}

#Preview {
    OBView()
}

/*
 
 Group {
     switch step {
     case 0: EmptyView()
     case 1: OBOneView()
     case 2: OBTwoView()
     case 3: OBThreeView()
     case 4: OBFourView()
     case 5: OBFiveView()
     case 6: OBSixView()
     case 7: OBSevenView()
     case 8: OBEightView()
     case 9: OBNineView()
     case 10: OBTenView()
     case 11: OBElevenView()
     case 12: OBNineteenView()
     case 13: OBThirteenView()
     case 14: OBFourteenView()
     case 15: OBFifteenView()
     case 16: OBSixteenView()
     case 17: OBSeventeenView()
     case 18: OBEighteenView()
     case 19: OBNineteenView()
     case 20: OBTwentyView()
     case 21: OBTwentyoneView()
     case 22: OBTwentytwoView()
     default: EmptyView()
     }
 }

 
 */
