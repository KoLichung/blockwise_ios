//
//  Haptics.swift
//  Blockwise
//
//  Created by Ivan Sanna on 26/10/24.
//

import SwiftUI

enum Haptics {
    @AppStorage(AppStorageKeys.Settings.isHapticsEnabled.rawValue) static var isHapticsEnabled: Bool = true

    static private let notificationFeedback = UINotificationFeedbackGenerator()

    static func feedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isHapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    static func successFeedback() {
        notificationFeedback.notificationOccurred(.success)
    }

    static func warningFeedback() {
        notificationFeedback.notificationOccurred(.warning)
    }

    static func errorFeedback() {
        notificationFeedback.notificationOccurred(.error)
    }
}
