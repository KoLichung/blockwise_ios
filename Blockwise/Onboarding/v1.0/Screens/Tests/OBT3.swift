//
//  OBT3.swift
//  Blockwise
//
//  Created by Ivan Sanna on 30/12/25.
//

import SwiftUI

struct OBT3: View {
    @EnvironmentObject var vm: OBVM
    @State private var appearAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            Space(height: 18)
            
            Text("\(AppConfiguration.name) is designed to fit real life.")
                .font(.grotesk(size: 26, weight: .semibold))
                .padding(.trailing)
                .lineSpacing(2.0)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth, value: appearAnimation)
                .frame(maxWidth: .infinity, alignment: .leading)
            
//            Image(.chart2)
//                .resizable()
//                .scaledToFit()
//                .opacity(appearAnimation ? 1 : 0)
//                .offset(y: appearAnimation ? 0 : 32)
//                .scaleEffect(appearAnimation ? 1 : 0.95)
//                .animation(.smooth.delay(0.1), value: appearAnimation)

            HStack(spacing: 18) {
                Circle()
                    .frame(square: 44)
                    .foregroundStyle(.secondary.opacity(0.15))
                    .overlay {
                        Text("🙌")
                            .font(.system(size: 20))
                    }
                
                Text("With \(AppConfiguration.name), you **don't need to quit** your phone.")
                    .font(.grotesk(.body, weight: .regular))
                    .opacity(0.5)
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.2), value: appearAnimation)

            HStack(spacing: 18) {
                Circle()
                    .frame(square: 44)
                    .foregroundStyle(.secondary.opacity(0.15))
                    .overlay {
                        Text("☘️")
                            .font(.system(size: 20))
                    }
                
                Text("We help you build a **healthier and more intentional** relationship with your phone.")
                    .font(.grotesk(.body, weight: .regular))
                    .opacity(0.5)
            }
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.25), value: appearAnimation)

        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
    
    private func action() {
        vm.nextPage(progressBar: 0.33)
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.1) {
            withAnimation {
                appearAnimation = true
            }
        }
    }

}


#Preview {
    OBT3()
        .environmentObject(OBVM())
}

/*
 enum OBTPhase: Int, CaseIterable {
     case one = 1
     case two = 2
     case three = 3
     case four = 4
     
     var offsetY: CGFloat {
         switch self {
         case .one: -48
         case .two: -235
         case .three: 0
         case .four: -64
         }
     }
     
     var label: String {
         switch self {
         case .one: "Blocked apps will appear faded in your Home Screen."
         case .two: "You will have full control on the time you spend on them."
         case .three: "A Live Activity timer will guide you through your session."
         case .four: "When the timer hits zero, your app will be closed automatically."
         }
     }
 }

 struct OBT3: View {
     @EnvironmentObject var lnManager: LocalNotificationManager
     @EnvironmentObject var vm: OBVM
     @State private var phase: OBTPhase = .one
     
     @State private var moveOne: Bool = false
     @State private var moveTwo: Bool = false
     @State private var remainingTime: Int = 300-1
     @State private var timer: Timer? = nil
     
     @State private var isAuth: Bool = false
 //    let columns: [GridItem] = .init(repeating: GridItem(spacing: 12), count: 4)
     
     @State private var appearAnimation: Bool = false
     @State private var fadeApps: Bool = false
     
     @State private var isLoading: Bool = false
     @State private var showChevronHint: Bool = false
     
     let screenHeight: CGFloat = UIScreen.main.bounds.height
     let screenWidth: CGFloat = UIScreen.main.bounds.width
     
     let bgColor: Color = Theme.backgroundC

     let columns = 4
     let items = Array(0..<12)
     
     @State private var addApps: Bool = false
     
     var body: some View {
         VStack {
             Image(.iphoneShape)
                 .resizable()
                 .scaledToFit()
                 .opacity(0.25)
                 .offset(y: appearAnimation ? 0 : -32)
                 .overlay(alignment: .top) {
                     VStack(spacing: 12) {
                         ForEach(items.chunked(into: columns), id: \.self) { row in
                             HStack(spacing: 12) {
                                 ForEach(row, id: \.self) { index in
                                     if index == 11 || index == 10 {
                                         RoundedRectangle(cornerRadius: 16, style: .continuous)
                                             .aspectRatio(1.0, contentMode: .fit)
                                             .foregroundStyle(.clear)
                                     } else {
                                         RoundedRectangle(cornerRadius: 16, style: .continuous)
                                             .aspectRatio(1.0, contentMode: .fit)
                                             .foregroundStyle(Color.secondary.opacity(0.15))
                                             .overlay {
                                                 if index == 2 {
                                                     ZStack {
                                                         Image("instagram-icon")
                                                             .resizable()
                                                             .scaledToFit()
                                                             .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                                         
                                                         RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                             .opacity(fadeApps ? 0.65 : 0.0)
                                                             .foregroundStyle(.black)
                                                     }
                                                 }
                                                 
 //                                                if index == 7 {
 //                                                    Image("chess-icon")
 //                                                        .resizable()
 //                                                        .scaledToFit()
 //                                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
 //                                                }
                                                 
 //                                                if index == 8 {
 //                                                    Image("chess-icon")
 //                                                        .resizable()
 //                                                        .scaledToFit()
 //                                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
 //                                                }
                                                 
                                                 if index == 5 {
                                                     ZStack {
                                                         Image("tiktok-icon")
                                                             .resizable()
                                                             .scaledToFit()
                                                             .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                                         
                                                         RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                             .opacity(fadeApps ? 0.65 : 0.0)
                                                             .foregroundStyle(.black)
                                                     }
                                                 }

                                             }
                                             .opacity(appearAnimation ? 1 : 0)
                                             .scaleEffect(appearAnimation ? 1 : 1.5)
                                             .animation(.smooth(duration: 0.35, extraBounce: 0.15),
                                                        value: appearAnimation)
                                     }
                                 }
                             }
                         }
                     }
                     .opacity(phase.rawValue > 2 ? 0 : 1)
                     .blur(radius: phase.rawValue > 2 ? 16 : 0)
                     .padding(32)
                     .offset(y: 72)
                     .scaleEffect(phase.rawValue > 2 ? 0.5 : 1.0)
                 }
                 .overlay(alignment: .top) {
                     VStack(alignment: .leading, spacing: 10) {
                         ZStack {
                             RoundedRectangle(cornerRadius: 32, style: .continuous)
                                 .frame(height: 180)
                                 .foregroundStyle(Theme.backgroundC)
                             
                             RoundedRectangle(cornerRadius: 32, style: .continuous)
                                 .frame(height: 180)
                                 .foregroundStyle(Color.secondary)
                                 .opacity(0.25)
                         }
                         
                         ZStack {
                             RoundedRectangle(cornerRadius: 32, style: .continuous)
                                 .frame(width: 72, height: 8)
                                 .foregroundStyle(Theme.backgroundC)
                             
                             RoundedRectangle(cornerRadius: 32, style: .continuous)
                                 .frame(width: 72, height: 8)
                                 .foregroundStyle(Color.secondary)
                                 .opacity(0.25)
                         }
                         
                         ZStack {
                             RoundedRectangle(cornerRadius: 32, style: .continuous)
                                 .frame(width: 144, height: 8)
                                 .foregroundStyle(Theme.backgroundC)
                             
                             RoundedRectangle(cornerRadius: 32, style: .continuous)
                                 .frame(width: 144, height: 8)
                                 .foregroundStyle(Color.secondary)
                                 .opacity(0.25)
                         }
                     }
                     .padding(24)
                     .offset(y: 100)
                     .opacity(phase == .three ? 1 : 0)
                     .offset(y: phase == .three ? 0 : 350)
                 }
                 .overlay(alignment: .top) {
                     Capsule(style: .continuous)
                         .frame(height: phase == .three ? 72 : 32)
                         .frame(maxWidth: phase == .three ? .infinity : 100)
                         .foregroundStyle(Color(hex: 0x181818).opacity(phase == .three ? 1 : 0))
                         .overlay {
                             HStack {
                                 Image(.blockrIconTransparent)
                                     .resizable()
                                     .scaledToFit()
                                     .frame(square: 44)
                                 
                                 Spacer()
                                 
                                 Text(formattedRemainingTime)
                                     .font(.grotesk(size: 40, weight: .regular))
                                     .opacity(0.8)
                                     .foregroundStyle(.white)
                                     .contentTransition(.numericText())
                                     .animation(.smooth, value: remainingTime)
                             }
                             .padding(.horizontal, 20)
                             .opacity(phase == .three ? 1 : 0)
                             .blur(radius: phase == .three ? 0 : 16)
                             .scaleEffect(phase == .three ? 1 : 0.2)
                         }
                         .padding(24)
                 }
                 .overlay(alignment: .bottom) {
                     UnevenRoundedRectangle(
                         topLeadingRadius: 18,
                         bottomLeadingRadius: 42,
                         bottomTrailingRadius: 42,
                         topTrailingRadius: 18,
                         style: .continuous
                     )
                     .frame(height: phase == .two ? 250 : 0)
                     .foregroundStyle(Theme.foregroundC)
                     .overlay {
                         UnevenRoundedRectangle(
                             topLeadingRadius: 18,
                             bottomLeadingRadius: 42,
                             bottomTrailingRadius: 42,
                             topTrailingRadius: 18,
                             style: .continuous
                         )
                         .stroke(lineWidth: 4.0)
                         .frame(height: phase == .two ? 250 : 0)
                         .foregroundStyle(.secondary.opacity(0.15))
                     }
                     .overlay {
                         
                         VStack(spacing: 16) {
                             
 //                            Text("Choose Duration")
 //                                .font(.grotesk(size: 18.5, weight: .semibold))
                             
                             Picker("", selection: .constant(5)) {
                                 ForEach(1..<90) { min in
                                     Text("\(min) min")
                                         .tag(min)
                                         .foregroundStyle(.textC)
                                         .font(.grotesk(size: 20, weight: .regular))
                                 }
                             }
                             .padding(.horizontal)
                             .pickerStyle(.wheel)
                         }
                         .padding(.top)
                         .opacity(phase == .two ? 1 : 0)
                     }
                     .padding()
 //                    .mask {
 //                        UnevenRoundedRectangle(
 //                            topLeadingRadius: 18,
 //                            bottomLeadingRadius: 44,
 //                            bottomTrailingRadius: 44,
 //                            topTrailingRadius: 18,
 //                            style: .continuous
 //                        )
 //                        .frame(height: phase == .two ? 400 : 0)
 //                    }
                 }
                 .overlay(alignment: .top) {
                     VStack(spacing: 32) {
                         Image(.instagramIcon)
                             .resizable()
                             .scaledToFit()
                             .frame(square: 64)
                             .clipShape(.rect(cornerRadius: 18, style: .continuous))
                         
                         VStack(spacing: 10) {
                             Text("Instagram is now blocked.")
                                 .font(.grotesk(size: 22, weight: .semibold))
                             
                             Text("Available again in 5 minutes")
                                 .font(.grotesk(size: 18, weight: .regular))
                                 .foregroundStyle(.secondary)
                         }
                     }
                     .offset(y: 64)
                     .rotation3DEffect(.degrees(phase == .four ? 0 : 25),
                                       axis: (1.0, 0.0, 0.0), anchor: .top)
                     .scaleEffect(phase == .four ? 1.0 : 0.5)
                     .opacity(phase == .four ? 1 : 0)
                     .offset(y: phase == .four ? 90 : 0)
                 }
                 .padding(32)
                 .offset(y: phase.offsetY)
                 .scaleEffect(appearAnimation ? 1 : 2)
                 .opacity(appearAnimation ? 1 : 0)
                 .animation(.smooth(duration: 0.45).delay(0.15), value: appearAnimation)
         }
         .scaleEffect(fadeApps ? phase == .three ? 1.02 : phase == .four ? 0.85 : phase == .two ? 1.02 : 0.95 : 0.9)
         .frame(maxWidth: .infinity, maxHeight: .infinity)
         .rotation3DEffect(.degrees(phase == .three ? 5 : phase == .two ? 5 : 0), axis: (1, 0, 0))
         .background(bgColor, ignoresSafeAreaEdges: .all)
         .overlay {
             LinearGradient(
                 colors: [
                     .clear,
                     .clear,
                     .clear,
                     .clear,
                     .clear,
                     bgColor,
                     bgColor,
                     bgColor,
                     bgColor
                 ],
                 startPoint: .top,
                 endPoint: .bottom
             )
             .ignoresSafeArea()
             .allowsHitTesting(false)
             .opacity(phase != .two ? 1 : 0)
             
             LinearGradient(
                 colors: [
                     .clear,
                     .clear,
                     .clear,
                     .clear,
                     bgColor
                 ],
                 startPoint: .bottom,
                 endPoint: .top
             )
             .ignoresSafeArea()
             .allowsHitTesting(false)
             .opacity(phase == .two ? 1 : 0)
         }
         .overlay(alignment: .bottom) {
             VStack(spacing: 32) {
                 VStack(spacing: 14) {
 //                    ZStack {
 //                        if phase == .one {
 //                            Text("QuizPhase.one.label")
 //                                .font(.grotesk(size: 20, weight: .semibold))
 //                                .multilineTextAlignment(.center)
 //                                .frame(maxWidth: .infinity)
 //                                .lineSpacing(2.0)
 //                                .opacity(appearAnimation ? 1 : 0)
 //                                .offset(y: appearAnimation ? 0 : 50)
 //                                .animation(.smooth(duration: 0.5, extraBounce: 0.15).delay(0.35), value: appearAnimation)
 //                                .transition(.move(edge: .leading).combined(with: .offset(x: -100)))
 //                        } else {
 //                            ZStack {
 //                                if phase == .two {
 //                                    Text("QuizPhase.two.label")
 //                                        .font(.grotesk(size: 20, weight: .semibold))
 //                                        .multilineTextAlignment(.center)
 //                                        .frame(maxWidth: .infinity)
 //                                        .lineSpacing(2.0)
 //                                        .transition(.move(edge: .leading).combined(with: .offset(x: -100)))
 //                                } else {
 //                                    ZStack {
 //                                        if phase == .three {
 //                                            Text("QuizPhase.three.label")
 //                                                .font(.grotesk(size: 20, weight: .semibold))
 //                                                .multilineTextAlignment(.center)
 //                                                .frame(maxWidth: .infinity)
 //                                                .lineSpacing(2.0)
 //                                                .transition(.move(edge: .leading).combined(with: .offset(x: -100)))
 //                                        } else {
 //                                            Text("QuizPhase.four.label")
 //                                                .font(.grotesk(size: 20, weight: .semibold))
 //                                                .multilineTextAlignment(.center)
 //                                                .frame(maxWidth: .infinity)
 //                                                .lineSpacing(2.0)
 //                                                .transition(.move(edge: .trailing).combined(with: .offset(x: 100)))
 //                                        }
 //                                    }
 //                                    .transition(.move(edge: .trailing).combined(with: .offset(x: 100)))
 //                                }
 //                            }
 //                            .transition(.move(edge: .trailing).combined(with: .offset(x: 56)))
 //                        }
 //                    }
 //                    .animation(.smooth(duration: 0.45).delay(0.02), value: phase)

                     if phase == .one {
                         Text(OBTPhase.one.label)
                             .font(.grotesk(size: 28, weight: .semibold))
                             .multilineTextAlignment(.center)
                             .frame(maxWidth: .infinity)
                             .lineSpacing(2.0)
                             .opacity(appearAnimation ? 1 : 0)
                             .offset(y: appearAnimation ? 0 : 50)
                             .animation(.smooth(duration: 0.5, extraBounce: 0.15).delay(0.35), value: appearAnimation)
                             .transition(.move(edge: .leading).combined(with: .offset(x: -100)))
                     } else {
                         ZStack {
                             if phase == .two {
                                 Text(OBTPhase.two.label)
                                     .font(.grotesk(size: 28, weight: .semibold))
                                     .multilineTextAlignment(.center)
                                     .frame(maxWidth: .infinity)
                                     .lineSpacing(2.0)
                                     .transition(.move(edge: .leading).combined(with: .offset(x: -100)))
                             } else {
                                 ZStack {
                                     if phase == .three {
                                         Text(OBTPhase.three.label)
                                             .font(.grotesk(size: 28, weight: .semibold))
                                             .multilineTextAlignment(.center)
                                             .frame(maxWidth: .infinity)
                                             .lineSpacing(2.0)
                                             .transition(.move(edge: .leading).combined(with: .offset(x: -100)))
                                     } else {
                                         Text(OBTPhase.four.label)
                                             .font(.grotesk(size: 28, weight: .semibold))
                                             .multilineTextAlignment(.center)
                                             .frame(maxWidth: .infinity)
                                             .lineSpacing(2.0)
                                             .transition(.move(edge: .trailing).combined(with: .offset(x: 100)))
                                     }
                                 }
                                 .transition(.move(edge: .trailing).combined(with: .offset(x: 100)))
                             }
                         }
                         .transition(.move(edge: .trailing).combined(with: .offset(x: 56)))
                     }
                 }
                 
                 HStack(spacing: 10) {
                     ForEach(QuizPhase.allCases, id: \.self) { p in
                         Circle()
                             .frame(square: 8)
                             .foregroundStyle(Color.secondary.opacity(0.35))
                             .overlay {
                                 Circle()
                                     .frame(square: 8)
                                     .opacity(p.rawValue <= phase.rawValue ? 1 : 0)
                             }
                     }
                 }
 //                .padding(.horizontal, 12)
 //                .padding(.vertical, 10)
 //                .background(Color.tertiaryBlue, in: Capsule(style: .continuous))
                 .opacity(appearAnimation ? 1 : 0)
                 .offset(y: appearAnimation ? 0 : 50)
                 .animation(.smooth(duration: 0.5, extraBounce: 0.15).delay(0.35), value: appearAnimation)
                 
                 GlassButton {
                     action()
                 } label: {
                     HStack(spacing: 10) {
                         if phase == .four {
                             Image(systemName: "plus")
                                 .font(.system(size: 20, weight: .semibold))
                                 .transition(.scale)
                         }
                         
                         Text(phase == .four ? "Add apps" : "Continue")
                             .font(.grotesk(size: 20, weight: .semibold))
                     }
                 }
                 .contentTransition(.numericText())
                 .opacity(appearAnimation ? 1 : 0)
                 .offset(y: appearAnimation ? 0 : 100)
                 .animation(.smooth(duration: 0.5, extraBounce: 0.15).delay(1.0), value: appearAnimation)
                 
             }
             .padding(.horizontal, 32)
             .padding(.vertical)
         }
         .overlay {
             ZStack {
                 Color.black.opacity(0.8).ignoresSafeArea()
                 
                 RoundedRectangle(cornerRadius: 20, style: .continuous)
                     .frame(square: 76)
                     .foregroundStyle(.thinMaterial)
                     .overlay {
                         ProgressView()
                             .controlSize(.large)
                             .foregroundStyle(.white)
                     }
                     .scaleEffect(isLoading ? 1 : 0.9)
                     .animation(.smooth(duration: 0.35, extraBounce: 0.15), value: isLoading)
                 
                 if showChevronHint {
                     Image(systemName: "chevron.compact.up")
                         .font(.system(size: 64))
                         .foregroundStyle(.white)
                         .phaseAnimator([true, false]) { view, phase in
                             view
                                 .offset(y: phase ? -24 : 0)
                                 .opacity(phase ? 1 : 0.75)
                         } animation: { _ in
                                 .smooth(duration: 0.5)
                         }
                         .offset(
                             x: 75,
                             y: 200
                         )
                 }

             }
             .opacity(isLoading ? 1 : 0)

         }
         .sheet(isPresented: $addApps) {
             OBCreateFirstBlock()
         }
         .onAppear(perform: setup)
     }
     
     private func setup() {
         SleepTask.sleep(seconds: 0.15) {
             appearAnimation = true
         }
         
         SleepTask.sleep(seconds: 1.25) {
             withAnimation {
                 fadeApps = true
             }
         }
     }
     
     @available(iOS 26.0, *)
     private func checkAlarmKitAuth(completion: @escaping () -> Void) async throws {
         switch AlarmManager.shared.authorizationState {
         case .notDetermined:
             let status = try await AlarmManager.shared.requestAuthorization()
             isAuth = status == .authorized
             lnManager.isAlarmAuthGranted = isAuth
         case .denied:
             isAuth = false
             lnManager.isAlarmAuthGranted = isAuth
         case .authorized:
             isAuth = true
             lnManager.isAlarmAuthGranted = isAuth
         @unknown default:
             fatalError()
         }
         
         completion()
     }
     
     private func action() {
         withAnimation(.smooth(duration: 0.5, extraBounce: 0.15)) {
             if phase == .one {
                 phase = .two
             } else if phase == .two {
                 phase = .three
                 startTimer()
             } else if phase == .three {
                 
                 #if targetEnvironment(simulator)
                 phase = .four
                 timer?.invalidate()
                 SleepTask.sleep(seconds: 0.15) {
                     withAnimation(.smooth(duration: 0.5, extraBounce: 0.35)) {
                         moveOne = true
                     }
                 }
                 
                 SleepTask.sleep(seconds: 0.25) {
                     withAnimation(.smooth(duration: 0.5, extraBounce: 0.35)) {
                         moveTwo = true
                     }
                 }
                 #else
                 if #available(iOS 26.0, *) {
                     isLoading = true
                     
                     SleepTask.sleep(seconds: 0.25) {
                         showChevronHint = true
                     }
                     
                     Task {
                         do {
                             try await checkAlarmKitAuth {
                                 DispatchQueue.main.async {
                                     withAnimation(.smooth(duration: 0.5, extraBounce: 0.15)) {
                                         isLoading = false
                                         showChevronHint = false
                                         phase = .four
                                         timer?.invalidate()
                                         SleepTask.sleep(seconds: 0.15) {
                                             withAnimation(.smooth(duration: 0.5, extraBounce: 0.35)) {
                                                 moveOne = true
                                             }
                                         }
                                         
                                         SleepTask.sleep(seconds: 0.25) {
                                             withAnimation(.smooth(duration: 0.5, extraBounce: 0.35)) {
                                                 moveTwo = true
                                             }
                                         }
                                     }
                                 }
                             }
                         } catch {
                             Logger.error(error.localizedDescription)
                             DispatchQueue.main.async {
                                 isLoading = false
                                 showChevronHint = false
                             }
                         }
                     }
                 } else {
                     phase = .four
                     timer?.invalidate()
                     SleepTask.sleep(seconds: 0.15) {
                         withAnimation(.smooth(duration: 0.5, extraBounce: 0.35)) {
                             moveOne = true
                         }
                     }
                     
                     SleepTask.sleep(seconds: 0.25) {
                         withAnimation(.smooth(duration: 0.5, extraBounce: 0.35)) {
                             moveTwo = true
                         }
                     }
                 }
                 #endif
                                 
             } else {
                 // ACTION
                 vm.nextPage()
             }
         }
     }
     private func startTimer() {
         timer?.invalidate()
         remainingTime = 300
         timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
             if remainingTime > 0 {
                 remainingTime -= 1
             } else {
                 timer?.invalidate()
             }
         }
     }

     
     @ViewBuilder
     private func Notification(title: String, description: String, time: String, timeSensitive: Bool = false) -> some View {
         RoundedRectangle(cornerRadius: 22)
             .fill(Color.tertiaryBlue)
             .shadow(color: .black.opacity(0.1), radius: 2, y: 4)
             .shadow(color: .black.opacity(0.1), radius: 2, y: -0.5)
             .frame(height: 60)
             .overlay {
                 HStack(spacing: 12) {
                     Image(Configuration.appIcon)
                         .resizable()
                         .scaledToFit()
                         .frame(width: 40, height: 40)
                         .clipShape(RoundedRectangle(cornerRadius: 10))
                     
                     VStack(alignment: .leading, spacing: 3) {
                         if timeSensitive {
                             Text("Time sensitive".uppercased())
                                 .font(.footnote.weight(.semibold))
                                 .foregroundStyle(.secondary)
                         }
                         
                         HStack {
                             Text(title)
                                 .font(.subheadline.weight(.semibold))
                             
                             Spacer()
                             
                             Text(time)
                                 .font(.system(size: 14))
                                 .foregroundStyle(.secondary)
                         }
                         
                         if !timeSensitive {
                             Text(description)
                                 .font(.system(size: 14))
                                 .opacity(0.8)
                         }
                     }
                     .opacity(0.8)
                 }
                 .padding()
             }
             .padding(.horizontal, 28)
     }

     private var formattedDate: String {
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "EEEE, d MMMM"
         return dateFormatter.string(from: .now)
     }
     
     private var formattedTime: String {
         let currentTime = Date()
         let formattedDate = currentTime.formatted(date: .omitted, time: .shortened)
         let dateFormatter = DateFormatter()
         
         if formattedDate.contains("M") {
             dateFormatter.dateFormat = "h:mm"
         } else {
             dateFormatter.dateFormat = "HH:mm"
         }
         
         return dateFormatter.string(from: currentTime)
     }
     
     var formattedRemainingTime: String {
         let minutes = remainingTime / 60
         let seconds = remainingTime % 60
         return String(format: "%d:%02d", minutes, seconds)
     }
 }

 */
