//
//  SuperlinkViewModel.swift
//  Blockwise
//
//  Created by Ivan Sanna on 04/02/26.
//

import SwiftUI

final class SuperlinkViewModel: ObservableObject {
    let apps: [Superlink] = Superlink.apps
    
    @Published var dismissAll: DismissAction?
    
    @Published var searchInput: String = ""
    @Published var showRequestAlert: Bool = false
    @Published var requestedApp: String = ""
    @Published var showInfoView: Bool = false
    
    func assignSuperlink(_ superlink: Superlink, block: BlockEntity) throws {
        block.superlinkId = superlink.id
        try CoreDataStack.shared.saveContext()
    }
    
    func sendRequest() {
        requestedApp = ""
    }
    
    func sendReport(message: String) {}
}
