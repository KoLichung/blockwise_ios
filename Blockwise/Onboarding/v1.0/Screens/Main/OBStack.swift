//
//  OBStack.swift
//  Blockwise
//
//  Created by Ivan Sanna on 21/11/25.
//

import SwiftUI

struct OBStack: View {
    @StateObject private var vm = OBVM()
    
    var body: some View {
        NavigationStack(path: $vm.path) {
            vm.views[0]
                .navigationDestination(
                    for: Int.self,
                    destination: destination
                )
        }
        .overlay(alignment: .top) {
            WelcomeProgressBar()
        }
        .overlay(alignment: .top) {
            ProgressBar()
        }
        .overlay(alignment: .top) {
            ReportBar()
        }
        .environmentObject(vm)
    }
    
    // MARK: - UI components
    @ViewBuilder
    private func destination(_ step: Int) -> some View {
        Group {
            if step >= 0 && step < vm.views.count {
                vm.views[step]
            } else {
                AnyView(EmptyView())
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder
    private func WelcomeProgressBar() -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 10) {
                ForEach(WelcomeProgress.allCases, id: \.self) { index in
                    
                    GeometryReader { geo in
                        let width = geo.size.width

                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.secondary.opacity(0.15))
                            .overlay(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: index.rawValue <= vm.welcomeProgress.rawValue ? width : 0)
                                    .foregroundStyle(Color.primary)
                            }
                            .frame(width: width)
                    }
                }
                .frame(height: 3)
            }
            .frame(height: 32)
            
            HStack(spacing: 10) {
                HStack(spacing: 8) {
                    Image(.blockrIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(square: 24)
                    
                    Text(AppConfiguration.name)
                        .font(.grotesk(size: 20, weight: .semibold))
                        .foregroundStyle(Color.blueAccent)
                }
            }
        }
        .animation(.smooth, value: vm.welcomeProgress)
        .padding(.horizontal, 32)
        .offset(y: vm.showWelcomeProgress ? 0 : -100)
        .opacity(vm.showWelcomeProgress ? 1 : 0)
        .animation(.smooth(duration: 0.5, extraBounce: 0.15), value: vm.showWelcomeProgress)
    }
    
    @ViewBuilder
    private func ProgressBar() -> some View {
        HStack(spacing: 14) {
            GeometryReader { geo in
                let width = geo.size.width
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 4)
                    .foregroundStyle(.secondary.opacity(0.15))
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 3)
                            .frame(width: width * vm.progressBar)
                    }
                    .padding(.vertical, 10)
            }
        }
        .padding(.horizontal, 32)
        .frame(height: 32)
        .opacity(vm.showProgressBar ? 1 : 0)
        .offset(y: vm.showProgressBar ? 0 : -100)
        .animation(.smooth, value: vm.progressBar)
        .animation(.smooth(duration: 0.5, extraBounce: 0.15), value: vm.showProgressBar)
    }
    
    @ViewBuilder
    private func ReportBar() -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 10) {
                ForEach(OBReport.allCases, id: \.self) { index in
                    
                    GeometryReader { geo in
                        let width = geo.size.width

                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.secondary.opacity(0.15))
                            .overlay(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: index.rawValue <= vm.reportProgress.rawValue ? width : 0)
                                    .foregroundStyle(Color.primary)
                            }
                            .frame(width: width)
                    }
                }
                .frame(height: 3)
            }
            .frame(height: 32)
        }
        .animation(.smooth, value: vm.reportProgress)
        .padding(.horizontal, 32)
        .offset(y: vm.showReportBar ? 0 : -100)
        .opacity(vm.showReportBar ? 1 : 0)
        .animation(.smooth(duration: 0.5, extraBounce: 0.15), value: vm.showReportBar)
    }

}

#Preview {
    OBStack()
}

/*
 
 @ViewBuilder
 private func ProgressBar() -> some View {
     HStack(spacing: 18) {
         GeometryReader { geo in
             let width = geo.size.width
             let progressIndex = vm.quizProgressIndex
             let questionCount = vm.quizProgressSteps.count

             // Safely resolve progress fraction
             let progressFraction: CGFloat = {
                 guard questionCount > 0 else { return 0 }
                 // Clamp index to valid range
                 let clamped = min(max(progressIndex, 0), questionCount - 1)
                 return vm.quizProgressSteps[clamped]
             }()

             let progressWidth = width * progressFraction
             
             RoundedRectangle(cornerRadius: 10)
                 .foregroundStyle(.secondary.opacity(0.15))
                 .overlay(alignment: .leading) {
                     RoundedRectangle(cornerRadius: 10)
                         .frame(width: progressWidth)
                         .foregroundStyle(Color.blueAccent)
                 }
         }
         .frame(height: 4)
         
         Text("\(vm.quizProgressIndex + 1) of \(vm.quizProgressSteps.count)")
             .font(.system(.subheadline, weight: .medium))
             .contentTransition(.numericText())
     }
     .padding(.vertical, 12)
     .padding(.horizontal, 32)
     .offset(y: vm.showQuizProgress ? 0 : -32)
     .opacity(vm.showQuizProgress ? 1 : 0)
     .offset(x: vm.quizProgressIndex == vm.quizProgressSteps.count ? -500 : 0)
     .opacity(vm.quizProgressIndex == vm.quizProgressSteps.count ? 0 : 1)
     .animation(.smooth(duration: 0.35), value: vm.quizProgressIndex)
     .animation(.smooth(duration: 0.35), value: vm.showQuizProgress)
 }

 
 */
