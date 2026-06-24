//
//  LiveActivityManager.swift
//  Blockwise
//
//  Created by Ivan Sanna on 04/09/25.
//

import SwiftUI
import ActivityKit

final class LiveActivityManager<Attributes: ActivityAttributes> {

    // MARK: - Properties
    private var activity: Activity<Attributes>?

    // MARK: - Start Live Activity
    func start(attributes: Attributes, state: Attributes.ContentState, pushEnabled: Bool = false) async throws {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let content = ActivityContent(state: state, staleDate: nil)
        self.activity = try Activity<Attributes>.request(
            attributes: attributes,
            content: content,
            pushType: pushEnabled ? .token : nil
        )

        if pushEnabled, let activity {
            Task {
                for await tokenData in activity.pushTokenUpdates {
                    let token = tokenData.map { String(format: "%02x", $0) }.joined()
                    print("Live Activity push token:", token)
                    // Send token to your server
                }
            }
        }
    }

    // MARK: - Update Activity
    func update(state: Attributes.ContentState) async {
        guard let activity else { return }
        let content = ActivityContent(state: state, staleDate: nil)
        await activity.update(content)
    }

    // MARK: - End Activity
    func end(immediate: Bool = false, state: Attributes.ContentState) async {
        guard let activity else { return }
        let content = ActivityContent(state: state, staleDate: nil)
        await activity.end(content, dismissalPolicy: immediate ? .immediate : .default)
    }
}
