//
//  NewUnblockView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 09/09/25.
//

import SwiftUI
import ManagedSettings
import Lottie
import CoreData
import AlarmKit

struct NewUnblockView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var toastManager: ToastManager
    @EnvironmentObject var vm: UserViewModel
    @EnvironmentObject var lnManager: LocalNotificationManager
            
    @State private var appToken: ApplicationToken?
    @State private var blockEntity: BlockEntity?
    
    // Slider-related
    @State private var value: Int = 5
    @State private var tempValue: Int = 5
    @State private var dragOffset: CGFloat = 0
    
    @State private var elasticFactor: CGFloat = 0.65
    
    @State private var range: ClosedRange<Int> = 1...15
    @State private var stepWidth: CGFloat = 20
    
    @State private var now = Date.now
    @State private var nowPlus30 = Date.now

    @Namespace var nspace
    
    @State private var isDragging: Bool = false
    
    @State private var showScreenTimeWarning: Bool = false
    
    @State private var openAnywayWarning: Bool = false
    
    @State private var canOpenAnyway: Bool = false
    
    @State private var isAlarmAllowed: Bool = false

    let height: CGFloat = UIScreen.main.bounds.height
    
    var body: some View {
        VStack(spacing: 32) {
            SelectTimeView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 32)
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 32) {
                GlassButton("Open for \(value) min") {
                    action()
                }
                .contentTransition(.numericText())
                .foregroundStyle(Color.accentBlue)
                
                Button("Close") {
                    Haptics.feedback(style: .rigid)
                    dismiss()
                    UserDefaultsManager.shared.setToken(token: nil, value: false)
                }
                .tint(.white)
                .font(.grotesk())
            }
            .padding(.horizontal, 32)
            .padding(.vertical)
        }
        .onAppear(perform: setup)
        .sheet(isPresented: $showScreenTimeWarning) {
            ScreenTimeWarning()
                .presentationDetents([.height(600)])
        }
        .onChange(of: scenePhase) {
            if scenePhase == .background {
                UserDefaultsManager.shared.setToken(token: nil, value: false)
            }
        }
    }
    
    @ViewBuilder
    private func CooldownView(_ blockEntity: BlockEntity, _ nextDate: Date) -> some View {
        VStack(spacing: 32) {
            VStack(spacing: 24) {
                
                if let appToken {
                    Label(appToken)
                        .labelStyle(.iconOnly)
                        .scaleEffect(2.75)
                } else {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .frame(square: 56)
                        .foregroundStyle(.secondary.opacity(0.15))
                }
                
                Text("Take a break")
                    .font(.grotesk(.title, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .padding(32)
                    .lineSpacing(2.0)
            }
            
            Text(nextDate, style: .timer)
                .font(.grotesk(size: 56, weight: .medium))
        }

    }
    
    @ViewBuilder
    private func SelectTimeView() -> some View {
        VStack(spacing: 32) {
            VStack(spacing: 14) {
                
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
                    .padding(32)
                    .lineSpacing(2.0)
            }
            
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Text("\(tempValue)")
                        .font(.grotesk(size: 64, weight: .semibold))
                        .contentTransition(.numericText())
                        .sensoryFeedback(.selection, trigger: tempValue)
                        .scaleEffect(tempValue != value ? 1.25 : 1.0)
                        .foregroundStyle(tempValue != value ? Color.primaryBlue : .white)
                        .brightness(0.9)
                        .overlay(alignment: .trailing) {
                            if value >= range.upperBound {
                                Button {
                                    guard value < 120 else { return }
                                    withAnimation {
                                        value += 1
                                        tempValue += 1
                                    }
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 38, weight: .medium))
                                        .symbolRenderingMode(.hierarchical)
                                }
                                .buttonRepeatBehavior(.enabled)
                                .tint(Color.white.opacity(value == 120 ? 0.25 : 1.0))
                                .buttonStyle(.borderless)
                                .offset(x: 90)
                            }
                        }
                        .overlay(alignment: .leading) {
                            if value >= range.upperBound {
                                Button {
                                    guard value > range.upperBound else { return }
                                    withAnimation {
                                        value -= 1
                                        tempValue -= 1
                                    }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 38, weight: .medium))
                                        .symbolRenderingMode(.hierarchical)
                                }
                                .buttonRepeatBehavior(.enabled)
                                .tint(Color.white.opacity(value == range.upperBound ? 0.25 : 1.0))
                                .buttonStyle(.borderless)
                                .offset(x: -90)
                            }
                        }

                    
                    Text("min")
                        .font(.grotesk(size: 20, weight: .medium))
                        .foregroundStyle(.white.opacity(0.65))
                }
                
                GeometryReader { geo in
                    let center = geo.size.width / 2
                    
                    ForEach(range, id: \.self) { tick in
                        
                        let width = stepWidth
                        
                        let x = center + CGFloat(tick - min(range.upperBound, value)) * width + dragOffset
//                        let distance = abs(x - center) * 0.1
                        
                        VStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(tick == tempValue ? Color.white : Color.white.opacity(0.35))
                                .frame(
                                    width: tick == tempValue ? 6.0 : tick % 5 == 0 ? 3.0 : 2.0,
                                    height: max(1, (tick % 5 == 0 ? 14 : 10))
                                )
                                .offset(y: (tick == tempValue) && isDragging ? -2 : 0)
                                .offset(y: tick % 5 == 0 ? -1.5 : 0)
                                .scaleEffect(y: tick == tempValue ? 2.5 : 1.0, anchor: .bottom)
                                .opacity(tick % 5 == 0 ? 1 : 0.8)
                        }
                        .position(x: x, y: geo.size.height / 2)
//                        .scaleEffect(isDragging ? 0.98 : 1.0)
                        .opacity(isDragging && tick != tempValue ? 0.85 : 1.0)
                        
                    }
                    .contentShape(Rectangle())
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            guard value <= range.upperBound else { return }
                            
                            withAnimation(.snappy(duration: 0.3, extraBounce: 0.1)) {
                                isDragging = true
                            }
                            
                            withAnimation(.interactiveSpring) {
                                
                                let rawOffset = gesture.translation.width * elasticFactor
                                let adjustedOffset = rawOffset
                                
                                let offsetSteps = adjustedOffset / stepWidth
                                var projected = CGFloat(value) - offsetSteps
                                
                                let lower = CGFloat(range.lowerBound)
                                let upper = CGFloat(range.upperBound)
                                
                                if projected < lower {
                                    let overshoot = lower - projected
                                    projected = lower - log(overshoot + 1) * 0.5
                                } else if projected > upper {
                                    let overshoot = projected - upper
                                    projected = upper + log(overshoot + 1) * 0.5
                                }
                                
                                dragOffset = (CGFloat(value) - projected) * stepWidth
                                let rounded = Int(projected.rounded())
                                tempValue = rounded.clamped(to: range)
                            }
                        }
                        .onEnded { gesture in
                            withAnimation(.snappy(duration: 0.3, extraBounce: 0.1)) {
                                isDragging = false
                            }

                            let velocity = gesture.velocity.width
                            
                            let rawOffset = gesture.translation.width * elasticFactor
                            let adjustedOffset = rawOffset
                            
                            let offsetSteps = adjustedOffset / stepWidth
                            let finalValue = Int((CGFloat(value) - offsetSteps).rounded()).clamped(to: range)
                            
                            withAnimation(.interpolatingSpring(stiffness: 120, damping: 20)) {
                                if abs(velocity) > 1250 {
                                    value = roundToNearestFive(finalValue)
                                    tempValue = roundToNearestFive(finalValue)
                                } else {
                                    value = finalValue
                                    tempValue = finalValue
                                }
                                dragOffset = 0
                            }
                        }
                )
                .frame(height: 128)
                
                if height > 800 { // only for bigger screens
                    HStack(spacing: 10) {
                        Text(Date.now, style: .time)
                        Image(systemName: "arrow.right")
                        Text(Date.now.addingTimeInterval(TimeInterval(tempValue * 60)), style: .time)
                            .contentTransition(.numericText())
                            .scaleEffect(value != tempValue ? 1.15 : 1.0)
                            .brightness(value != tempValue ? 0.5 : 0.0)
                    }
                    .font(.grotesk(.subheadline, weight: .medium))
                    .foregroundStyle(.white.opacity(0.45))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background {
                        Capsule(style: .continuous)
                            .opacity(0.05)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func ScreenTimeWarning() -> some View {
        let interval = TimeInterval(value * 60)

        VStack(alignment: .center, spacing: 32) {
            LottieView(animation: .named("raised-hand"))
                .looping()
                .frame(square: 100)
            
            Text("You've reached your screen time limit.")
                .font(.grotesk(.title, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineSpacing(2.0)

            Space(height: 6)
            
            HStack(spacing: 32) {
                VStack(alignment: .center, spacing: 10) {
                    Text("Before")
                        .font(.grotesk(.subheadline, weight: .medium))
                    
                    Text(TimeFormatter.display(vm.usage, style: .short))
                        .font(.grotesk(.title, weight: .semibold))
                }
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 20, weight: .medium))
                    .padding(.horizontal)

                VStack(alignment: .center, spacing: 10) {
                    Text("After")
                        .font(.grotesk(.subheadline, weight: .medium))
                    
                    Text(TimeFormatter.display(vm.usage.advanced(by: interval), style: .short))
                        .foregroundStyle(.orange)
                        .font(.grotesk(.title, weight: .semibold))
                }
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
        .padding(.top)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 32) {
                GlassButton("Go back") {
                    dismiss()
                }
                .contentTransition(.numericText())
                .foregroundStyle(Color.accentBlue)
                
                HStack(spacing: 10) {
                    Button("Open anyway") {
                        openAnyway()
                    }
                    .disabled(!canOpenAnyway)
                    .tint(.white)
                    .font(.grotesk())
                    
                    if !canOpenAnyway {
                        Text("\(Text(timerInterval: now...nowPlus30, countsDown: true))s")
                            .font(.grotesk())
                            .italic()
                    }
                }
                .animation(.smooth, value: canOpenAnyway)
            }
            .padding(.horizontal, 32)
            .padding(.vertical)
        }
        .background(Color.tertiaryBlue, ignoresSafeAreaEdges: .all)
        .onAppear {
            nowPlus30 = .now.addingTimeInterval(30)
            SleepTask.sleep(seconds: 30) {
                canOpenAnyway = true
            }
        }
    }
    
    func inverseNormalizedDistance(value: Int, maxDistance: Int) -> CGFloat {
        let normalized = 1 - (CGFloat(value) / CGFloat(maxDistance))
        return pow(normalized.clamped(to: 0.25...1), 2) // quadratic ease-out
    }
    
    func roundToNearestFive(_ value: Int) -> Int {
        return max(1, Int((Double(value) / 5.0).rounded() * 5))
    }
    
    private func action() {
        guard let blockEntity else {
            Logger.error("Either could not retrieve block or appToken")
            toastManager.error("Something went wrong.")
            return
        }
        
        let interval = TimeInterval(value * 60)
        Logger.debug("Interval: \(interval)")
        
        // Make sure the user does not goes over the screen time goal
        let screenTimeGoal: TimeInterval = vm.user?.screenTimeGoal ?? 0
        
        Logger.debug("usage.advanced(by: interval): \(vm.usage.advanced(by: interval).formattedDuration())")
        Logger.debug("screenTimeGoal: \(screenTimeGoal.formattedDuration())")
        
        guard vm.usage.advanced(by: interval) <= screenTimeGoal else {
            showScreenTimeWarning = true
            Logger.debug("Ah-ah")
            return
        }
        
        Task {
            do {
                guard let raw = blockEntity.appTokenString,
                      let token = ApplicationToken.fromRawValue(raw) else {
                    Logger.error("Invalid ApplicationToken string")
                    toastManager.error("Something went wrong: error 389")
                    return
                }

                try await DeviceActivityManager.shared.open(
                    blockId: blockEntity.identifier ?? "",
                    appToken: token,
                    for: interval
                )
            } catch {
                Logger.error(error.localizedDescription)
                toastManager.error(error.localizedDescription)
            }
        }
        
        do {
            // Create Record
            try CoreDataStack.shared.createRecord(
                for: blockEntity,
                duration: interval
            )
            
            // Set open status
            blockEntity.isOpen = true
            blockEntity.openStartTime = Date.now
            blockEntity.openEndTime = Date.now.addingTimeInterval(interval)
            
            // Update NextAvailableDate for Cooldown if ANY
//            if blockEntity.cooldown > 0 {
//                blockEntity.nextAvailableDate = Date.now.addingTimeInterval(interval + blockEntity.cooldown)
//            }
                                                
            // Save to Core Data
            try CoreDataStack.shared.saveContext()
            
            // Start Live Activity Timer
            startLiveActivityOrAlarm()
            
            // Dismiss view
            dismiss()
            UserDefaultsManager.shared.setToken(token: nil, value: false)
            
            // Inform user
            toastManager.info("App opened for \(value) minutes.")
            Logger.success("Success!")
            
        } catch {
            Logger.error(error.localizedDescription)
            toastManager.error(error.localizedDescription)
        }

        // For TESTING
//        if reviewPrompt == false {
//            let delay = interval + 5*60 // 5 minutes after the interval
//            
//            var notification = LocalNotification(
//                identifier: UUID().uuidString,
//                title: "💙 \(vm.user?.name ?? ""), do you like BLOCKR?",
//                body: "Tap to leave a quick review",
//                timeInterval: delay,
//                repeats: false
//            )
//            
//            notification.userInfo = ["link_key" : LinkView.review.rawValue]
//            
//            Task {
//                await lnManager.schedule(localNotification: notification)
//            }
//            
//            reviewPrompt = true
//        }
    }
    
    private func startLiveActivityOrAlarm() {
        if #available(iOS 26.0, *), isAlarmAllowed {
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
        } else {
            // Live Activity
            guard let blockEntity else { return }
            let interval = TimeInterval(value * 60)
            let timerManager = LiveActivityManager<TimerAttributes>()
            let attributes = TimerAttributes()
            let contentState = TimerAttributes.ContentState(
                startDate: .now,
                endDate: .now.addingTimeInterval(interval),
                entityId: blockEntity.identifier ?? ""
            )
            
            Task {
                try await timerManager.start(attributes: attributes, state: contentState)
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

    
    private func openAnyway() {
        guard let blockEntity else {
            Logger.error("Either could not retrieve block or appToken")
            toastManager.error("Something went wrong.")
            return
        }

        let interval = TimeInterval(value * 60)
        Logger.debug("Interval: \(interval)")

        Task {
            do {
                guard let raw = blockEntity.appTokenString,
                      let token = ApplicationToken.fromRawValue(raw) else {
                    Logger.error("Invalid ApplicationToken string")
                    return
                }

                try await DeviceActivityManager.shared.open(
                    blockId: blockEntity.identifier ?? "",
                    appToken: token,
                    for: interval
                )
//                try await DeviceActivityManager.shared.open(
//                    block: blockEntity,
//                    appToken: appToken,
//                    for: interval
//                )
            } catch {
                Logger.error(error.localizedDescription)
                toastManager.error(error.localizedDescription)
            }
        }

        do {
            // Create Record
            try CoreDataStack.shared.createRecord(
                for: blockEntity,
                duration: interval
            )
            
            // Set open status
            blockEntity.isOpen = true
            blockEntity.openStartTime = Date.now
            blockEntity.openEndTime = Date.now.addingTimeInterval(interval)
            
            // Update NextAvailableDate for Cooldown if ANY
//            if blockEntity.cooldown > 0 {
//                blockEntity.nextAvailableDate = Date.now.addingTimeInterval(interval + blockEntity.cooldown)
//            }
                                                
            // Save to Core Data
            try CoreDataStack.shared.saveContext()
            
            // Reset streaks
            vm.breakStreak()
            
            // Start Live Activity Timer
            startLiveActivityOrAlarm()
            
            // Dismiss view
            dismiss()
            UserDefaultsManager.shared.setToken(token: nil, value: false)
            
            // Inform user
            toastManager.info("App opened for \(value) minutes.")
            Logger.success("Success!")
            
        } catch {
            Logger.error(error.localizedDescription)
            toastManager.error(error.localizedDescription)
        }

    }
    
    private func setup() {
        // Find the Block from the Notification ID
        retrieveBlockFromNotificationID()
        
        if #available(iOS 26, *) {
            Task {
                do {
                    try await checkAlarmKitAuth()
                } catch {
                    Logger.error(error.localizedDescription)
                }
            }
        }
        
    }
    
    @available(iOS 26.0, *)
    private func checkAlarmKitAuth() async throws {
        switch AlarmManager.shared.authorizationState {
        case .notDetermined:
            let status = try await AlarmManager.shared.requestAuthorization()
            isAlarmAllowed = status == .authorized
        case .denied:
            isAlarmAllowed = false
        case .authorized:
            isAlarmAllowed = true
        @unknown default:
            fatalError()
        }
    }
    
    private func retrieveBlockFromNotificationID() {
        // Step 1: Get the stored token from UserDefaults
        guard let storedToken = UserDefaultsManager.shared.loadAppToken() else {
            toastManager.error("No AppToken found for key")
            Logger.error("⚠️ No ApplicationToken found for key")
            return
        }
        
        // Step 2: Fetch the matching BlockEntity directly
        let request = NSFetchRequest<BlockEntity>(entityName: "BlockEntity")
        request.predicate = NSPredicate(format: "appTokenString == %@", storedToken.string ?? "")
        request.fetchLimit = 1
        
        do {
            // Step 2.5: Calculate total usage across all blocks
//            let allBlocks = CoreDataStack.shared.fetchEntities(for: BlockEntity.self)
//            usage = allBlocks.flatMap { $0.records }
//                .filtered(by: .now)
//                .reduce(.zero) { $0 + $1.duration }
//            Logger.debug("⏰ Total Usage for Today: \(usage.formattedDuration())")

            // Step 3: Assign the matched BlockEntity
            if let entity = try CoreDataStack.shared.persistentContainer.viewContext.fetch(request).first {
                appToken = storedToken
                blockEntity = entity
                Logger.success("AppToken found")
            } else {
                Logger.error("⚠️ No matching BlockEntity found for token: \(storedToken)")
                toastManager.error("No matching BlockEntity found for token")
            }
        } catch {
            Logger.error("❌ Core Data fetch failed: \(error)")
            toastManager.error("Failed to fetch BlockEntity")
        }
    }

    
//    private func retrieveBlockFromNotificationID() {
//        // Step 1: Get the stored token from UserDefaults
//        guard let storedToken = UserDefaultsManager.shared.get(
//            forKey: id,
//            as: ApplicationToken.self
//        ) else {
//            toastManager.error("No AppToken found for key")
//            Logger.error("⚠️ No ApplicationToken found for key: \(id)")
//            return
//        }
//
//        // Step 2: Fetch all BlockEntity items
//        let allBlocks = CoreDataStack.shared.fetchEntities(for: BlockEntity.self)
//
//        // Step 2.5: Calcualte total usage for today
//        usage = allBlocks.flatMap { $0.records }
//            .filtered(by: .now)
//            .reduce(.zero) { $0 + $1.duration }
//        Logger.debug("⏰ Total Usage for Today: \(usage.formattedDuration())")
//
//        // Step 3: Find the matching BlockEntity
//        for entity in allBlocks {
//            guard let rawToken = entity.appTokenString,
//                  let entityToken = ApplicationToken.fromRawValue(rawToken),
//                  entityToken == storedToken else {
//                continue
//            }
//
//            appToken = entityToken
//            blockEntity = entity
//            Logger.success("AppToken found")
//            return
//        }
//
//        // No match found
//        Logger.error("⚠️ No matching BlockEntity found for token: \(storedToken)")
//        toastManager.error("No matching BlockEntity found for token")
//    }
}

#Preview {
    UnblockView(id: "")
        .environmentObject(ToastManager())
}
