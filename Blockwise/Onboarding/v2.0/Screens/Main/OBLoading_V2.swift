//
//  OBLoading_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 19/01/26.
//

import SwiftUI

enum LoadingPhase_V2: String {
    case start = "Understanding your responses..."
    case stepOne = "Analysing your patterns..."
    case stepTwo = "Finalizing your results..."
    case hold = ""
}

struct OBLoading_V2: View {
    @EnvironmentObject var vm: OBVM_V2
    
    @State private var percentageCompleted: Int = 0
    @State private var trim: CGFloat = 0.0
    
    @State private var timer: Timer? = nil
    
    @State private var loadingPhase: LoadingPhase = .start
            
    var body: some View {
        VStack(spacing: 48) {
            Loader()
            
            VStack(spacing: 18) {
                
                Text("Calculating")
                    .font(.grotesk(size: 38, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.textC)
                
                ZStack {
                    Text(LoadingPhase.start.rawValue)
                        .opacity(loadingPhase == .start ? 1 : 0)
                    
                    Text(LoadingPhase.stepOne.rawValue)
                        .opacity(loadingPhase == .stepOne ? 1 : 0)

                    Text(LoadingPhase.stepTwo.rawValue)
                        .opacity(loadingPhase == .stepTwo ? 1 : 0)
                }
                .foregroundStyle(.secondary)
                .font(.grotesk())
                .animation(.smooth(duration: 0.8), value: loadingPhase)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .lineSpacing(4.0)
                .lineLimit(3, reservesSpace: true)
            }
        }
        .tint(.primary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal)
        .padding(.bottom)
        .padding()
        .onAppear(perform: setup)
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    // MARK: - Functions
    private func setup() {
        SleepTask.sleep(seconds: 0.15) {
            startLoading()
        }
    }
    
    private func action() {
        vm.calculateGoodBadNews()
        vm.nextPage()
    }
    
    private func startLoading() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.09, repeats: true) { _ in
            if percentageCompleted < 100 {
                percentageCompleted += 1
                trim = CGFloat(percentageCompleted) / 100.0
                
                if percentageCompleted > 36 && percentageCompleted < 64 {
                    loadingPhase = .stepOne
                } else if percentageCompleted > 72 {
                    loadingPhase = .stepTwo
                } else if percentageCompleted < 28 {
                    loadingPhase = .start
                } else {
                    loadingPhase = .hold
                }
                
                Haptics.feedback(style: .soft)
                
            } else {
                timer?.invalidate()
                Haptics.successFeedback()
                
                SleepTask.sleep(seconds: 0.2) {
                    action()
                }
            }
        }
    }
    
    // MARK: - UI components
    @ViewBuilder
    private func Loader() -> some View {
        Circle()
            .stroke(lineWidth: 18.0)
            .frame(square: 220)
            .foregroundStyle(.secondary.opacity(0.15))
            .overlay {
                Circle()
                    .trim(from: 0.0, to: trim)
                    .stroke(style: .init(lineWidth: 20.0, lineCap: .round))
                    .animation(.smooth, value: trim)
                    .frame(square: 220)
                    .foregroundStyle(.skyBlue)
                    .rotationEffect(.degrees(-90))
            }
            .overlay {
                Text("\(percentageCompleted)%")
                    .font(.grotesk(size: 56, weight: .semibold))
                    .foregroundStyle(.textC)
            }
    }
            
}

#Preview {
    OBLoading_V2()
        .environmentObject(OBVM_V2())
}
