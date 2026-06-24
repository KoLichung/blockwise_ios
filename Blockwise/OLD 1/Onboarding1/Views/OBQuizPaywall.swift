//
//  OBQuizPaywall.swift
//  Blockwise
//
//  Created by Ivan Sanna on 25/08/25.
//

import SwiftUI
import Lottie
import SuperwallKit

struct OBQuizPaywall: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var vm: OBUserViewModel
    @EnvironmentObject var lnManager: LocalNotificationManager
    @StateObject private var superwall = Superwall.shared
    
    @State private var triggerCheckmark: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Checkmark(
                    size: 32,
                    trigger: $triggerCheckmark,
                    checkmarkColor: nil,
                    backgroundColor: .white
                )
                
                Text("\(vm.username), we've got some exciting news for you.")
                    .font(.grotesk(.title, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2.0)
                
                VStack(spacing: 18) {
                    Text("You can half your screen time by:")
                        .font(.grotesk(.body, weight: .medium))
                        .opacity(0.65)
                    
                    Text(Date.now.addingTimeInterval(7 * 24 * 60 * 60).formatted(components: [.month, .day, .separator, .year]))
                        .font(.grotesk(.body, weight: .semibold))
                        .foregroundStyle(.black)
                        .padding(.horizontal)
                        .padding(.vertical)
                        .background {
                            Capsule(style: .continuous)
                        }
                }
                
                DiscountButton()
                
                Divisor()
                
                VStack(spacing: 14) {
                    Text("Become the best of yourself with \(AppConfiguration.name)")
                        .font(.grotesk(.title, weight: .semibold))
                        .multilineTextAlignment(.center)
                    
                    Text("Stronger. Healthier. Happier.")
                        .font(.grotesk(.body, weight: .regular))
                        .opacity(0.65)
                }
                
                BenefitSection(
                    lottie: "martial-arts",
                    title: "Conquer yourself",
                    testimonial: "It felt like a weight lifted off my chest, like I could finally live again",
                    author: "Anonymous",
                    lines: [
                        BenefitLine(
                            icon: "lock.circle.fill",
                            color: .red,
                            label: "Stand firm when temptations strike"
                        ),
                        BenefitLine(
                            icon: "arrow.up.circle.fill",
                            color: .indigo,
                            label: "Earn pride in the person you’re becoming"
                        ),
                        BenefitLine(
                            icon: "leaf.circle.fill",
                            color: .green,
                            label: "Wake up lighter, calmer, and more at peace"
                        )
                    ]
                )

                Divisor()
                                                
                BenefitSection(
                    lottie: "man-muscle",
                    title: "Grow stronger each day",
                    testimonial: "The small choices I made started to bloom into a life I’m proud of.",
                    author: "Anonymous",
                    lines: [
                        BenefitLine(
                            icon: "lock.circle.fill",
                            color: .red,
                            label: "Break free from old habits that held you down"
                        ),
                        BenefitLine(
                            icon: "arrow.up.circle.fill",
                            color: .indigo,
                            label: "Feel your confidence take root and rise"
                        ),
                        BenefitLine(
                            icon: "leaf.circle.fill",
                            color: .green,
                            label: "Bring back joy in the little things"
                        )
                    ]
                )

                Divisor()
                                                
                BenefitSection(
                    lottie: "plant",
                    title: "Breathe again",
                    testimonial: "For the first time in a long time, I felt alive again.",
                    author: "Anonymous",
                    lines: [
                        BenefitLine(
                            icon: "lock.circle.fill",
                            color: .red,
                            label: "Cut loose from what once controlled you"
                        ),
                        BenefitLine(
                            icon: "arrow.up.circle.fill",
                            color: .indigo,
                            label: "Discover the strength you always carried inside"
                        ),
                        BenefitLine(
                            icon: "leaf.circle.fill",
                            color: .green,
                            label: "Step into days filled with energy and freedom"
                        )
                    ]
                )

                DiscountButton()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(32)
        }
        .overlay {
            LinearGradient(colors: [
                .clear,
                .clear,
                .clear,
                .clear,
                .clear,
                .clear,
                Theme.backgroundC,
                Theme.backgroundC
            ], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 18) {
                GlassButton("Start your Journey") {
                    action()
                }
                .foregroundStyle(Color.accentBlue)
                
                HStack(spacing: 4) {
                    Image(systemName: "checkmark")
                        .font(.footnote.weight(.medium))
                    Text("No commitment • Cancel anytime")
                }
                .multilineTextAlignment(.center)
                .opacity(0.65)
                .font(.grotesk(.footnote, weight: .regular))
                .padding(.horizontal, 32)
                .padding(.horizontal)
                .lineSpacing(4.0)
            }
            .padding(.vertical)
            .padding(.horizontal, 32)
        }
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        .onAppear(perform: setup)
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.25) {
            triggerCheckmark = true
        }
        
        if !vm.paywallReached {
            SleepTask.sleep(seconds: 0.5) {
                vm.paywallReached = true
            }
        }
        
        if vm.username.isEmpty {
            vm.username = CoreDataStack.shared.fetchEntities(for: UserEntity.self, fetchLimit: 1).first?.name ?? "unknown"
        }

        // If the user hasn't seen the discount yet. Delete it so it reschedules (avoids to show up while the app is open)
        let notificationId: String = UserDefaultsManager.shared.get(forKey: "paywall_discount", as: String.self) ?? ""
        lnManager.removePendingRequest(withIdentifier: notificationId)
        UserDefaultsManager.shared.set("", forKey: "paywall_discount")
        Logger.debug("Notification removed")
    }
    
    private func action() {
//        Superwall.shared.register(placement: Placements.paywallMain.rawValue) {
//            dismissPaywall()
//        }
    }
    
    private func dismissPaywall() {
        guard superwall.subscriptionStatus.isActive else { return }

        withAnimation(.smooth(duration: 0.5)) {
            vm.firstTimeUser = false
        }
        
        let notificationId: String = UserDefaultsManager.shared.get(forKey: "paywall_discount", as: String.self) ?? ""
        lnManager.removePendingRequest(withIdentifier: notificationId)
    }
    
    private func triggerNotification(_ oldValue: ScenePhase, _ newValue: ScenePhase) async {
//        guard !vm.discountSeen else { return }
        
        if newValue == .background && (oldValue == .active || oldValue == .inactive) {
            // Check if we already stored a paywall notification
            if let existingId: String = UserDefaultsManager.shared.get(forKey: "paywall_discount", as: String.self),
               !existingId.isEmpty {
                Logger.debug("[NOTIFICATION] Notification already scheduled")
                return // Notification already scheduled
            }
            
            let identifier = UUID().uuidString
            
            var localNotification = LocalNotification(
                identifier: identifier,
                title: "\(vm.username), we didn't give up on you.",
                body: "🎁⏳ Limited time offer: Get 80% off BLOCKR and start your new life.",
                timeInterval: 5 * 60, // 5 minutes
                repeats: false,
                timeSensitive: false
            )
            
            localNotification.userInfo = ["link_key": LinkView.paywall.rawValue]
            
            await lnManager.schedule(localNotification: localNotification)
            
            Logger.debug("[NOTIFICATION] Notification scheduled for \(identifier)")
            
            UserDefaultsManager.shared.set(identifier, forKey: "paywall_discount")
            // Remove this if user purchases
        }
    }
    @ViewBuilder
    private func Divisor() -> some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(width: 200, height: 4.0)
            .opacity(0.15)
    }
    
    struct BenefitLine: Identifiable {
        var id: UUID = UUID()
        
        let icon: String
        let color: Color
        let label: String
    }
    
    @ViewBuilder
    private func BenefitSection(
        lottie: String,
        title: String,
        testimonial: String,
        author: String,
        lines: [BenefitLine]
    ) -> some View {
        VStack(spacing: 24) {
            LottieView(animation: .named(lottie))
                .looping()
                .frame(square: 128)
            
            Text(title)
                .font(.grotesk(.title2, weight: .semibold))
            
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(lines) { line in
                    HStack(spacing: 10) {
                        Image(systemName: line.icon)
                            .font(.system(size: 32))
                            .foregroundStyle(.white, line.color)
                        
                        Text(line.label)
                            .font(.grotesk(.body, weight: .semibold))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical)
            
            HStack(spacing: 6) {
                ForEach(0..<5) { index in
                    Image(systemName: "star.fill")
                        .font(.system(size: 24))
                }
                .foregroundStyle(.yellow)
            }
            .padding(16)
            .background {
                Capsule(style: .continuous)
                    .stroke(lineWidth: 3.0)
                    .opacity(0.15)
            }

            
            VStack(spacing: 16) {
                Text("“\(testimonial)”")
                    .multilineTextAlignment(.center)
                    .font(.grotesk(.body, weight: .regular))
                    .lineSpacing(4.0)
                
                Text(author)
                    .font(.grotesk(.footnote, weight: .regular))
                    .opacity(0.65)
            }
        }

    }
    
    @ViewBuilder
    private func DiscountButton() -> some View {
        VStack(alignment: .center, spacing: 24) {
            LottieView(animation: .named("wrapped-gift"))
                .looping()
                .frame(square: 72)
            
            VStack(alignment: .center, spacing: 8) {
                
                Text("Special Discount!")
                    .font(.grotesk(.largeTitle, weight: .semibold))
                
                Text("We have something special for you!")
                    .font(.grotesk(.subheadline, weight: .medium))
                    .opacity(0.65)
            }
            
            Button {
                Logger.debug(Superwall.shared.subscriptionStatus.description)
                Superwall.shared.register(placement: placementFromAge) {
                    dismissPaywall()
                }
            } label: {
                HStack(spacing: 8) {
                    Text("Claim Now")
                    
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                }
                .font(.grotesk(.title3, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .foregroundStyle(Color.accentBlue)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 32)
        .padding(.vertical, 28)
        .background(Theme.foregroundC, in: .rect(cornerRadius: 24, style: .continuous))

    }

    var placementFromAge: String {
//        switch vm.ageGroup {
//        case "Under 18": AgePlacements.ageUnder18.rawValue
//        case "18-23": AgePlacements.age18to23.rawValue
//        case "24-29": AgePlacements.age24to29.rawValue
//        case "30-39": AgePlacements.age30to39.rawValue
//        case "Above 40": AgePlacements.ageAbove40.rawValue
//        default: Placements.paywallDiscount.rawValue
//        }
        return ""
    }
    
    /*
     
     OBOption(emoji: "", label: "Under 18", value: 16),
     OBOption(emoji: "", label: "18-23", value: 18),
     OBOption(emoji: "", label: "24-29", value: 24),
     OBOption(emoji: "", label: "30-39", value: 30),
     OBOption(emoji: "", label: "Above 40", value: 41),

     */
}

#Preview {
    OBQuizPaywall()
        .environmentObject(OBUserViewModel())
        .environmentObject(LocalNotificationManager())
}
