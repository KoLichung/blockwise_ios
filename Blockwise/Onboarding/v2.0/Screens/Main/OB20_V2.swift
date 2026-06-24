//
//  OB20_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 20/01/26.
//

import SwiftUI

struct OB20_V2: View {
    @EnvironmentObject var vm: OBVM_V2
    @State private var appearAnimation: Bool = false
    
    @State private var progress: Double = 0.0
    
    var body: some View {
        VStack(spacing: 32) {
            CircularProgress()
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .foregroundStyle(Theme.foregroundC)
                        .border(cornerRadius: 32)
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
        .safeAreaInset(edge: .bottom) {
            GlassButton("Continue") {
                action()
            }
            .padding()
            .padding(.horizontal, 32)
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.3), value: appearAnimation)
        }
        .onAppear(perform: setup)
    }
    
    private func setup() {
        #if targetEnvironment(simulator)
        vm.screenTimeGoal = 3600 + 1800
        #endif
        
        SleepTask.sleep(seconds: 0.1) {
            withAnimation {
                appearAnimation = true
            }
        }
    }
    
    private func action() {
        vm.nextPage(progress: 1.0)

        // Mixpanel
        AnalyticsService.shared.track("Onboarding > Science")
    }
    
    @ViewBuilder
    private func CircularProgress() -> some View {
        let linewidth: CGFloat = 48
        
        GeometryReader { geometry in
            let width = geometry.size.width
            
            ZStack {
                Circle()
                    .stroke(lineWidth: linewidth)
                    .foregroundStyle(.secondary.opacity(0.1))
                
                Circle()
                    .stroke(lineWidth: 2)
                    .foregroundStyle(.secondary.opacity(0.15))
                
                Circle()
                    .trim(from: progress, to: 1)
                    .stroke(style: .init(lineWidth: linewidth, lineCap: .butt))
                    .rotationEffect(.degrees(-90))
                    .foregroundStyle(.skyBlue)
                
                Circle()
                    .trim(from: progress, to: 1)
                    .stroke(lineWidth: 2)
                    .rotationEffect(.degrees(-90))
                    .foregroundStyle(.skyBlue)
                    .brightness(0.8)
                    .opacity(0.15)

                VStack(spacing: 4) {
                    Text("Daily goal".uppercased())
                        .font(.grotesk(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .kerning(1.0)
                    
                    Text("\(TimeFormatter.display(vm.screenTimeGoal, style: .short))")
                        .font(.grotesk(size: width * 0.18, weight: .semibold))
                        .foregroundStyle(.textC)
                    
                    Text("Remaining").hidden()
                        .font(.grotesk(size: 16, weight: .medium))
                        .foregroundStyle(.secondary).opacity(0.75)
                }
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
        .padding(32)
        .frame(maxWidth: .infinity, alignment: .center)
    }

}

#Preview {
    OB20_V2()
        .environmentObject(OBVM_V2())
        .overlay(alignment: .top) {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.secondary.opacity(0.15))
                .frame(height: 12)
                .padding(.vertical, 10)
                .padding(.horizontal, 32)
                .frame(height: 32)
        }
}
