//
//  OBSelectAppsView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 13/06/25.
//

import SwiftUI
import FamilyControls

struct OBSelectAppsView: View {
    @State private var appearAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 48) {
            VStack(spacing: 14) {
                Text("subtitle".uppercased())
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .kerning(1.0)
                
                Text("Choose the apps to block")
                    .font(.system(size: 30).weight(.bold))
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 18) {
                
                Button {
                    
                } label: {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .foregroundStyle(.thinMaterial)
                        .opacity(0.25)
                        .frame(height: 250)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(lineWidth: 3.0)
                                .foregroundStyle(.thinMaterial)
                                .phaseAnimator([true, false]) { view, phase in
                                    view
                                        .opacity(phase ? 0.75 : 0.25)
                                } animation: { _ in
                                        .smooth(duration: 0.5)
                                }
//                                .opacity(selection.applicationTokens.isEmpty ? 1 : 0)
                        }
                        .overlay {
                            VStack(spacing: 24) {
                                HStack(spacing: 0) {
                                    Image(systemName: "app.dashed")
                                        .font(.system(size: 50, weight: .light))
                                        .foregroundStyle(
                                            .linearGradient(
                                                colors: [.secondary.opacity(0.15), .secondary.opacity(0.0)],
                                                startPoint: .trailing,
                                                endPoint: .leading
                                            )
                                        )
                                        .rotationEffect(.degrees(appearAnimation ? -10 : 0))
                                        .offset(y: 10)
                                        .offset(x: appearAnimation ? 0 : 6)

                                    Image(systemName: "app.dashed")
                                        .font(.system(size: 55, weight: .light))
                                        .foregroundStyle(.secondary.opacity(0.15))
                                        .rotationEffect(.degrees(appearAnimation ? -5 : 0))
                                        .offset(x: appearAnimation ? 0 : 6)

                                    Image(systemName: "app.dashed")
                                        .font(.system(size: appearAnimation ? 70 : 64, weight: .light))
                                        .foregroundStyle(.secondary.opacity(0.25))
                                        .overlay {
                                            Image(systemName: "plus")
                                                .font(.system(size: 32, weight: .medium))
                                                .foregroundStyle(.secondary.opacity(0.45))
                                        }
                                        .offset(y: -10)

                                    Image(systemName: "app.dashed")
                                        .font(.system(size: 55, weight: .light))
                                        .foregroundStyle(.secondary.opacity(0.15))
                                        .rotationEffect(.degrees(appearAnimation ? 5 : 0))
                                        .offset(x: appearAnimation ? 0 : -6)
                                    
                                    Image(systemName: "app.dashed")
                                        .font(.system(size: 50, weight: .light))
                                        .foregroundStyle(
                                            .linearGradient(
                                                colors: [.secondary.opacity(0.15), .secondary.opacity(0.0)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .rotationEffect(.degrees(appearAnimation ? 10 : 0))
                                        .offset(y: 10)
                                        .offset(x: appearAnimation ? 0 : -6)
                                }
                                
                                VStack(spacing: 16) {
                                    Text("Choose apps")
                                        .font(.title3.weight(.semibold))

                                    Text("Select from your app list the ones you'd like to block")
                                        .multilineTextAlignment(.center)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.secondary)
                                        .lineSpacing(2.0)
                                }
                            }
                            .padding(32)
                        }
                }
            }
            
            Image(systemName: "chevron.compact.up")
                .font(.system(size: 64))
                .foregroundStyle(.secondary.opacity(0.3))
                .phaseAnimator([true, false]) { view, phase in
                    view
                        .offset(y: phase ? -24 : 0)
                } animation: { _ in
                        .smooth(duration: 0.5)
                }
//                .opacity(selection.applicationTokens.isEmpty ? 1 : 0)

        }
        .tint(.primary)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            Button {
                action()
            } label: {
                RoundedRectangle(cornerRadius: 100, style: .continuous)
                    .frame(height: 60)
//                    .animation(.smooth(duration: 0.35).delay(0.3), value: selection)
                    .overlay {
                        Text("Continue")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.background)
                    }
            }
            .padding(.horizontal)
            .opacity(0.0)
//            .overlay(alignment: .top) {
//                VStack(spacing: 18) {
//                    Text("Tap “Allow Blocking“ to continue")
//                        .font(.subheadline.weight(.medium))
//                        .foregroundStyle(.secondary).opacity(0.8)
//                    
//                    Image(systemName: "chevron.compact.down")
//                        .font(.system(size: 32, weight: .semibold))
//                        .foregroundStyle(.secondary.opacity(0.3))
//                        .phaseAnimator([true, false]) { view, phase in
//                            view
//                                .offset(y: phase ? 12 : 0)
//                        } animation: { _ in
//                                .smooth(duration: 0.5)
//                        }
//                }
//                .offset(y: -80)
//                .opacity(!selection.applicationTokens.isEmpty ? 1 : 0)
//            }
        }
        .background {
            Circle()
                .foregroundStyle(
                    .linearGradient(
                        colors: [.orange, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(0.25)
                .blur(radius: 144)
        }
        .padding()
        .onAppear(perform: setup)
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.15) {
            withAnimation(.smooth(duration: 0.35, extraBounce: 0.25)) {
                appearAnimation = true
            }
        }
    }
    
    private func action() {
        
    }
    
}

#Preview {
    OBSelectAppsView()
}
