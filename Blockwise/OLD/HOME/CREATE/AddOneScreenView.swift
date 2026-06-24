//
//  AddOneScreenView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 03/12/25.
//

import SwiftUI
import Combine
import FamilyControls

final class AddVM: ObservableObject {
    @Published var familyActivitySelection = FamilyActivitySelection(includeEntireCategory: true)
    @Published var dismiss: DismissAction?
    
    func createBlock() throws {
        guard let token = familyActivitySelection.applicationTokens.first else {
            Logger.error("Error finding applicationTokens.first")
            throw URLError(.badURL)
        }
        
        try CoreDataStack.shared.createBlock(appToken: token)
    }
}

struct AddOneScreenView: View {
    @Environment(\.dismiss) var dismiss
    let columns: [GridItem] = .init(repeating: GridItem(spacing: 10), count: 4)
    
    @StateObject private var vm = AddVM()
    
    @State private var appearAnimation: Bool = false
    @State private var showPicker: Bool = false
    @State private var nextPage: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                RoundedRectangle(cornerRadius: 56, style: .continuous)
                    .foregroundStyle(.secondary.opacity(0.15))
                    .shadow(color: .primary.opacity(0.5), radius: 6, x: 0, y: 0)
                    .padding(.horizontal)
                    .overlay(alignment: .top) {
                        VStack(spacing: 18) {
                            RoundedRectangle(cornerRadius: 100, style: .continuous)
                                .frame(height: 38)
                                .foregroundStyle(.secondary.opacity(0.15))
                                .overlay(alignment: .leading) {
                                    HStack(spacing: 10) {
                                        Image(systemName: "magnifyingglass")
                                            .font(.system(size: 16, weight: .medium))
                                        
                                        Text("Instagram, TikTok, and more...")
                                            .font(.grotesk(.body, weight: .medium))
                                    }
                                    .foregroundStyle(Color.secondary.opacity(0.5))
                                    .padding(.horizontal)
                                }

                            LazyVGrid(columns: columns, spacing: 10) {
                                ForEach(0..<7) { index in
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .aspectRatio(1/1, contentMode: .fit)
                                        .foregroundStyle(.secondary.opacity(0.15))
                                        .opacity(appearAnimation ? 1 : 0)
                                        .animation(.smooth(duration: 0.5).delay(TimeInterval(index) * 0.05), value: appearAnimation)
                                }
                            }
                        }
                        .padding(.horizontal, 32)
                        .offset(y: 64)
                    }
                    .offset(y: appearAnimation ? 0 : 32)
                    .animation(.smooth(duration: 0.5), value: appearAnimation)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(32)
            .background(Theme.foregroundC, ignoresSafeAreaEdges: .all)
            .overlay(alignment: .bottom) {
                VStack(spacing: 14) {
                    
                    Text("Step 1".uppercased())
                        .font(.grotesk(.footnote, weight: .semibold))
                        .kerning(1.0)
                        .foregroundStyle(.secondary)
                    
                    Text("Search the app you want to block")
                        .font(.grotesk(size: 30, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2.0)
                        .foregroundStyle(.textC)
                        .padding(.horizontal)

                    Space(height: 100)
                    
                    GlassButton {
                        showPicker = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .fontWeight(.semibold)
                                .font(.grotesk(size: 20, weight: .semibold))

                            Text("Search app")
                                .font(.grotesk(size: 20, weight: .semibold))
                        }
                    }
                    
                }
                .frame(height: 320, alignment: .bottom)
                .padding(.horizontal, 32)
                .padding(.vertical)
                .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.primary)
                }
            }
            .sheet(isPresented: $showPicker) {
                AddTwoScreenView { fam in
                    vm.familyActivitySelection = fam
                    nextPage = true
                }
            }
            .navigationDestination(isPresented: $nextPage) {
                AddThreeScreenView()
                    .environmentObject(vm)
            }
            .onAppear(perform: setup)
        }
    }
    
    private func setup() {
        vm.dismiss = dismiss
        
        SleepTask.sleep(seconds: 0.1) {
            appearAnimation = true
        }
    }
}

#Preview {
    AddOneScreenView()
}

#Preview("Sheet Preview") {
    Text("Hello, World!")
        .sheet(isPresented: .constant(true)) {
            AddOneScreenView()
        }
}

