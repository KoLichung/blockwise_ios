//
//  SuperlinkListView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 04/02/26.
//

import SwiftUI

struct SuperlinkListView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm = SuperlinkViewModel()
    @StateObject private var toastManager = ToastManager()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BlockEntity.dateCreated, ascending: false)],
        animation: .default
    )
    private var blocks: FetchedResults<BlockEntity>

    var body: some View {
        NavigationStack {
            ZStack {
                if filteredApps.isEmpty && !vm.searchInput.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text("No app found")
                            .font(.grotesk(.title, weight: .semibold))
                            .foregroundStyle(.textC)
                        
                        Text("We couldn't find \"\(vm.searchInput)\"")
                            .font(.grotesk(.body, weight: .regular))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button {
                            vm.requestedApp = vm.searchInput
                            vm.showRequestAlert = true
                        } label: {
                            Text("Request this app")
                                .font(.grotesk(.body, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .clipShape(Capsule())
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Section {
                            ForEach(filteredApps) { app in
                                NavigationLink {
                                    SuperlinkConfirmView(superlink: app)
                                        .environmentObject(vm)
                                } label: {
                                    HStack(spacing: 14) {
                                        Image(app.asset)
                                            .resizable()
                                            .scaledToFit()
                                            .appIconStyle(size: 38)
                                        
                                        Text(app.name)
                                            .font(.grotesk(.title3, weight: .regular))
                                        
                                        if usedSuperlinkIds.contains(app.id) {
                                            Spacer()
                                            
                                            Text("Superlinked")
                                                .font(.grotesk(.subheadline, weight: .regular))
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .disabled(usedSuperlinkIds.contains(app.id))
                                .listRowBackground(Theme.foregroundC)
                            }
                        } header: {
                            Text("Search for your app")
                        } footer: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("We update this list regularly. If you didn't find your app, ")
                                + Text("request it here")
                                    .foregroundColor(.blue)
                                    .underline()
                                + Text(" and we'll add it.")
                            }
                            .onTapGesture {
                                vm.showRequestAlert = true
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
            .searchable(text: $vm.searchInput, placement: .automatic, prompt: "Search apps")
            .navigationTitle("Superlink your app")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        #if DEBUG
                        debugURLSchemes()
                        #endif
                        vm.showInfoView = true
                    } label: {
                        Image(systemName: "info")
                    }
                    .tint(.primary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.primary)
                }
            }
            .alert("Request an App", isPresented: $vm.showRequestAlert) {
                TextField("App name", text: $vm.requestedApp)
                Button("Cancel", role: .cancel) {
                    vm.requestedApp = ""
                }
                Button("Submit") {
                    vm.sendRequest()
                    toastManager.info("Request sent!")
                }
            } message: {
                Text("Which app would you like us to add?")
            }
            .sheet(isPresented: $vm.showInfoView) {
                SuperlinkInfoView()
            }
        }
        .toast(manager: toastManager)
        .onAppear {
            vm.dismissAll = dismiss
        }
    }
    
    // Computed properties
    
    var usedSuperlinkIds: [String] {
        blocks.compactMap { $0.superlinkId }
    }
    
    var filteredApps: [Superlink] {
        let apps: [Superlink]
        
        if vm.searchInput.isEmpty {
            apps = vm.apps
        } else {
            apps = vm.apps.filter { $0.name.localizedCaseInsensitiveContains(vm.searchInput) }
        }
        
        return apps.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }


}

#Preview {
    NavigationStack {
        SuperlinkListView()
            .environmentObject(SuperlinkViewModel())
            .environmentObject(BlockViewModel())
    }
}

#Preview {
    SuperlinkInfoView()
}

struct SuperlinkInfoView: View {
    @Environment(\.dismiss) private var dismiss
    let superlinkDisplay: Superlink = Superlink.apps[0]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    
                    VStack(spacing: 0) {
                        HStack(spacing: 32) {
                            VStack(spacing: 18) {
                                Image(superlinkDisplay.asset)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(square: 64)
                                    .appIconStyle(size: 64)
                                    .blur(radius: 2)
                                
                                Text("?")
                                    .font(.grotesk(.body, weight: .semibold))
                                    .foregroundStyle(.textC)
                            }
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundStyle(.textC)
                            
                            VStack(spacing: 18) {
                                Image(superlinkDisplay.asset)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(square: 64)
                                    .appIconStyle(size: 64)
                                
                                Text(superlinkDisplay.name)
                                    .font(.grotesk(.body, weight: .semibold))
                                    .foregroundStyle(.textC)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(32)
                    .background {
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .foregroundStyle(Theme.foregroundC)
                            .border(cornerRadius: 32)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What is Superlink?")
                            .font(.grotesk(.title2, weight: .bold))
                            .foregroundStyle(.textC)

                        Text("Superlink allows you to automatically open your app when you unlock it. Here's how it works:\n\nWhen you create a block, \(AppConfiguration.name) doesn't automatically know which app you're blocking. If you enable Superlink, you tell Blockwise which app to open by selecting it from our list.\n\n**Why does this matter?** When you tap \"Open for X minutes\" on a superlinked block, the app opens instantly. Without Superlink, you'd have to unlock the block and then switch back to the opened app yourself.\n\nIt's a simple convenience feature that makes unlocking faster and easier.")
                            .font(.grotesk(.body, weight: .regular))
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                    }
                    
                    WasThisHelpfulButtons(context: "What is Superlink?")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding()
            }
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
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
            .navigationTitle("What is Superlink?")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
#if DEBUG
extension SuperlinkListView {
    
    private func debugURLSchemes() {
        let results = vm.apps.map { app in
            (
                name: app.name,
                scheme: app.urlScheme,
                asset: app.asset,
                canQuery: canOpenURLScheme(app.urlScheme),
                hasAsset: assetExists(app.asset)
            )
        }
        
        let notInstalled = results.filter { !$0.canQuery }
        let missingAssets = results.filter { !$0.hasAsset }
        let allGood = results.filter { $0.canQuery && $0.hasAsset }
        
        print("\n🔍 Superlink Debug Report")
        print(String(repeating: "=", count: 60))
        print("✅ Installed & Configured: \(allGood.count)")
        print("📱 Not Installed (or missing from plist): \(notInstalled.count)")
        print("🖼️  Missing Assets: \(missingAssets.count)")
        print(String(repeating: "=", count: 60))
        
        if !notInstalled.isEmpty {
            print("\n📱 Apps not installed OR missing from LSApplicationQueriesSchemes:")
            print("   (Install the app to verify plist configuration)")
            notInstalled.forEach {
                print("   - \($0.name): \($0.scheme)")
            }
        }
        
        if !missingAssets.isEmpty {
            print("\n🖼️  Missing Assets (not in Asset Catalog):")
            missingAssets.forEach {
                print("   - \($0.name): \($0.asset)")
            }
        }
        
        // Show items with BOTH issues
        let bothMissing = results.filter { !$0.canQuery && !$0.hasAsset }
        if !bothMissing.isEmpty {
            print("\n⚠️  Not installed/queryable AND missing asset:")
            bothMissing.forEach {
                print("   - \($0.name)")
                print("     • Scheme: \($0.scheme)")
                print("     • Asset: \($0.asset)")
            }
        }
        
        if allGood.count == results.count {
            print("\n✅ All superlinks are properly configured!")
        } else {
            print("\n💡 Tip: Install apps to verify LSApplicationQueriesSchemes configuration")
        }
        
        print("\n")
    }
    
    private func canOpenURLScheme(_ scheme: String) -> Bool {
        guard let url = URL(string: "\(scheme)://") else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
    
    private func assetExists(_ assetName: String) -> Bool {
        return UIImage(named: assetName) != nil
    }
}
#endif
