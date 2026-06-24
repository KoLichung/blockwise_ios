//
//  OB21.swift
//  Blockwise
//
//  Created by Ivan Sanna on 24/11/25.
//

import SwiftUI

struct OB21: View {
    @EnvironmentObject var vm: OBVM
    @State private var appearAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {

            Text("Feel the difference with \(AppConfiguration.name)")
                .font(.grotesk(size: 30, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineSpacing(2.0)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth, value: appearAnimation)
            
            Space(height: 8)
            
            ZStack {
                GeometryReader { geo in
                    let width = geo.size.width
                    
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(lineWidth: 2.0)
                        .foregroundStyle(.secondary.opacity(0.15))
                        .overlay(alignment: .topLeading) {
                            VStack(alignment: .leading, spacing: 18) {
                                Text("Before")
                                    .font(.grotesk(.title, weight: .semibold))
                                
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "xmark")
                                        .foregroundStyle(.red)
                                        .offset(y: 4)
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Text("Constant procrastination")
                                        .font(.grotesk())
                                        .foregroundStyle(.secondary)
                                }
                                
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "xmark")
                                        .foregroundStyle(.red)
                                        .offset(y: 4)
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Text("Hard to focus")
                                        .font(.grotesk())
                                        .foregroundStyle(.secondary)
                                }

                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "xmark")
                                        .foregroundStyle(.red)
                                        .offset(y: 4)
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Text("Bad memory")
                                        .font(.grotesk())
                                        .foregroundStyle(.secondary)
                                }

                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "xmark")
                                        .foregroundStyle(.red)
                                        .offset(y: 4)
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Text("Can't sleep")
                                        .font(.grotesk())
                                        .foregroundStyle(.secondary)
                                }

                            }
                            .padding()
                            .padding(.vertical)
                        }
                        .overlay(alignment: .topTrailing) {
//                            Image(.mascotteOverwhelmed2)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(square: 80)
//                                .offset(y: -50)
//                                .offset(x: -32)
                        }
                        .frame(width: width * 0.52)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(y: appearAnimation ? 40 : 0)
                        .rotationEffect(.degrees(-2))
                    
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.05), radius: 0, x: -6, y: 6)
                        .overlay {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(lineWidth: 2.0)
                                .foregroundStyle(Color.primaryBlue.opacity(0.5))
                        }
                        .overlay(alignment: .topLeading) {
                            VStack(alignment: .leading, spacing: 18) {
                                Text("After")
                                    .font(.grotesk(.title, weight: .semibold))
                                
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.primaryBlue)
                                        .offset(y: 4)
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Text("Get things done")
                                        .font(.grotesk())
                                }
                                
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.primaryBlue)
                                        .offset(y: 4)
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Text("Easy to enter deep focus")
                                        .font(.grotesk())
                                }

                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.primaryBlue)
                                        .offset(y: 4)
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Text("Great memory")
                                        .font(.grotesk())
                                }

                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.primaryBlue)
                                        .offset(y: 4)
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Text("Quality REM sleep")
                                        .font(.grotesk())
                                }

                            }
                            .padding()
                            .padding(.vertical)
                        }
                        .overlay(alignment: .topTrailing) {
//                            Image(.mascotteSitOnClock)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(square: 100)
//                                .offset(y: -44)
                        }
                        .frame(width: width * 0.52)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .rotationEffect(.degrees(1))
                }
                .frame(height: 350)
            }
            .padding(.horizontal, -12)
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.1), value: appearAnimation)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .safeAreaInset(edge: .bottom) {
            GlassButton("Continue") {
                action()
            }
            .padding(.horizontal, 32)
            .padding()
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.3), value: appearAnimation)
        }
        .onAppear(perform: setup)
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.1) {
            withAnimation {
                appearAnimation = true
            }
        }
    }
    
    private func action() {
        vm.nextPage()
        
        // Mixpanel
        AnalyticsService.shared.track("Onboarding > Differences")
    }
}

#Preview {
    OB21()
        .environmentObject(OBVM())
}
