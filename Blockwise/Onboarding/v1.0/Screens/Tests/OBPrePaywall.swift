//
//  OBPrePaywall.swift
//  Blockwise
//
//  Created by Ivan Sanna on 07/01/26.
//

import SwiftUI
import SuperwallKit

struct OBPrePaywall: View {
    @EnvironmentObject var vm: OBVM
    
    @State private var triggerCheckmark: Bool = false
    
    @State private var scrollContentPosition: Int? = 0
    @State private var scrollPosition: Int? = 0
    
    let customOrange: Color = Color(hex: 0xFB8C00)
    let darkOrange: Color = Color(hex: 0xE65100)

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Checkmark(
                    size: 32,
                    trigger: $triggerCheckmark,
                    checkmarkColor: nil,
                    backgroundColor: Color.blueAccent
                )

                Group {
//                    Text("Change your") +
//                    Text(" habits without fighting ").foregroundStyle(Color.blueAccent) +
//                    Text("yourself.")
                    
                    Text("Here's what") +
                    Text(" this week ").foregroundStyle(Color.blueAccent) +
                    Text("can look like for you:")
                }
                .font(.grotesk(.title, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineSpacing(2.0)
                
                VStack(spacing: 18) {
                    Text("Cut screen time in half by:")
                        .font(.grotesk(.body, weight: .medium))
                        .opacity(0.65)
                    
                    Text(Date.now.addingTimeInterval(3 * 24 * 60 * 60).formatted(components: [.month, .day, .separator, .year]))
                        .font(.grotesk(.body, weight: .semibold))
                        .foregroundStyle(.black)
                        .padding(.horizontal)
                        .padding(.vertical)
                        .background {
                            Capsule(style: .continuous)
                                .stroke(lineWidth: 2.0)
                                .foregroundStyle(.secondary.opacity(0.15))
                        }
                }

//                Image(.beforeAfterScreentime)
//                    .resizable()
//                    .scaledToFit()
//                    .padding(.vertical, 8)
                
                Text("*Conceptual illustration of progress over time")
                    .font(.grotesk(.footnote, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Divisor()
                
                VStack(spacing: 14) {
                    Text("Inspired by Science".uppercased())
                        .font(.grotesk(.subheadline, weight: .semibold))
                        .kerning(1.5)
                        .foregroundStyle(.secondary)

                    Text("It's not fantasy, it's Neuroscience.")
                        .font(.grotesk(size: 30, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2.0)
                    
//                    Image(.books)
//                        .resizable()
//                        .scaledToFit()
//                        .padding(.horizontal, 64)
//                        .padding(.vertical, 8)
                }

                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 18) {
                        ForEach(Array(DoctorTestimony.testimonies.enumerated()), id: \.offset) { (index, testimony) in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(testimony.name)
                                    .font(.grotesk(.title3, weight: .semibold))
                                
                                Text("“\(testimony.text)“")
                                    .font(.grotesk())
                                    .lineSpacing(4.0)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(lineWidth: 2.0)
                                    .foregroundStyle(.secondary.opacity(0.15))
                            }
                            .id(index)
                            .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollPosition(id: $scrollContentPosition)
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.viewAligned)
                .contentMargins(.horizontal, 32, for: .scrollContent)
                .padding(.horizontal, -32)

                HStack(spacing: 10) {
                    ForEach(Array(DoctorTestimony.testimonies.enumerated()), id: \.offset) { (index, testimony) in
                        Circle()
                            .foregroundStyle(.secondary.opacity(0.15))
                            .overlay {
                                Circle()
                                    .opacity(index == scrollContentPosition ? 1 : 0)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(square: 6)
                    }
                }
                
                Text("*Smartphone addiction is leading to 'brain rot'.\n-CBS Evening News, 2025")
                    .font(.grotesk(.footnote, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                                
                Divisor()
                
                BottomArea()

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(32)
        }
        .safeAreaInset(edge: .bottom) {
            GlassButton("Start your Journey") {
                action()
            }
            .padding()
            .padding(.horizontal, 32)
            .background {
                LinearGradient(
                    colors: [.clear, .white.opacity(0.75), .white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
        }
        .onAppear(perform: setup)
    }
    
    // MARK: - Functions
    private func setup() {
        // Set paywall reached to TRUE
//        vm.paywallReached = true
        
        do {
            try vm.createProfile()
        } catch {
            Logger.error(error.localizedDescription)
        }
        
        SleepTask.sleep(seconds: 0.1) {
            triggerCheckmark = true
        }
    }
    
    private func action() {
        Superwall.shared.register(placement: "main_trial_paywall") {
            Logger.success("Paywall dismissed!")
        }
    }
    
    // MARK: - UI components
    
    @ViewBuilder
    private func BottomArea() -> some View {
        VStack(alignment: .center, spacing: 24) {
            VStack(alignment: .center, spacing: 14) {
                                
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14))
                    
                    Text("Built on trust. Self-funded and devoted to privacy.")
                        .font(.grotesk(.footnote, weight: .medium))
                }
                .foregroundStyle(Color.green)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)

    }
    
    @ViewBuilder
    private func Divisor() -> some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(height: 2.0)
            .padding(.horizontal, 64)
            .opacity(0.15)
            .padding(.vertical)
    }
    
    fileprivate let roadmap: [RoadmapPoint] = [
        RoadmapPoint(
            title: "Day 1 - Feel Less Overwhelmed",
            description: "You’ll start noticing how often your phone pulls you in and begin carving out small moments to breathe and be present."
        ),
        
        RoadmapPoint(
            title: "Day 3 - Choose Moments That Matter",
            description: "You’ll catch yourself before mindless scrolling, naturally shifting your time toward things you enjoy, like chatting with friends or stepping outside."
        ),
        
        RoadmapPoint(
            title: "Day 7 - Enjoy Real Connection",
            description: "You’ll find yourself spending more time in nature, laughing with loved ones, or simply enjoying quiet moments without your phone distracting you."
        ),
        
        RoadmapPoint(
            title: "Beyond - Make It Your New Normal",
            description: "When your phone tempts you, you’ll easily pause and choose what truly matters, keeping balance and calm as part of your everyday life."
        ),
    ]

}

#Preview {
    OBPrePaywall()
        .environmentObject(OBVM())
}
