//
//  OB11_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 26/01/26.
//

import SwiftUI
import AlarmKit

enum OB11_V2Step: Int, CaseIterable {
    case one, two, three
    
    var offsetY: CGFloat {
        switch self {
        case .one: return -48
        case .two: return -235
        case .three: return 0
        }
    }
    
    var label: String {
        switch self {
        case .one: return "Apps you will select will be shown faded in the home screen"
        case .two: return "You will have full control on the time you spend on them."
        case .three: return "A Live Activity timer will guide you through your session."
        }
    }
}

// MARK: - Main View
struct OB11_V2: View {
    // MARK: - Environment
    @EnvironmentObject var lnManager: LocalNotificationManager
    @EnvironmentObject var vm: OBVM_V2
    
    // MARK: - State
    @State private var phase: OB11_V2Step = .one
    @State private var appearAnimation: Bool = false
    @State private var fadeApps: Bool = false
    @State private var moveOne: Bool = false
    @State private var moveTwo: Bool = false
    @State private var isLoading: Bool = false
    @State private var showChevronHint: Bool = false
    @State private var isAuth: Bool = false
    
    // MARK: - Timer State
    @State private var remainingTime: Int = 299
    @State private var timer: Timer? = nil
    
    // MARK: - Constants
    private let screenHeight: CGFloat = UIScreen.main.bounds.height
    private let screenWidth: CGFloat = UIScreen.main.bounds.width
    private let bgColor: Color = Theme.backgroundC
    private let columns = 4
    private let items = Array(0..<12)
    
    // MARK: - Body
    var body: some View {
        VStack {
            phonePreview
        }
        .scaleEffect(phoneScale)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .rotation3DEffect(.degrees(phoneRotation), axis: (1, 0, 0))
        .overlay {
            gradientOverlays
        }
        .overlay(alignment: .bottom) {
            bottomContent
        }
        .overlay {
            loadingOverlay
        }
        .onAppear(perform: setup)
    }
    
    // MARK: - Phone Preview
    @ViewBuilder
    private var phonePreview: some View {
        Image(.iphoneShape)
            .resizable()
            .scaledToFit()
            .brightness(0.8)
            .offset(y: appearAnimation ? 0 : -32)
            .overlay(alignment: .top) {
                appGrid
            }
            .overlay(alignment: .top) {
                liveActivityPreview
            }
            .overlay(alignment: .top) {
                dynamicIslandPreview
            }
            .overlay(alignment: .bottom) {
                durationPicker
            }
            .padding(32)
            .offset(y: phase.offsetY)
            .scaleEffect(appearAnimation ? 1 : 2)
            .opacity(appearAnimation ? 1 : 0)
            .animation(.smooth(duration: 0.45).delay(0.15), value: appearAnimation)
    }
    
    // MARK: - App Grid
    @ViewBuilder
    private var appGrid: some View {
        VStack(spacing: 12) {
            ForEach(items.chunked(into: columns), id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { index in
                        appIcon(at: index)
                    }
                }
            }
        }
        .opacity(phase.rawValue > 1 ? 0 : 1)
        .blur(radius: phase.rawValue > 1 ? 16 : 0)
        .padding(32)
        .offset(y: 72)
        .scaleEffect(phase.rawValue > 1 ? 0.5 : 1.0)
    }
    
    @ViewBuilder
    private func appIcon(at index: Int) -> some View {
        if index == 10 || index == 11 {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .aspectRatio(1.0, contentMode: .fit)
                .foregroundStyle(.clear)
        } else {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .aspectRatio(1.0, contentMode: .fit)
                .foregroundStyle(Color.secondary)
                .opacity(0.25)
                .overlay {
                    appIconContent(at: index)
                }
                .opacity(appearAnimation ? 1 : 0)
                .scaleEffect(appearAnimation ? 1 : 1.5)
                .animation(.smooth(duration: 0.35, extraBounce: 0.15), value: appearAnimation)
        }
    }
    
    @ViewBuilder
    private func appIconContent(at index: Int) -> some View {
        switch index {
        case 2:
            ZStack {
                Image("instagram-icon")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .opacity(fadeApps ? 0.5 : 0.0)
                    .foregroundStyle(.black)
            }
        case 5:
            ZStack {
                Image("tiktok-icon")
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .opacity(fadeApps ? 0.5 : 0.0)
                    .foregroundStyle(.black)
            }
        case 7:
            Image(.blockrIcon)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        default:
            EmptyView()
        }
    }
    
    // MARK: - Live Activity Preview
    @ViewBuilder
    private var liveActivityPreview: some View {
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
                    .foregroundStyle(Color.tertiaryBlue)
                    .opacity(0.25)
            }
        }
        .padding(24)
        .offset(y: 100)
        .opacity(phase == .three ? 1 : 0)
        .offset(y: phase == .three ? 0 : 350)
    }
    
    // MARK: - Dynamic Island Preview
    @ViewBuilder
    private var dynamicIslandPreview: some View {
        Capsule(style: .continuous)
            .frame(height: phase == .three ? 72 : 32)
            .frame(maxWidth: phase == .three ? .infinity : 100)
            .foregroundStyle(phase == .three ? .black : .gray)
            .overlay {
                HStack {
                    Image(.blockrIconTransparent)
                        .resizable()
                        .scaledToFit()
                        .frame(square: 32)
                    
                    Spacer()
                    
                    Text(Date.now.addingTimeInterval(60), style: .timer)
                        .font(.grotesk(size: 40, weight: .regular))
                        .contentTransition(.numericText())
                        .animation(.smooth, value: remainingTime)
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 20)
                .opacity(phase == .three ? 1 : 0)
                .blur(radius: phase == .three ? 0 : 16)
                .scaleEffect(phase == .three ? 1 : 0.2)
            }
            .padding(24)
    }
    
    // MARK: - Duration Picker
    @ViewBuilder
    private var durationPicker: some View {
        UnevenRoundedRectangle(
            topLeadingRadius: 24,
            bottomLeadingRadius: 42,
            bottomTrailingRadius: 42,
            topTrailingRadius: 24,
            style: .continuous
        )
        .frame(height: phase == .two ? 250 : 0)
        .foregroundStyle(Color.gray.opacity(0.15))
        .overlay {
            VStack(spacing: 16) {
                Picker("", selection: .constant(5)) {
                    ForEach(1..<90) { min in
                        Text("\(min) min")
                            .tag(min)
                            .foregroundStyle(.textC)
                            .font(.grotesk(size: 20, weight: .semibold))
                    }
                }
                .padding(.horizontal)
                .pickerStyle(.wheel)
            }
            .padding(.top)
            .opacity(phase == .two ? 1 : 0)
        }
        .padding()
    }
        
    // MARK: - Gradient Overlays
    @ViewBuilder
    private var gradientOverlays: some View {
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
    
    // MARK: - Bottom Content
    @ViewBuilder
    private var bottomContent: some View {
        VStack(spacing: 32) {
            phaseLabel
            phaseIndicator
            continueButton
        }
        .padding()
        .padding(.horizontal, 32)
    }
    
    @ViewBuilder
    private var phaseLabel: some View {
        if phase == .one {
            Text(OB11_V2Step.one.label)
                .font(.grotesk(size: 26, weight: .semibold))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .lineSpacing(2.0)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 50)
                .animation(.smooth(duration: 0.5, extraBounce: 0.15).delay(0.35), value: appearAnimation)
                .transition(.move(edge: .leading).combined(with: .offset(x: -100)))
        } else if phase == .two {
            Text(OB11_V2Step.two.label)
                .font(.grotesk(size: 26, weight: .semibold))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .lineSpacing(2.0)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .offset(x: 100)),
                        removal: .move(edge: .leading).combined(with: .offset(x: -100))
                    )
                )
        } else if phase == .three {
            Text(OB11_V2Step.three.label)
                .font(.grotesk(size: 26, weight: .semibold))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .lineSpacing(2.0)
                .transition(.move(edge: .trailing).combined(with: .offset(x: 100)))
        }
    }
    
    @ViewBuilder
    private var phaseIndicator: some View {
        HStack(spacing: 10) {
            ForEach(OB11_V2Step.allCases, id: \.self) { p in
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
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 50)
        .animation(.smooth(duration: 0.5, extraBounce: 0.15).delay(0.35), value: appearAnimation)
    }
    
    @ViewBuilder
    private var continueButton: some View {
        GlassButton("Continue") {
            action()
        }
        .opacity(appearAnimation ? 1 : 0)
        .offset(y: appearAnimation ? 0 : 100)
        .animation(.smooth(duration: 0.5, extraBounce: 0.15).delay(0.8), value: appearAnimation)
    }
    
    // MARK: - Loading Overlay
    @ViewBuilder
    private var loadingOverlay: some View {
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
                chevronHint
            }
        }
        .opacity(isLoading ? 1 : 0)
    }
    
    @ViewBuilder
    private var chevronHint: some View {
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
            .offset(x: 75, y: 200)
    }
    
    // MARK: - Computed Properties
    private var phoneScale: CGFloat {
        if fadeApps {
            switch phase {
            case .three: return 1.02
            case .two: return 1.02
            default: return 0.95
            }
        }
        return 0.9
    }
    
    private var phoneRotation: Double {
        switch phase {
        case .three, .two: return 5
        default: return 0
        }
    }
    
    private var formattedRemainingTime: String {
        let minutes = remainingTime / 60
        let seconds = remainingTime % 60
        return String(format: "%d:%02d", minutes, seconds)
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
    
    // MARK: - Functions
    private func setup() {
        SleepTask.sleep(seconds: 0.15) {
            appearAnimation = true
        }
        
        SleepTask.sleep(seconds: 1.0) {
            withAnimation {
                fadeApps = true
            }
        }
    }
    
    private func action() {
        withAnimation(.smooth(duration: 0.5, extraBounce: 0.15)) {
            switch phase {
            case .one:
                phase = .two
            case .two:
                phase = .three
                startTimer()
            case .three:
//                handlePhaseThreeAction()
                vm.nextPage()
            }
        }
    }
    
    private func handlePhaseThreeAction() {
        if #available(iOS 26.0, *) {
            isLoading = true
            
            SleepTask.sleep(seconds: 0.25) {
                showChevronHint = true
            }
            
            Task {
                do {
                    try await checkAlarmKitAuth {
                        // Completion
                    }
                } catch {
                    Logger.error(error.localizedDescription)
                    DispatchQueue.main.async {
                        isLoading = false
                        showChevronHint = false
                    }
                }
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
}

// MARK: - Notification View Component
extension OBQuizTutorial {
    @ViewBuilder
    private func NotificationView(
        title: String,
        description: String,
        time: String,
        timeSensitive: Bool = false
    ) -> some View {
        RoundedRectangle(cornerRadius: 22)
            .fill(Color.tertiaryBlue)
            .shadow(color: .black.opacity(0.1), radius: 2, y: 4)
            .shadow(color: .black.opacity(0.1), radius: 2, y: -0.5)
            .frame(height: 60)
            .overlay {
                HStack(spacing: 12) {
                    Image(AppConfiguration.appIcon)
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
}

#Preview {
    OB11_V2()
        .environmentObject(OBVM_V2())
}
