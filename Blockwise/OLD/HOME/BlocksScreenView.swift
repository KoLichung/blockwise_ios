//
//  BlocksScreenView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 01/12/25.
//

import SwiftUI
import Lottie

enum BlockTab: String, CaseIterable {
    case apps = "Apps"
    case websites = "Websites"
    case schedules = "Schedules"
}

struct BlocksScreenView: View {
    let blocks: FetchedResults<BlockEntity>
    var totalUsageToday: TimeInterval {
        blocks.reduce(0) { usage, block in
            usage + block.records.filtered(by: .now).reduce(0) { $0 + $1.duration }
        }
    }
    
    var isAnyOpen: Bool {
        (blocks.first(where: { $0.isOpen == true }) != nil)
    }
    
    var sortedBlocksByUsage: [BlockEntity] {
        blocks.sorted {
            $0.records.filtered(by: .now).reduce(0) { $0 + $1.duration } > $1.records.filtered(by: .now).reduce(0) { $0 + $1.duration }
        }
    }
    
    @State private var selectedTab: BlockTab = .apps
    @Namespace var nspace
    
    @Binding var showReload: Bool
    @Binding var isReload: Bool
    
    @State private var addBlockView: Bool = false

    @State private var id: Int = 0
    
    @State private var selectedBlock: BlockEntity?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
//                    ScrollView(.horizontal) {
//                        HStack(spacing: 24) {
//                            ForEach(BlockTab.allCases, id: \.self) { tab in
//                                let isSelected = selectedTab.rawValue == tab.rawValue
//                                
//                                Button {
//                                    withAnimation(.smooth(duration: 0.35)) {
//                                        selectedTab = tab
//                                    }
//                                    Haptics.feedback(style: .light)
//                                } label: {
//                                    Text(tab.rawValue)
//                                        .font(.grotesk(.title2, weight: .semibold))
//                                        .foregroundStyle(isSelected ? Color.textC : Color.secondary.opacity(0.5))
//                                        .overlay(alignment: .bottom) {
//                                            if isSelected {
//                                                RoundedRectangle(cornerRadius: 1)
//                                                    .frame(height: 2.5)
//                                                    .offset(y: 4)
//                                                    .matchedGeometryEffect(id: "selected_tab", in: nspace)
//                                                    .foregroundStyle(Color.blueAccent)
//                                            }
//                                        }
//                                        .animation(.smooth(duration: 0.35), value: isSelected)
//                                }
//                            }
//                        }
//                        .padding(.bottom)
//                    }
//                    .padding(.horizontal, -16)
//                    .contentMargins(.horizontal, 16, for: .scrollContent)
//                    .scrollIndicators(.hidden)

                    if sortedBlocksByUsage.isEmpty {
                        NoBlocksView()
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(sortedBlocksByUsage) { block in
                                Button {
                                    Haptics.feedback(style: .light)
                                    selectedBlock = block
                                } label: {
                                    BlockRow(block: block, totalUsageToday: totalUsageToday)
                                }
                                .tint(.primary)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Blocks")
                        .font(.grotesk(size: 20, weight: .semibold))
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if !sortedBlocksByUsage.isEmpty {
                        Button {
                            addBlockView = true
                        } label: {
                            Image(systemName: "plus")
                                .fontWeight(.semibold)
                        }
                        .tint(Color.primary)
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    if !sortedBlocksByUsage.isEmpty {
                        Button {
                            withAnimation(.smooth(duration: 0.35)) {
                                showReload = true
                                Haptics.warningFeedback()
                            }
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .fontWeight(.semibold)
                        }
                        .tint(Color.primary)
                    }
                }

            }
            .sheet(isPresented: $addBlockView) {
                AddOneScreenView()
            }
            .sheet(item: $selectedBlock) { block in
                BlockRowDetails(block: block)
            }
        }
        .id(id)
        .onChange(of: isReload) {
            if isReload {
                id += 1
            }
        }
    }
    
    @ViewBuilder
    private func NoBlocksView() -> some View {
        VStack(spacing: 32) {
            Space(height: 32)
            
            LottieView(animation: .named("hot-beverage"))
                .looping()
                .frame(square: 128)
//                .makeReflection(size: 130)
            
            VStack(spacing: 14) {
                Text("Nothing here yet")
                    .font(.grotesk(size: 30, weight: .semibold))
                    .foregroundStyle(.textC)
                
                Text("Add apps you want to be more intentional with.")
                    .font(.grotesk(size: 17, weight: .regular))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Space(height: 20)
                        
            GlassButton {
                addBlockView = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "plus")
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                    
                    Text("Add a block")
                        .font(.grotesk(.title3, weight: .semibold))
                }
            }
            .padding(.horizontal, 32)
        }
    }
}

// MARK: - Preview
private struct ExploreScreenViewPreview: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BlockEntity.dateCreated, ascending: false)],
        animation: .default
    )
    private var blocks: FetchedResults<BlockEntity>
    
    @State private var showReload: Bool = false

    var body: some View {
        BlocksScreenView(blocks: blocks, showReload: $showReload, isReload: .constant(true))
            .blur(radius: showReload ? 16 : 0)
            .overlay {
                Color.black.opacity(showReload ? 0.6 : 0.0)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showReload = false
                        }
                    }
                
                VStack(alignment: .center, spacing: 48) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundStyle(.white)

                    VStack(alignment: .center, spacing: 14) {
                        Text("Something feels off?")
                            .font(.grotesk(size: 30, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)
                        
                        Text("Your blocks stay in sync with Apple Screen Time. If something seems off, manually reload your blocks to get everything back on track.")
                            .font(.grotesk(size: 18, weight: .regular))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)
                            .lineSpacing(4.0)
                            .padding(.horizontal, 44)
                    }

                    GlassButton {
//                        addBlockView = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 18, weight: .semibold))
                            
                            Text("Reload")
                                .font(.grotesk(.title3, weight: .semibold))
                        }
                    }
                    .padding(.horizontal, 64)
                }
                .opacity(showReload ? 1 : 0)
                .scaleEffect(showReload ? 1 : 1.2)
                .animation(.smooth, value: showReload)
                .offset(y: -32)
                
                Text("Tap anywhere to dismiss")
                    .font(.grotesk(.body, weight: .medium))
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .foregroundStyle(.white.opacity(0.65))
                    .padding(.bottom)
                    .opacity(showReload ? 1 : 0)
            }

    }
}

#Preview {
    ExploreScreenViewPreview()
}
