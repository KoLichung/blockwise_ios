//
//  OBProfileView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 06/06/25.
//

import SwiftUI
import Lottie

struct OBProfileView: View {
    @EnvironmentObject var vm: OBUserViewModel
    @State private var appearAnimation: Bool = false

    @State private var color: Color = Color.primaryBlue

    @State private var next: Bool = false
    
    let cardCornerRadius: CGFloat = 32.0

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 14) {
                Text("Analysis".uppercased())
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .kerning(1.0)
                
                Text("Your Profile")
                    .font(.system(size: 30).weight(.bold))
                    .multilineTextAlignment(.center)
                
                Text("We've built your profile. Your progress will be tracked here.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .offset(y: appearAnimation ? 0 : 64)
            .opacity(appearAnimation ? 1 : 0)

            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .aspectRatio(0.75, contentMode: .fit)
                .foregroundStyle(color.gradient)
                .brightness(-0.10)
                .shadow(color: .black.opacity(0.5), radius: 14, x: 0, y: 10)
                .background {
                    RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                        .aspectRatio(0.75, contentMode: .fit)
                        .foregroundStyle(
                            .linearGradient(
                                colors: [color],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blur(radius: 244)
                        .opacity(0.75)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: cardCornerRadius - 5, style: .continuous)
                        .stroke(lineWidth: 4.0)
                        .foregroundStyle(
                            .linearGradient(
                                colors: [color],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .white.opacity(0.25), radius: 6, x: 0, y: 0)
                        .brightness(0.6)
                        .opacity(0.25)
                        .padding(10)
                }
                .overlay {
                    
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .offset(y: appearAnimation ? 0 : 500)
                .rotation3DEffect(.degrees(appearAnimation ? 2 : 45), axis: (1, 0, 0))
                .opacity(appearAnimation ? 1 : 0)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 32) {
                Button {
                    action()
                } label: {
                    RoundedRectangle(cornerRadius: 100, style: .continuous)
                        .frame(height: 60)
                        .foregroundStyle(color)
                        .opacity(0.25)
                        .overlay {
                            HStack(spacing: 10) {
                                Text("Get Started")
                                    .font(.title3.weight(.semibold))
                                
                                Image(systemName: "arrow.right")
                                    .font(.title3.weight(.semibold))
                                    .phaseAnimator([true, false]) { view, phase in
                                        view
                                            .offset(x: phase ? 0 : 6)
                                    }
                            }
                            .foregroundStyle(color)
                        }
                        .brightness(0.15)
                }
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .animation(.smooth(duration: 0.45).delay(1.0), value: appearAnimation)
            }
            .padding(.horizontal)
            .padding([.bottom, .horizontal])
        }
        .onAppear(perform: setup)
    }

    private func setup() {
        SleepTask.sleep(seconds: 0.10) {
            withAnimation(.smooth(duration: 0.45, extraBounce: 0.15)) {
                appearAnimation = true
            }
        }
    }

    private func action() {
        vm.goToNextStep(step: 15)
    }
}

#Preview {
    OBProfileView()
        .environmentObject(OBUserViewModel())
}

struct LogoShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.95601*width, y: 0.19983*height))
        path.addCurve(to: CGPoint(x: 0.997*width, y: 0.24292*height), control1: CGPoint(x: 0.97787*width, y: 0.20317*height), control2: CGPoint(x: 0.99525*width, y: 0.22072*height))
        path.addCurve(to: CGPoint(x: 0.49992*width, y: 0.9997*height), control1: CGPoint(x: 1.03651*width, y: 0.74412*height), control2: CGPoint(x: 0.65438*width, y: 0.9997*height))
        path.addCurve(to: CGPoint(x: 0.00283*width, y: 0.24308*height), control1: CGPoint(x: 0.34549*width, y: 0.9997*height), control2: CGPoint(x: -0.03658*width, y: 0.74418*height))
        path.addCurve(to: CGPoint(x: 0.04401*width, y: 0.19996*height), control1: CGPoint(x: 0.00459*width, y: 0.22081*height), control2: CGPoint(x: 0.02206*width, y: 0.20323*height))
        path.addCurve(to: CGPoint(x: 0.49992*width, y: 0), control1: CGPoint(x: 0.41995*width, y: 0.14393*height), control2: CGPoint(x: 0.45044*width, y: 0))
        path.addCurve(to: CGPoint(x: 0.95601*width, y: 0.19983*height), control1: CGPoint(x: 0.54943*width, y: 0), control2: CGPoint(x: 0.57701*width, y: 0.14195*height))
        path.closeSubpath()
        return path
    }
}
