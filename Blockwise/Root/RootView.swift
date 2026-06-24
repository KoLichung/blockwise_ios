//
//  RootView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 16/01/26.
//

import SwiftUI

struct RootView: View {
    
    @State private var tabSelection: Int = 0
    
    init(tabSelection: Int = 0) {
        _tabSelection = State(initialValue: tabSelection)
        applyCustomFont()
    }
    
    var body: some View {
        TabView(selection: $tabSelection) {
            Tab("Today", image: "time.circle", value: 0) {
                HomeTabView()
            }
            
            Tab("Schedules", image: "play.rounded", value: 1) {
                ActionsTabView()
            }
            
            Tab("Settings", systemImage: "gearshape", value: 2) {
                SettingsTabView()
            }
        }
        .sensoryFeedback(.selection, trigger: tabSelection)
        .tint(.skyBlue)
    }
    
    private func applyCustomFont() {
        //Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: GroteskFontWeight.bold.rawValue, size: 34)!]

        //Use this if NavigationBarTitle is with displayMode = .inline
        UINavigationBar.appearance().titleTextAttributes = [.font : UIFont(name: GroteskFontWeight.semibold.rawValue, size: 17)!]
    }
}

#Preview {
    RootView()
        .environmentObject(UserViewModel())
        .environmentObject(FocusViewModel())
}
