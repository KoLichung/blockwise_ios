//
//  HomepageView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 10/07/25.
//

import SwiftUI
import ManagedSettings
import Lottie
import SuperwallKit

struct HomepageView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var vm: UserViewModel
    @EnvironmentObject var toastManager: ToastManager
    
    @State private var appearAnimation: Bool = false
    
    let sectionbackgrund: Color = Theme.foregroundC
    
    @State private var showScreenTimeInfo: Bool = false
    @State private var showStreakSheet: Bool = false
    
    @State private var showScreenTime: Bool = false
    
    @State private var showNewBlockView: Bool = false

    @Namespace var nspace
    
    @State private var selectedDate: Date = .now
    
    let blocks: FetchedResults<BlockEntity>
    
    var sortedBlocksByUsage: [BlockEntity] {
        blocks.sorted {
            $0.records.filtered(by: .now).reduce(0) { $0 + $1.duration } > $1.records.filtered(by: .now).reduce(0) { $0 + $1.duration }
        }
    }
    
    var totalUsageToday: TimeInterval {
        blocks.reduce(0) { usage, block in
            usage + block.records.filtered(by: .now).reduce(0) { $0 + $1.duration }
        }
    }
    
    @State private var selectedBlock: BlockEntity?
    
    @StateObject private var superwall = Superwall.shared
        
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    
                    GoalSection()
                    
                    VStack(spacing: 14) {
                        HStack(spacing: 14) {
                            Text("Blocks")
                                .font(.grotesk(size: 24, weight: .semibold))
                            
                            Spacer()
                            
                            Button {
                                showNewBlockView = true
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .medium))
                            }
                        }
                        
                        BlocksSection()
                    }
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            .navigationTitle("Today")
            .sheet(item: $selectedBlock) { block in
                BlockRowDetails(block: block)
            }
            .sheet(isPresented: $showNewBlockView) {
                CreateBlockOneView()
            }
            .sheet(isPresented: $showScreenTimeInfo) {
                ScreenTimeInfo()
                    .presentationDetents([.height(570)])
            }
            .sheet(isPresented: $showScreenTime) {
                ScreenTimeHistoryView()
            }
            .sheet(isPresented: $showStreakSheet) {
                StreaksView()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showStreakSheet = true
                        Haptics.feedback(style: .soft)
                    } label: {
                        HStack(spacing: 4) {
                            Text("\(vm.currentStreak) day streak")
                                .font(.grotesk(.footnote, weight: .medium))
                        }
                    }
                }
            }
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        }
        .onAppear(perform: setup)
    }
    
    private func setup() {
        vm.usage = totalUsageToday
        
        SleepTask.sleep(seconds: 0.15) {
            withAnimation(.smooth(duration: 0.35, extraBounce: 0.15)) {
                appearAnimation = true
            }
        }
    }
    
    @ViewBuilder
    private func ScreenTimeInfo() -> some View {
        let secondaryBlue: Color = Color(hex: 0x2A2D55)

        VStack(alignment: .center, spacing: 32) {
            LottieView(animation: .named("owl"))
                .looping()
                .frame(square: 100)
            
            VStack(alignment: .leading, spacing: 32) {
                Text("How is your Screen Time calculated?")
                    .font(.grotesk(.title, weight: .semibold))
                
                Text("We add up the minutes you use in blocked apps. Anything you haven’t blocked won’t count toward your screen time.")
                    .font(.grotesk(.body, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(4.0)
                
                Text("If you want to change your goal, go to Settings > Screen Time > Change you goal")
                    .font(.grotesk(.subheadline, weight: .regular))
                    .foregroundColor(.white.opacity(0.5))
                    .lineSpacing(4.0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            Button {
                showScreenTimeInfo = false
            } label: {
                Capsule(style: .continuous)
                    .frame(height: 55)
                    .foregroundStyle(Color.primaryBlue)
                    .overlay {
                        Text("Go back")
                            .font(.grotesk(.title3, weight: .medium))
                            .foregroundStyle(.white)
                    }
            }
        }
        .padding([.bottom, .horizontal], 32)
        .padding(.top)
        .background(secondaryBlue, ignoresSafeAreaEdges: .all)
    }
        
    @ViewBuilder
    private func GoalSection() -> some View {
        let screenTimeGoal: TimeInterval = vm.user?.screenTimeGoal ?? 1
        let usage: TimeInterval = totalUsageToday
        let timeLeft: TimeInterval = max(screenTimeGoal - usage, 0)
        
        Button {
            showScreenTime = true
            Haptics.feedback(style: .soft)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text("Screen Time")
                        .font(.grotesk(.body, weight: .medium))
                }
                
                Text("\(TimeFormatter.display(usage, style: .short))")
                    .font(.grotesk(size: 38, weight: .semibold))
                    .contentTransition(.numericText())
                    .animation(.smooth(duration: 0.35), value: usage)
                
                GeometryReader { geo in
                    let width: CGFloat = geo.size.width
                    let progress: CGFloat = usage / max(1, screenTimeGoal)
                    let clampedProgress = min(max(progress, 0), 1) // Clamp between 0 and 1
                    let progressWidth: CGFloat = width * clampedProgress
                    let triangleWidth: CGFloat = 11
                    let triangleHeight: CGFloat = 9
                    let feedback = progressFeedback(for: clampedProgress)
                    let color = progressColor(for: clampedProgress)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        ZStack(alignment: .leading) {
                            
                            Rectangle()
                                .foregroundStyle(.secondary.opacity(0.15))
                            
                            Rectangle()
                                .frame(width: appearAnimation ? progressWidth : 0)
                                .foregroundStyle(color)
                        }
                        .frame(height: 35)
                        .mask {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                        }
                        
//                        Triangle()
//                            .frame(width: triangleWidth, height: triangleHeight)
//                            .offset(x: appearAnimation ? progressWidth - (triangleWidth / 2) : 0) // center the triangle
//                            .foregroundStyle(.secondary)
//                            .opacity(clampedProgress > 0 && clampedProgress < 1 ? 1 : 0)
                        
                        HStack(spacing: 8) {
                            Text(feedback)
                                .foregroundStyle(color)
                                .font(.grotesk(.footnote, weight: .medium))
                            
                            Divider()
                                .frame(height: 16)
                            
                            Text("You have \(TimeFormatter.display(timeLeft, style: .short)) left.")
                                .font(.grotesk(.footnote, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(height: 82)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .foregroundStyle(sectionbackgrund)
            }
            .overlay(alignment: .topTrailing) {
                Button {
                    showScreenTimeInfo = true
                    Haptics.feedback(style: .medium)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .font(.subheadline)
                    }
                    .foregroundStyle(.secondary)
                }
                .padding()
            }
            //                .glassEffect()
        }
        //            .buttonStyle(.glass)
        //            .buttonBorderShape(.roundedRectangle(radius: 18))
    }
    
    func progressFeedback(for progress: CGFloat) -> String {
        switch progress {
        case 0..<0.25: return "Great!"
        case 0.25..<0.85: return "Good"
        case 0.85..<1.0: return "Approaching limit"
        case 1.0: return "Limit reached"
        default: return "Unknown status"
        }
    }
    
    func progressColor(for progress: CGFloat) -> Color {
        switch progress {
        case 0..<0.85: return Color.primaryBlue
        case 0.85..<1.0: return .yellow
        case 1.0: return .red
        default: return .gray
        }
    }
    
    @ViewBuilder
    private func BlocksSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(sortedBlocksByUsage) { block in
                Button {
                    Haptics.feedback(style: .light)
                    selectedBlock = block
                } label: {
                    BlockRow(block: block, totalUsageToday: totalUsageToday)
                }
            }
        }
    }
    
    @ViewBuilder
    private func ScheduleSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(sortedBlocksByUsage) { block in
                Button {
                    Haptics.feedback(style: .light)
                    selectedBlock = block
                } label: {
                    BlockRow(block: block, totalUsageToday: totalUsageToday)
                }
            }
        }
    }
            
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // Ensures consistent formatting
        formatter.dateFormat = "E, MMM d" // "Mon, Jul 14"
        return formatter.string(from: date)
    }
}

#Preview("TabView") {
    TabBarView()
        .environmentObject(LocalNotificationManager())
        .environmentObject(UserViewModel())
        .environmentObject(ToastManager())
        .environmentObject(PurchaseManager.shared)
}
