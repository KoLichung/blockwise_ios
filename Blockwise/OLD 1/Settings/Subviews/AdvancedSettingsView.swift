//
//  AdvancedSettingsView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 22/05/25.
//

import SwiftUI

struct AdvancedSettingsView: View {
//    @AppStorage(AppStorageKeys.hapticsEnabled.rawValue) var hapticEnabled: Bool = true

    var body: some View {
        List {
            Section {
//                Toggle(isOn: $hapticEnabled) {
//                    HStack(spacing: 12) {
//                        Image(systemName: "water.waves")
//                        
//                        Text("Haptics")
//                            .font(.grotesk())
//                    }
//                }
//                .tint(Color.primaryBlue)
            } footer: {
                Text("Haptics add gentle feedback. Turn off for a quieter experience.")
                    .font(.grotesk(.footnote, weight: .regular))
            }
            .listRowBackground(Theme.foregroundC)
            .listRowSeparatorTint(Color.tertiaryBlue)
        }
        .scrollContentBackground(.hidden)
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        .navigationTitle("Advanced Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AdvancedSettingsView()
    }
}

/*
 
 struct AdvancedSettingsView: View {
     @AppStorage(AppStorageKeys.cooldown.rawValue) var cooldown: Int = 5
     @AppStorage(AppStorageKeys.waitTime.rawValue) var waitTime: Int = 5
     @AppStorage(AppStorageKeys.warningNotification.rawValue) var warningNotification: Bool = true

     let cooldowns: [Int] = Array(0...10) + [15, 20, 25, 30, 35, 40, 45, 50, 55, 60]
     let waitTimes: [Int] = [0, 5, 10, 15, 20, 25, 30]
     
     var body: some View {
         List {
             Section {
                 Picker("Cooldown", selection: $cooldown) {
                     ForEach(cooldowns, id: \.self) { cool in
                         if cool == 0 {
                             Text("No cooldown").tag(cool)
                         } else {
                             Text("\(cool) min").tag(cool)
                         }
                     }
                 }
             } header: {
                 
             } footer: {
                 Text("Cooldown prevents instant reentry. Use it to add friction after stopping.")
             }
             .tint(.secondary)
             
             Section {
                 Picker("Wait Time", selection: $waitTime) {
                     ForEach(waitTimes, id: \.self) { wait in
                         if wait == 0 {
                             Text("No wait time").tag(wait)
                         } else {
                             Text("\(wait) sec").tag(wait)
                         }
                     }
                 }
             } header: {
                 
             } footer: {
                 Text("Wait time adds a delay before you can enter. Useful to reduce impulsive use.")
             }
             .tint(.secondary)
             
             Section {
                 Toggle("Notify before close", isOn: $warningNotification)
             } header: {
                 
             } footer: {
                 Text("You'll get a heads-up 30 seconds before the app auto-closes again. Helpful if you need to wrap things up.")
             }
             .tint(Color.primaryBlue)

         }
     }
 }

 
 */
