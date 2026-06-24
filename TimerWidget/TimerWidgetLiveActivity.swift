//
//  TimerWidgetLiveActivity.swift
//  TimerWidget
//
//  Created by Ivan Sanna on 04/09/25.
//

import SwiftUI
import WidgetKit
import ActivityKit
import AppIntents
import AlarmKit

struct TimerLiveActivity: Widget {
    @State private var formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    var body: some WidgetConfiguration {
        #if targetEnvironment(simulator)
        return makeActivityConfiguration()
        #else
        if #available(iOS 26.0, *) {
            return makeActivityConfigurationWithAlarm()
        } else {
            return makeActivityConfiguration()
        }
        #endif
    }
    
    private func makeActivityConfiguration() -> some WidgetConfiguration {
        ActivityConfiguration(for: TimerAttributes.self) { context in
            // LOCK SCREEN / STANDBY
            let remaining = max(0, context.state.endDate.timeIntervalSinceNow)
            
            HStack(spacing: 0) {
                Image(.logoSmall)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)

                Spacer()
                
//                TextTimer(Date.now...Date.now.addingTimeInterval(remaining), font: .systemFont(ofSize: 44))
                TextTimer(Date.now...Date.now.addingTimeInterval(remaining), font: .grotesk(size: 48))
            }
            .padding()
            .activityBackgroundTint(.clear)
            .activitySystemActionForegroundColor(.primary)
            
        } dynamicIsland: { context in
            // DYNAMIC ISLAND
            let remaining = max(0, context.state.endDate.timeIntervalSinceNow)
            
            return DynamicIsland {
                // Expanded
                DynamicIslandExpandedRegion(.leading) {
                    Image(.logoSmall)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 44)
                        .frame(maxHeight: .infinity, alignment: .center)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
//                    TextTimer(Date.now...Date.now.addingTimeInterval(remaining), font: .systemFont(ofSize: 44))
                    TextTimer(Date.now...Date.now.addingTimeInterval(remaining), font: .grotesk(size: 48))
                }
                
                DynamicIslandExpandedRegion(.center) {
                    // Empty - keeps leading and trailing regions separated
                }
                
                DynamicIslandExpandedRegion(.bottom) {

                }
                
            } compactLeading: {
                Image(.logoSmall)
                    .resizable()
                    .scaledToFit()
//                    .padding(2)
                    .frame(width: 22, height: 16)
            } compactTrailing: {
                let remaining = max(0, context.state.endDate.timeIntervalSinceNow)
                
//                TextTimer(Date.now...Date.now.addingTimeInterval(remaining), font: .systemFont(ofSize: 15))
                TextTimer(Date.now...Date.now.addingTimeInterval(remaining), font: .grotesk(size: 15))
            } minimal: {
                let remaining = max(0, context.state.endDate.timeIntervalSinceNow)
                
                ProgressView(
                    timerInterval: Date.now...Date.now.addingTimeInterval(remaining),
                    countsDown: false,
                    label: { EmptyView() },
                    currentValueLabel: { EmptyView() }
                )
                .progressViewStyle(.circular)
            }
        }
    }
    
    @available(iOS 26.0, *)
    private func makeActivityConfigurationWithAlarm() -> some WidgetConfiguration {
        ActivityConfiguration(for: AlarmAttributes<CountdownAttributes>.self) { context in
            // Lock screen/banner UI goes here
            HStack(spacing: 0) {
                Image(.logoSmall)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)

                Spacer()
                
                switch context.state.mode {
                case .countdown(let countdown):
                    let remaining = max(0, countdown.fireDate.timeIntervalSinceNow)

//                    TextTimer(Date.now...Date.now.addingTimeInterval(remaining), font: .systemFont(ofSize: 48))
                    TextTimer(Date.now...Date.now.addingTimeInterval(remaining), font: .grotesk(size: 48))
                    
                case .paused(_):
                    Text("P")
                case .alert(_):
                    Text("A")
                @unknown default:
                    fatalError()
                } // End switch
            }
            .padding()
            .activityBackgroundTint(.clear)
            .activitySystemActionForegroundColor(.primary)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Image(.logoSmall)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 44)
                        .frame(maxHeight: .infinity, alignment: .center)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    switch context.state.mode {
                    case .countdown(let countdown):
                        let remaining = max(0, countdown.fireDate.timeIntervalSinceNow)

//                        TextTimer(Date.now...Date.now.addingTimeInterval(remaining), font: .systemFont(ofSize: 48))
                        TextTimer(Date.now...Date.now.addingTimeInterval(remaining), font: .grotesk(size: 48))
                        
                    case .paused(let paused):
                        Text("P")
                    case .alert(_):
                        Text("A")
                    @unknown default:
                        fatalError()
                    } // End switch
                }
//                DynamicIslandExpandedRegion(.bottom) {
//                    Text("Bottom")
//                }
            } compactLeading: {
                Image(.logoSmall)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 16)
            } compactTrailing: {
                switch context.state.mode {
                case .countdown(let countdown):
//                    Text("0:00")
//                        .overlay {
//                            Text(countdown.fireDate, style: .timer)
//                        }
                    let remaining = max(0, countdown.fireDate.timeIntervalSinceNow)

//                    TextTimer(Date.now...Date.now.addingTimeInterval(remaining), font: .systemFont(ofSize: 15))
                    TextTimer(Date.now...Date.now.addingTimeInterval(remaining), font: .grotesk(size: 15))

                case .paused(let paused):
                    Text("P")
                case .alert(_):
                    Text("A")
                @unknown default:
                    fatalError()
                } // End switch

            } minimal: {
                switch context.state.mode {
                case .countdown(let countdown):
                    let remaining = max(0, countdown.fireDate.timeIntervalSinceNow)

                    ProgressView(
                        timerInterval: Date.now...Date.now.addingTimeInterval(remaining),
                        countsDown: false,
                        label: { EmptyView() },
                        currentValueLabel: { EmptyView() }
                    )
                    .progressViewStyle(.circular)

                case .paused(let paused):
                    Text("P")
                case .alert(_):
                    Text("A")
                @unknown default:
                    fatalError()
                } // End switch
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.blue)
        }
    }
}

struct StopTimerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Stop Timer"
    static var description = IntentDescription("Stops the current timer")
    
    func perform() async throws -> some IntentResult {
        // Handle stop action in your app
        // You can use notifications, shared data, or other methods to communicate with your main app
        return .result()
    }
}

// Small helpers for concise time labels
fileprivate extension Text {
    init(timeInterval: TimeInterval) {
        self = Text(timerInterval: Date.now ... Date.now.addingTimeInterval(timeInterval), countsDown: true)
    }
    
    init(shortTime time: TimeInterval) {
        let comps = Int(time)
        let m = comps / 60
        let s = comps % 60
        self = Text(String(format: "%d:%02d", m, s))
    }
}

extension TimerAttributes {
    fileprivate static var preview: TimerAttributes {
        TimerAttributes()
    }
}

extension TimerAttributes.ContentState {
    fileprivate static var sampleRunning: TimerAttributes.ContentState {
        TimerAttributes.ContentState(
            startDate: .now.addingTimeInterval(-240), // Started 4 minutes ago
            endDate: .now.addingTimeInterval(600), // 10 minutes remaining
            entityId: ""
        )
    }
    
    fileprivate static var sampleAlmostDone: TimerAttributes.ContentState {
        TimerAttributes.ContentState(
            startDate: .now.addingTimeInterval(-540), // Started 9 minutes ago
            endDate: .now.addingTimeInterval(60), // 1 minute remaining
            entityId: ""
        )
    }
}

#Preview("Lock Screen", as: .content, using: TimerAttributes.preview) {
    TimerLiveActivity()
} contentStates: {
    TimerAttributes.ContentState.sampleRunning
    TimerAttributes.ContentState.sampleAlmostDone
}

#Preview("Dynamic Island Compact", as: .dynamicIsland(.compact), using: TimerAttributes.preview) {
    TimerLiveActivity()
} contentStates: {
    TimerAttributes.ContentState.sampleRunning
}


import SwiftUI

struct TextTimer: View {

    let dateRange: ClosedRange<Date>
    let font: UIFont
    let width: CGFloat

    init(_ dateRange: ClosedRange<Date>, font: UIFont, width: CGFloat? = nil) {
        self.dateRange = dateRange
        self.font = font
        self.width = width ?? TextTimer.defaultWidth(font: font, dateRange: dateRange)
    }

    var body: some View {
        Text(timerInterval: dateRange, showsHours: false)
            .font(Font(font))
            .frame(width: width > 0 ? width : nil)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .multilineTextAlignment(.trailing)
    }

    private static func defaultWidth(font: UIFont, dateRange: ClosedRange<Date>) -> CGFloat {
        let maxString = maxStringFor(dateRange: dateRange)
        let fontAttributes = [NSAttributedString.Key.font: font]
        return (maxString as NSString).size(withAttributes: fontAttributes).width
    }

    private static func maxStringFor(dateRange: ClosedRange<Date>) -> String {
        let duration = dateRange.upperBound.timeIntervalSince(dateRange.lowerBound)
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

}
