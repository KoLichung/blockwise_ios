//
//  UnlockScreenView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 02/12/25.
//

import Lottie
import SwiftUI
import CoreData
import ManagedSettings
import AlarmKit

struct UnlockScreenView: View {
    @EnvironmentObject var vm: UserViewModel
    @EnvironmentObject var toastManager: ToastManager
    
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dismiss) var dismiss
    
    // Limit View
    @State private var limitAppearAnimation: Bool = false
    @State private var limitUnlockAnyway: Bool = false
    
    // Countdown View
    @State private var countdownAppearAnimation: Bool = false
        
    // Slider related - default minute value
    @State private var value: Double = 5
    
    @State private var showResetStreak: Bool = false
    
    var goal: TimeInterval {
        vm.user?.goal(for: .now) ?? 3600
//        return 0
    }
    
    var range: ClosedRange<Int> {
        // Compute remaining time in seconds, clamp to >= 0
        let availableTime = max(0, goal - vm.usage)
        // Convert to minutes, clamp upper bound to at least 1 to avoid 1...0
        let remainingMinutes = max(1, Int(availableTime / 60))
        return 1...remainingMinutes
    }
    
    // Entity related
    @State private var appToken: ApplicationToken?
    @State private var blockEntity: BlockEntity?
    
    private var isLimit: Bool {
        vm.usage >= goal && !(blockEntity?.isOpen ?? false)
    }
    
    // Computed property
    private var isCooldown: Bool {
        guard let next = blockEntity?.nextAvailableDate else { return false }
        return next > .now && next.timeIntervalSinceNow > 10
        // We also check if the distance from now is greater that 10 seconds
        // this way we avoid the screen jumping to cooldown view as soon as the user taps to unlock
    }
    
    // Clean accessor for cooldown end date
    private var cooldownDate: Date? {
        guard let next = blockEntity?.nextAvailableDate,
              next > .now,
              next.timeIntervalSinceNow > 10 else { return nil }
        return next
    }
    
    // Unlock anyway countdown (label-only)
    @State private var unlockCountdownRemaining: Int = 0
    let countdownDuration: Int = 60 // seconds
    @State private var unlockCountdownTask: Task<Void, Never>?
        
    var body: some View {
        VStack(spacing: 32) {
            if isLimit {
                LimitReachedView()
            } else if isCooldown {
                CooldownView()
            } else {
                SelectTimeView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        .sheet(isPresented: $limitUnlockAnyway) {
            OvercomeLimitView {
                dismissView()
            }
        }
        .safeAreaInset(edge: .bottom) {
            BottomArea()
                .padding(.horizontal, 32)
        }
        .onChange(of: scenePhase) {
            if scenePhase == .background {
                dismissView()
            }
        }
        .blur(radius: showResetStreak ? 16 : 0)
        .overlay {
            if showResetStreak {
                ResetStreaksView(showStreakReset: $showResetStreak) { interval in
                    actionAndStreakReset(for: interval)
                } dismissCompletion: {
                    withAnimation {
                        showResetStreak = false
                    }
                    dismiss()
                }
            }
        }
        // ✅ LOGIC TIMER (not UI)
        .onReceive(
            Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        ) { _ in
            if let next = blockEntity?.nextAvailableDate,
               next <= .now {
                Logger.debug("Finished")
            }
        }
        .onChange(of: isLimit) { _, newValue in
            if newValue {
                startUnlockCountdown()
            } else {
                stopUnlockCountdown()
            }
        }
        .onAppear {
            setup()
            if isLimit {
                startUnlockCountdown()
            }
        }
        .onDisappear {
            stopUnlockCountdown()
        }
    }
    
    // MARK: - Functions
    private func setup() {
        loadBlock()
    }
    
    private func dismissView() {
        dismiss()
        UserDefaultsManager.shared.setToken(token: nil, value: false)
    }
    
    private func startUnlockCountdown() {
        unlockCountdownRemaining = countdownDuration
        unlockCountdownTask?.cancel()
        unlockCountdownTask = Task { @MainActor in
            while !Task.isCancelled, unlockCountdownRemaining > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { break }
                unlockCountdownRemaining -= 1
            }
        }
    }
    
    private func stopUnlockCountdown() {
        unlockCountdownTask?.cancel()
        unlockCountdownTask = nil
    }
        
    // MARK: - UI components
    @ViewBuilder
    private func SelectTimeView() -> some View {
        VStack(spacing: 32) {
            if let appToken {
                Label(appToken)
                    .labelStyle(.iconOnly)
                    .scaleEffect(2.75)
            } else {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .frame(square: 56)
                    .foregroundStyle(.secondary.opacity(0.15))
            }

            Text("How much time do you need?")
                .font(.grotesk(.title, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineSpacing(2.0)
                .foregroundStyle(.textC)
            
            Picker("", selection: $value) {
                ForEach(range, id: \.self) { value in
                    Text("\(value) min")
                        .font(.grotesk(size: 20, weight: .medium))
                        .tag(Double(value))
                }
            }
            .pickerStyle(.wheel)

            HStack(spacing: 10) {
                Text(Date.now, style: .time)
                Image(systemName: "arrow.right")
                Text(Date.now.addingTimeInterval(TimeInterval(value * 60)), style: .time)
                    .contentTransition(.numericText())
            }
            .font(.grotesk(.subheadline, weight: .medium))
            .foregroundStyle(.secondary.opacity(0.75))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background {
                Capsule(style: .continuous)
                    .foregroundStyle(.secondary.opacity(0.15))
            }
        }
    }
    
    @ViewBuilder
    private func CooldownView() -> some View {
        let end = blockEntity?.nextAvailableDate ?? .now
        let start = blockEntity?.openEndTime ?? .now
        
        VStack(spacing: 32) {
            if let appToken {
                Label(appToken)
                    .labelStyle(.iconOnly)
                    .scaleEffect(2.75)
            } else {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .frame(square: 56)
                    .foregroundStyle(.secondary.opacity(0.15))
            }
            
            VStack(spacing: 14) {
                Text("Take a break")
                    .font(.grotesk(.title, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2.0)
                    .foregroundStyle(.textC)
                
                Text("Please come back later")
                    .font(.grotesk(.body, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            
            Space(height: 10)
            
            Text(timerInterval: .now...end, countsDown: true)
                .font(.grotesk(.title, weight: .medium))
                .foregroundStyle(.secondary)

            // Cooldown progress
            TimelineView(.periodic(from: .now, by: 0.1)) { context in
                let now = context.date
                let total = end.timeIntervalSince(start)
                let elapsed = now.timeIntervalSince(start)
                let progress = min(max(elapsed / total, 0), 1)
                
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.secondary.opacity(0.15))
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .frame(width: geo.size.width * progress)
                                .foregroundStyle(Color.blueAccent)
                                .animation(.linear(duration: 0.1), value: progress)
                        }
                }
                .frame(height: 40)
            }
        }
    }
    
    @ViewBuilder
    private func LimitReachedView() -> some View {
        VStack(spacing: 32) {
            Image(systemName: "hexagon.fill")
                .font(.system(size: 144))
                .rotationEffect(.degrees(90))
                .foregroundStyle(Color.blueAccent.opacity(0.15))
                .scaleEffect(limitAppearAnimation ? 1 : 0.8)
                .animation(.smooth(duration: 0.25, extraBounce: 0.45), value: limitAppearAnimation)
                .overlay {
                    ExclamationShape()
                        .aspectRatio(0.38, contentMode: .fit)
                        .frame(square: 90)
                        .foregroundStyle(Color.blueAccent)
                        .scaleEffect(limitAppearAnimation ? 1 : 0.6)
                        .animation(.smooth(duration: 0.35, extraBounce: 0.45), value: limitAppearAnimation)
                }
                .offset(y: limitAppearAnimation ? 0 : 32)
                .animation(.smooth(duration: 0.35, extraBounce: 0.45), value: limitAppearAnimation)
            
            VStack(spacing: 14) {
                Text("You're out of time")
                    .font(.grotesk(.title, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2.0)
                    .foregroundStyle(.textC)
                
                Text("Nice job staying on track today!")
                    .font(.grotesk(.body, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            
            if vm.currentStreak > 0 {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(vm.currentStreak)")
                            .font(.grotesk(size: 44, weight: .bold))
                            .foregroundStyle(.orange)
                        
                        Text("Streak Days")
                            .font(.grotesk(size: 16, weight: .semibold))
                            .foregroundStyle(.orange)
                            .opacity(0.8)
                    }
                    .offset(y: -10)
                    
                    Spacer()
                    
                    LottieView(animation: .named("fire"))
                        .looping()
                        .frame(square: 128)
                        .background {
                            LottieView(animation: .named("fire"))
                                .looping()
                                .frame(square: 128)
                                .scaleEffect(1.1)
                                .brightness(1.0)
                                .shadow(radius: 8)
                                .offset(y: -2)
                        }
                        .background {
//                            Image(.rays)
//                                .resizable()
//                                .scaledToFit()
//                                .scaleEffect(3)
//                                .offset(y: 4)
//                                .rotationEffect(.degrees(limitAppearAnimation ? 360 : 0))
//                                .animation(.linear(duration: 10.0).repeatForever(autoreverses: false), value: limitAppearAnimation)
                        }
                        .offset(x: 40, y: 16)

                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 92)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .foregroundStyle(Color.orange.opacity(0.15))
                        .overlay {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(lineWidth: 8.0)
                                .foregroundStyle(.orange.opacity(0.15))
                        }
                }
                .mask {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                }
            }
                        
        }
        .onAppear {
            SleepTask.sleep(seconds: 0.15) {
                limitAppearAnimation = true
                Haptics.warningFeedback()
            }
        }
    }
    
    var countdownEnded: Bool {
        unlockCountdownRemaining <= 0
    }
    
    @ViewBuilder
    private func BottomArea() -> some View {
        if isLimit {
            VStack(spacing: 14) {
                GlassButton("Go back") {
                    dismissView()
                }

                GlassButton("Unlock anyway\(!countdownEnded ? " (\(unlockCountdownRemaining)s)" : "")", labelColor: .textC, background: Theme.foregroundC) {
                    guard countdownEnded else { return }
                    withAnimation {
                        showResetStreak = true
                    }
                }
                .opacity(!countdownEnded ? 0.6 : 1.0)
            }

        } else if isCooldown {
            VStack(spacing: 14) {
                GlassButton("Go back") {
                    dismissView()
                }

//                GlassButton("Are you stressed?", labelColor: .textC, color: Theme.foregroundC) {
//                    dismissView()
//                }
            }
        } else {
            VStack(spacing: 14) {
                GlassButton("Unlock for \(Int(value)) min") {
                    action()
                }
                
                GlassButton("Nah, I'm good", labelColor: .textC, background: Theme.foregroundC) {
                     dismissView()
                }
            }
        }
    }
}

#Preview {
    UnlockScreenView()
        .environmentObject(ToastManager())
        .environmentObject(UserViewModel())
}

// MARK: - More functions
extension UnlockScreenView {
    private func loadBlock() {
        // Step 1: Get the stored token from UserDefaults
        guard let storedToken = UserDefaultsManager.shared.loadAppToken() else {
            toastManager.error("Something went wrong: Error 18")
            Logger.error("No app token")
            return
        }
        
        // Step 2: Fetch the matching BlockEntity
        let request = NSFetchRequest<BlockEntity>(entityName: "BlockEntity")
        request.predicate = NSPredicate(format: "appTokenString == %@", storedToken.string ?? "")
        request.fetchLimit = 1
        
        // Execute the request
        do {
            let entity = try CoreDataStack.shared.persistentContainer.viewContext.fetch(request).first
            if let entity {
                // Assign values
                appToken = storedToken
                blockEntity = entity
                Logger.success("Entity found!")
            } else {
                // Handle error
                Logger.error("Entity NOT found.")
                toastManager.error("Something went wrong: Error 19")
            }
        } catch {
            // Handle error
            Logger.error(error.localizedDescription)
            toastManager.error("Something went wrong: Error 20")
        }
    }
    
    private func action() {
        guard let blockEntity else {
            toastManager.error("Something went wrong: Error 21")
            return
        }
                
        // Transform to seconds
        let interval = TimeInterval(value * 60)
        
        // Remove shield and schedule auto close
        Task {
            do {
                try await scheduleAutoBlock(blockEntity, interval)
            } catch {
                Logger.error(error.localizedDescription)
                toastManager.error("Something went wrong: Error 23")
            }
        }
        
        // Create the CoreData's data
        do {
            try saveToCoreData(blockEntity, interval)
        } catch {
            Logger.error(error.localizedDescription)
            toastManager.error("Something went wrong: Error 24")
        }
        
        // Start alarm + live activity
        startLiveActivity()
        
        // Dismiss view
        dismissView()
        
        // Inform user
        toastManager.info("App opened for \(Int(value)) minutes.")
    }
    
    private func scheduleAutoBlock(_ blockEntity: BlockEntity, _ interval: TimeInterval) async throws {

        guard let raw = blockEntity.appTokenString, let token = ApplicationToken.fromRawValue(raw) else {
            toastManager.error("Something went wrong: Error 22")
            return
        }
        
        let blockId = blockEntity.identifier ?? ""
        
        try await DeviceActivityManager.shared.open(
            blockId: blockId,
            appToken: token,
            for: interval
        )
    }
    
    private func saveToCoreData(_ blockEntity: BlockEntity, _ interval: TimeInterval) throws {
        // Create record
        try CoreDataStack.shared.createRecord(
            for: blockEntity,
            duration: interval
        )
        
        // Set open state
        blockEntity.isOpen = true
        blockEntity.openStartTime = Date.now
        blockEntity.openEndTime = Date.now.addingTimeInterval(interval)
        
        // Update nextAvailableDate (i.e. cooldown)
        // If there is a cooldown...
        if blockEntity.cooldown > 0 {
            blockEntity.nextAvailableDate = Date.now.addingTimeInterval(interval + blockEntity.cooldown)
        }
        
        // Save context
        try CoreDataStack.shared.saveContext()
    }
    
    private func actionAndStreakReset(for interval: TimeInterval) {
        guard let blockEntity else {
            toastManager.error("Something went wrong: Error 21-B")
            return
        }

        // Remove shield and schedule auto close
        Task {
            do {
                try await scheduleAutoBlock(blockEntity, interval)
            } catch {
                Logger.error(error.localizedDescription)
                toastManager.error("Something went wrong: Error 23-B")
            }
        }

        // Create the CoreData's data
        do {
            try saveToCoreData(blockEntity, interval)
        } catch {
            Logger.error(error.localizedDescription)
            toastManager.error("Something went wrong: Error 24")
        }
        
        // Start alarm + live activity
        startLiveActivity()
        
        // Dismiss view
        dismissView()
        
        // Inform user
        toastManager.info("App opened for \(Int(value)) minutes.")
        
        // Reset streak
        vm.breakStreak()
    }
    
    private func startLiveActivity() {
        if #available(iOS 26.0, *) {
            // Live Activity + Alarm
            Task {
                do {
                    try await setAlarm()
                } catch {
                    Logger.error(error.localizedDescription)
                    DispatchQueue.main.async {
                        toastManager.error(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    @available(iOS 26.0, *)
    private func setAlarm() async throws {
        guard let identifier = blockEntity?.identifier, let id = UUID(uuidString: identifier) else { return }
        
        let interval = TimeInterval(value * 60) - 1 // some delay
        
        // Countdown
        let alarmCountdown = Alarm.CountdownDuration(
            preAlert: interval,
            postAlert: nil
        )

        // Alert
        let alert = AlarmPresentation.Alert(
            title: "Time's up!",
            stopButton: .init(text: "Stop", textColor: .red, systemImageName: "xmark")
        )

        let countdownPresentation = AlarmPresentation.Countdown(title: "App open")
        
        // Presentation
        let presentation = AlarmPresentation(
            alert: alert,
            countdown: countdownPresentation
        )
        
        // Attributes
        /// AlarmAttributes requires the creation of a struct that conforms to the AlarmMetaData protocol.
        /// This will provide additional data to the Alarm UI for the LiveActivity and Dynamic Island, among other functionalitites.
        let attributes = AlarmAttributes<CountdownAttributes>(
            presentation: presentation,
            metadata: .init(),
            tintColor: .blue
        )
        
        // Configuration
        let config = AlarmManager.AlarmConfiguration(
            countdownDuration: alarmCountdown,
            attributes: attributes
        )
        
        // Adding alarm to the System
        let _ = try await AlarmManager.shared.schedule(id: id, configuration: config)
        print("Alarm Set")
    }

}

struct ExclamationShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.addEllipse(in: CGRect(x: 0.04853*width, y: 0.68493*height, width: 0.88462*width, height: 0.31507*height))
        path.move(to: CGPoint(x: 0.00154*width, y: 0.09169*height))
        path.addCurve(to: CGPoint(x: 0.23076*width, y: 0), control1: CGPoint(x: -0.0144*width, y: 0.04286*height), control2: CGPoint(x: 0.09275*width, y: 0))
        path.addLine(to: CGPoint(x: 0.75091*width, y: 0))
        path.addCurve(to: CGPoint(x: 0.98013*width, y: 0.09169*height), control1: CGPoint(x: 0.88892*width, y: 0), control2: CGPoint(x: 0.99607*width, y: 0.04286*height))
        path.addLine(to: CGPoint(x: 0.84149*width, y: 0.51634*height))
        path.addCurve(to: CGPoint(x: 0.61227*width, y: 0.58904*height), control1: CGPoint(x: 0.82796*width, y: 0.55778*height), control2: CGPoint(x: 0.72941*width, y: 0.58904*height))
        path.addLine(to: CGPoint(x: 0.3694*width, y: 0.58904*height))
        path.addCurve(to: CGPoint(x: 0.14018*width, y: 0.51634*height), control1: CGPoint(x: 0.25226*width, y: 0.58904*height), control2: CGPoint(x: 0.15371*width, y: 0.55778*height))
        path.addLine(to: CGPoint(x: 0.00154*width, y: 0.09169*height))
        path.closeSubpath()
        return path
    }
}

// MARK: - Another View
struct OvercomeLimitView: View {
    @EnvironmentObject var toastManager: ToastManager
    let waitInterval: TimeInterval = 1
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var secondsRemaining: Int = 0
    @State private var isCountingDown: Bool = false
    @State private var countdownTask: Task<Void, Never>?
    
    @State private var selectTimeView: Bool = false
    // Slider-related
    @State private var value: Double = 5
    @State private var range: ClosedRange<Int> = 1...30

    var completion: () -> Void
    
    var title: String {
        secondsRemaining > 0 ? "Lose my streak (\(secondsRemaining)s)" : "Lose my streak"
    }
    
    var body: some View {
        VStack(spacing: 32) {
//            Image(.mascotteCrying)
//                .resizable()
//                .scaledToFit()
//                .frame(square: 200)
            
            VStack(spacing: 14) {
                Text("Unlock and you'll lose your hard worked streak!")
                    .font(.grotesk(.title, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2.0)
                    .foregroundStyle(.textC)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .background(Theme.foregroundC, ignoresSafeAreaEdges: .all)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 24) {
                GlassButton("Go back") {
                    stopCountdown()
                    completion()
                }
                
                Button(title) {
                    // Confirm destructive action here
                    stopCountdown()
                    Haptics.feedback(style: .rigid)
                    selectTimeView = true
                }
                .tint(.red)
                .font(.grotesk(.body, weight: .semibold))
                .disabled(secondsRemaining > 0)
            }
            .padding(.horizontal, 32)
            .padding(.vertical)
        }
        .sheet(isPresented: $selectTimeView) {
            SelectTimeLimitView()
        }
        .onAppear {
            startCountdown()
        }
        .onDisappear {
            stopCountdown()
        }
        .presentationDetents([.height(550)])
    }
    
    private func startCountdown() {
        secondsRemaining = Int(waitInterval)
        isCountingDown = true
        
        countdownTask?.cancel()
        countdownTask = Task { @MainActor in
            while !Task.isCancelled, isCountingDown, secondsRemaining > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled, isCountingDown else { break }
                secondsRemaining -= 1
            }
            if !Task.isCancelled, secondsRemaining == 0 {
                isCountingDown = false
                Haptics.feedback(style: .rigid)
            }
        }
    }
    
    private func stopCountdown() {
        isCountingDown = false
        countdownTask?.cancel()
        countdownTask = nil
    }
    
    @ViewBuilder
    private func SelectTimeLimitView() -> some View {
        VStack(spacing: 32) {
            Text("How much time do you need?")
                .font(.grotesk(.title, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineSpacing(2.0)
                .foregroundStyle(.textC)
            
            Picker("", selection: $value) {
                ForEach(range, id: \.self) { value in
                    Text("\(value) min")
                        .font(.grotesk(size: 20, weight: .medium))
                        .tag(Double(value))
                }
            }
            .pickerStyle(.wheel)
            
            Text("**IMPORTANT**: if you choose to unlock the app, your current streak will be **lost forever**.")
                .font(.grotesk(.footnote, weight: .regular))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .lineSpacing(2.0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding([.horizontal, .top], 32)
        .background(Theme.foregroundC, ignoresSafeAreaEdges: .all)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 24) {
                GlassButton("Go back") {
                    stopCountdown()
                    completion()
                }
                
                Button("Unlock for \(Int(value)) min") {
                    // Confirm destructive action here
                    stopCountdown()
                    Haptics.feedback(style: .rigid)
                    // Open the app
                    completion()
                }
                .tint(.red)
                .font(.grotesk(.body, weight: .semibold))
            }
            .padding(.horizontal, 32)
            .padding(.bottom)
        }
        .presentationDetents([.height(600)])
    }
}

#Preview {
    Text("Hello, World!")
        .sheet(isPresented: .constant(true)) {
            OvercomeLimitView {
                
            }
        }
}
