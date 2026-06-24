//
//  OBRoadmapView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 18/06/25.
//

import SwiftUI

//private struct RoadmapPoint: Identifiable {
//    let id = UUID()
//    
//    let title: String
//    let description: String
//}

struct OBRoadmapView: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    let customOrange: Color = Color(hex: 0xFB8C00)
    let darkOrange: Color = Color(hex: 0xE65100)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 32) {
                    Image("balloon-bg")
                        .resizable()
                        .scaledToFill()
                        .overlay(alignment: .bottom) {
                            Image("balloon")
                                .resizable()
                                .scaledToFit()
                                .offset(y: 70)
                                .shadow(color: .black.opacity(0.15), radius: 10)
                        }
                        .padding(.bottom, 16)

                    VStack(spacing: 12) {
                        Text("\(vm.firstName)'s Path".uppercased())
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(Color.primaryOrange)
                            .kerning(1.0)

                        Text("The Roadmap to\nYour Better Self")
    //                        .font(.system(size: 34).weight(.light))
                            .font(.grotesk(size: 34, weight: .medium))
                            .multilineTextAlignment(.center)
                            .lineSpacing(2.0)
                    }
                    .padding(.horizontal, 32)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(roadmap) { point in
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(spacing: 14) {
                                    Circle()
                                        .stroke(lineWidth: 2.0)
                                        .frame(square: 20)
                                        .foregroundStyle(customOrange)
                                        .overlay {
                                            Circle()
                                                .frame(square: 10)
                                                .foregroundStyle(darkOrange)
                                                .blur(radius: 2)
                                        }
                                    
                                    Text(point.title)
    //                                    .font(.headline)
                                        .font(.grotesk(.body, weight: .medium))
                                }
                                
                                HStack(spacing: 14) {
                                    if let last = roadmap.last {
                                        RoundedRectangle(cornerRadius: 10)
                                            .frame(width: 2)
                                            .foregroundStyle(
                                                .linearGradient(
                                                    colors: [darkOrange, .clear],
                                                    startPoint: .bottom,
                                                    endPoint: .top
                                                )
                                            )
                                            .frame(width: 20)
                                            .opacity(point.id == last.id ? 0.0 : 1.0)
                                    }

                                    Text(point.description + "\n")
    //                                    .font(.system(size: 14))
                                        .font(.grotesk(size: 14, weight: .regular))
                                        .opacity(0.8)
                                        .lineSpacing(8.0)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                }
                .offset(y: -24)
                
                GlassButton("Continue") {
                    action()
                }
                .foregroundStyle(darkOrange)
                .padding(.horizontal, 32)
                .padding(.bottom)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background {
            customOrange.opacity(0.15)
                .ignoresSafeArea()
        }
    }
    
    private func action() {
        vm.nextStep()
    }
    
    fileprivate let roadmap: [RoadmapPoint] = [
        RoadmapPoint(
            title: "First 7 days",
            description: "Begin identifying your biggest distractions. Try out different block schedules to see what helps you feel more in control."
        ),
        
        RoadmapPoint(
            title: "30 days in",
            description: "You’ll grow more aware of your urges and start replacing automatic app use with intentional, healthier choices."
        ),
        
        RoadmapPoint(
            title: "60 days in",
            description: "With consistency, your new habits take root. Distractions lose their grip as focus and calm become your new normal."
        ),
        
        RoadmapPoint(
            title: "Beyond",
            description: "Stay steady on your path. Even when urges arise, you’ll know how to ride them out and protect your progress."
        ),
    ]
    
}

#Preview {
    OBRoadmapView()
        .environmentObject(OBUserViewModel())
}
