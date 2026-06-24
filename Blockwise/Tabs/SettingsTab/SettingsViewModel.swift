//
//  SettingsUserViewModel.swift
//  Blockwise
//
//  Created by Ivan Sanna on 16/01/26.
//

import SwiftUI

final class SettingsViewModel: ObservableObject {
    @Published var showFAQ1: Bool = false
    @Published var showFAQ2: Bool = false
    @Published var showFAQ3: Bool = false
    @Published var showFAQ4: Bool = false
    
    @Published var showUserView: Bool = false
}
