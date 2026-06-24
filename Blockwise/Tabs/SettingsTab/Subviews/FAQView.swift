//
//  FAQView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 12/02/26.
//

import SwiftUI

struct FAQView: View {
    @Environment(\.dismiss) var dismiss
    let faq: FAQ

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(faq.title)
                        .font(.grotesk(.title2, weight: .semibold))
                        .lineSpacing(2.0)
                        .foregroundStyle(.textC)

                    Text(faq.description)
                        .font(.grotesk(.title3, weight: .regular))
                        .lineSpacing(2.0)
                        .foregroundStyle(.secondary)
                    
                    ContactSupportButton {
                        Text("Need help? Contact us")
                            .font(.grotesk(.body, weight: .medium))
                    }
                    .padding(.top, 32)
                }
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding()
            }
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
            .navigationTitle("FAQ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

#Preview {
    FAQView(faq: .screenTimeIncorrect)
}

enum FAQ: String, CaseIterable, Identifiable {
    case appsNotBlocked
    case screenTimeIncorrect
    case widgetNotUpdating
    case scheduleDidNotStart

    var id: Self { self }

    var title: String {
        switch self {
        case .appsNotBlocked:
            return "Apps are no longer being blocked"
        case .screenTimeIncorrect:
            return "Screen Time data is incorrect"
        case .widgetNotUpdating:
            return "The widget isn’t updating"
        case .scheduleDidNotStart:
            return "The schedule didn’t start"
        }
    }

    var description: String {
        switch self {
        case .appsNotBlocked:
            return "Sometimes problems with Apple's Screen Time integration cause temporary interruptions in the \(AppConfiguration.name) blocks.\n\nFollow these steps to fix:\n\n1. Tap the “Restore“ button on the block from the Today tab.\n\n2. If that button doesn't appear, please contact us."
            
        case .screenTimeIncorrect:
            return "The Screen Time shown in the Today tab is different from your iPhone’s built-in Screen Time. We only track usage for the apps you choose to block with our app. All other apps are excluded. This ensures that apps like Maps or Messages do not add to your usage and create misleading totals.\n\nPlease note that usage time is rounded to the nearest minute when you close an app. For example, if you stop using an app at 2 minutes and 13 seconds, it will be recorded as 2 minutes."

        case .widgetNotUpdating:
            return "• Due to widget refresh limits, data may be delayed by several minutes. If it's taking too long to update, try restarting your iPhone.\n\n• If a widget does not display content, please wait a moment for it to load or restart your iPhone."
            
        case .scheduleDidNotStart:
            return "Sometimes problems with Apple's Screen Time integration cause temporary interruptions in the \(AppConfiguration.name) schedule.\n\nFollow this step to fix:\n\n1. Tap the “Reload Schedules“ button on the Schedules tab."
            
        }
    }
}

