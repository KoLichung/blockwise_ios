//
//  LinkModel.swift
//  ProdApp
//
//  Created by Ivan Sanna on 01/10/24.
//

import SwiftUI

struct LinkModel: Identifiable, Equatable {
    var id: String { linkView.rawValue }
    
    let linkView: LinkView
    let notificationId: String
}

enum LinkView: String {
    case paywall, unlock, review
    
    @ViewBuilder
    func view(notificationId: String) -> some View {
        switch self {
        case .paywall:
            EmptyView()
        case .unlock:
//            UnblockView(id: notificationId)
            EmptyView()
        case .review:
            EmptyView()
        }
    }
}
