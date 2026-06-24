//
//  OBWelcomeThreeView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 10/06/25.
//

import SwiftUI
import Lottie

struct OBWelcomeThreeView: View {
    @State private var appearAnimation: Bool = false

    @State private var show: Bool = false
    let customOrange: Color = Color(hex: 0xFB8C00)
    let darkOrange: Color = Color(hex: 0xE65100)

    var body: some View {
        ScrollView {
            ZStack {
                Image("sunset-2")
                    .resizable()
                    .scaledToFit()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .offset(y: -128)
        }
        .ignoresSafeArea(edges: .top)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 48) {
                VStack(spacing: 14) {
    
                    Text("Welcome to Blockr".uppercased())
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .kerning(1.0)
    
                    Text("A Science-Backed Journey to Quit Phone Addiction.")
                        .font(.system(size: 30).weight(.semibold))
                        .multilineTextAlignment(.center)
                        .fontDesign(.default)
                        .lineSpacing(4.0)
                }
                
                HStack(spacing: 16) {
                    let rectSize: CGFloat = 64
                    
                    RoundedRectangle(cornerRadius: rectSize / 4.0, style: .continuous)
                        .frame(square: rectSize)
                        .foregroundStyle(Color(hex: 0xBA2643))
                        .overlay(alignment: .topTrailing) {
                            Circle()
                                .foregroundStyle(.red)
                                .frame(square: 24)
                                .background {
                                    Circle()
                                        .foregroundStyle(.black)
                                        .frame(square: 32)

                                    Circle()
                                        .foregroundStyle(customOrange).opacity(0.15)
                                        .frame(square: 32)
                                }
                                .overlay {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 14, weight: .heavy))
                                        .foregroundStyle(.white)
                                }
                                .offset(x: 10, y: -10)
                        }
                    
                    RoundedRectangle(cornerRadius: rectSize / 4.0, style: .continuous)
                        .frame(square: rectSize)
                        .foregroundStyle(Color(hex: 0xFFA726))
                        .overlay(alignment: .topTrailing) {
                            Circle()
                                .foregroundStyle(.indigo)
                                .frame(square: 24)
                                .background {
                                    Circle()
                                        .foregroundStyle(.black)
                                        .frame(square: 32)

                                    Circle()
                                        .foregroundStyle(customOrange).opacity(0.15)
                                        .frame(square: 32)
                                }
                                .overlay {
                                    Image(systemName: "moon.fill")
                                        .font(.system(size: 14, weight: .heavy))
                                        .foregroundStyle(.white)
                                }
                                .offset(x: 10, y: -10)
                        }
                    
                    RoundedRectangle(cornerRadius: rectSize / 4.0, style: .continuous)
                        .frame(square: rectSize)
                        .foregroundStyle(Color.primaryBlue)
                        .overlay(alignment: .topTrailing) {
                            Circle()
                                .foregroundStyle(.purple)
                                .frame(square: 24)
                                .background {
                                    Circle()
                                        .foregroundStyle(.black)
                                        .frame(square: 32)

                                    Circle()
                                        .foregroundStyle(customOrange).opacity(0.15)
                                        .frame(square: 32)
                                }
                                .overlay {
                                    Image(systemName: "arrow.down")
                                        .font(.system(size: 14, weight: .heavy))
                                        .foregroundStyle(.white)
                                }
                                .offset(x: 10, y: -10)
                        }

                    RoundedRectangle(cornerRadius: rectSize / 4.0, style: .continuous)
                        .frame(square: rectSize)
                        .foregroundStyle(Color(hex: 0xD84315))
                        .overlay(alignment: .topTrailing) {
                            Circle()
                                .foregroundStyle(.red)
                                .frame(square: 24)
                                .background {
                                    Circle()
                                        .foregroundStyle(.black)
                                        .frame(square: 32)

                                    Circle()
                                        .foregroundStyle(customOrange).opacity(0.15)
                                        .frame(square: 32)
                                }
                                .overlay {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 14, weight: .heavy))
                                        .foregroundStyle(.white)
                                }
                                .offset(x: 10, y: -10)
                        }

                }

//                Image(systemName: "chevron.compact.down")
//                    .font(.system(size: 64))
//                    .foregroundStyle(.secondary.opacity(0.3))
//                    .phaseAnimator([true, false]) { view, phase in
//                        view
//                            .offset(y: phase ? 0 : -24)
//                    } animation: { _ in
//                            .smooth(duration: 0.5)
//                    }
                
                VStack(spacing: 24) {
                    Button("Start your Journey") {
                        action()
                    }
                    .foregroundStyle(darkOrange)
                    
                    Text("By continuing, you accept our \("Terms of Use") and \("Privacy Policy")")
                        .multilineTextAlignment(.center)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 32)
                        .tint(Color.secondary)
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical)
        }
        .fullScreenCover(isPresented: $show) {
//            OBRoadmapView()
            OBView()
        }
        .background {
            customOrange.opacity(0.15)
                .ignoresSafeArea()
//            Image("forest-path")
//                .resizable()
//                .scaledToFill()
//                .scaleEffect(1.80)
            
            LinearGradient(
                colors: [.clear, .clear, .clear, .black.opacity(0.65)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
        .onAppear(perform: setup)
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.15) {
            withAnimation(.smooth(duration: 0.5)) {
                appearAnimation = true
            }
        }
    }
    
    private func action() {
        show = true
    }
}

#Preview {
    OBWelcomeThreeView()
}

/*
 
             LottieView(animation: .named("wave"))
                 .looping()
                 .frame(square: 100)
                 .makeReflection(size: 100)

             VStack(spacing: 14) {
 
                 Text("Welcome to Blockr".uppercased())
                     .font(.footnote.weight(.semibold))
                     .foregroundStyle(.secondary)
                     .kerning(1.0)
 
                 Text("A Science-Backed Journey to Quit Phone Addiction.")
                     .font(.system(size: 30).weight(.medium))
                     .multilineTextAlignment(.center)
                     .fontDesign(.serif)
                     .lineSpacing(2.0)
             }

 
 */
