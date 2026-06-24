//
//  AddBlockUserViewModel.swift
//  Blockwise
//
//  Created by Ivan Sanna on 16/11/25.
//

import SwiftUI
import FamilyControls

final class AddBlockUserViewModel: ObservableObject {
    @Published var familyActivitySelection = FamilyActivitySelection(includeEntireCategory: true)
    @Published var dismiss: DismissAction?
    
    func createBlock() throws {
        guard let appToken = familyActivitySelection.applicationTokens.first else {
            Logger.error("Error finding applicationTokens.first")
            throw URLError(.badURL)
        }
        
        try CoreDataStack.shared.createBlock(appToken: appToken)
    }
}
