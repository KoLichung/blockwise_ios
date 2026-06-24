//
//  TimerWidget.swift
//  TimerWidget
//
//  Created by Ivan Sanna on 04/09/25.
//

import WidgetKit  // Apple's framework for creating widgets
import SwiftUI    // For building the UI
import CoreData   // To access your app's database

// MARK: - Timeline Provider
// This is the "brain" of your widget. It tells iOS:
// 1. What placeholder to show while loading
// 2. What data to display right now
// 3. When to refresh the widget with new data
struct Provider: TimelineProvider {
    // Shared access to your Core Data database
    // This is the same database your main app uses
    let persistenceController = CoreDataStack.shared
    
    // PLACEHOLDER
    // Purpose: Shows a temporary view while the widget is loading
    // When it's used: First time adding widget, or when iOS needs a quick preview
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            totalUsage: 0,      // Show 0 usage as placeholder
            goal: 3600,         // Default 1 hour goal
            progress: 0         // No progress
        )
    }
    
    // SNAPSHOT
    // Purpose: Provides data for the widget gallery (when user is browsing widgets to add)
    // When it's used: When user opens the widget picker to add your widget
    // Note: Should be fast! iOS might call this multiple times quickly
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = fetchCurrentData()  // Get real data from database
        completion(entry)               // Send it back to iOS
    }
    
    // TIMELINE
    // Purpose: The main function! Tells iOS what to display and when to refresh
    // When it's used: Every time the widget needs to update
    // Returns: A "timeline" = array of entries with dates telling iOS when to show each one
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = fetchCurrentData()  // Get current screen time data
        
        // Tell iOS: "Update this widget again in 15 minutes"
        // This keeps your widget fresh without draining battery
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        
        // Create timeline with one entry and a refresh policy
        // .after(nextUpdate) = "refresh after this date"
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)  // Send timeline back to iOS
    }
    
    // MARK: - Data Fetching
    // Purpose: Reads data from your Core Data database
    // What it does:
    // 1. Gets all screen time records from today
    // 2. Adds up total usage time
    // 3. Gets user's daily goal
    // 4. Calculates progress percentage
    private func fetchCurrentData() -> SimpleEntry {
        let context = persistenceController.persistentContainer.viewContext
        
        print("🔵 WIDGET: Starting fetch...")
        
        // Calculate today's date range
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Fetch today's records
        let recordRequest: NSFetchRequest<RecordEntity> = RecordEntity.fetchRequest()
        recordRequest.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp < %@",
                                              startOfDay as NSDate,
                                              startOfTomorrow as NSDate)
        
        do {
            let todaysRecords = try context.fetch(recordRequest)
            print("🔵 WIDGET: Found \(todaysRecords.count) records")
            
            let totalUsage = todaysRecords.reduce(0.0) { $0 + $1.duration }
            print("🔵 WIDGET: Total usage: \(totalUsage) seconds")
            
            // Fetch user's goal
            let userRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            let user = try context.fetch(userRequest).first
            let goal = user?.goal(for: Date.now) ?? 3600
            print("🔵 WIDGET: Goal: \(goal) seconds")
            
            let progress = min(1, totalUsage / max(1, goal))
            
            return SimpleEntry(
                date: Date(),
                totalUsage: totalUsage,
                goal: goal,
                progress: progress
            )
        } catch {
            print("🔴 WIDGET ERROR: \(error)")
            return SimpleEntry(
                date: Date(),
                totalUsage: 0,
                goal: 3600,
                progress: 0
            )
        }
    }
}

// MARK: - Timeline Entry
// Purpose: A single "snapshot" of data at a specific time
// Think of it like a photo that says "at 2:30 PM, here's what the widget should show"
struct SimpleEntry: TimelineEntry {
    let date: Date              // When this data is valid for
    let totalUsage: TimeInterval // Seconds used today (e.g., 1800 = 30 minutes)
    let goal: TimeInterval       // Daily goal in seconds (e.g., 3600 = 1 hour)
    let progress: Double         // Percentage 0.0 to 1.0 (e.g., 0.5 = 50%)
    
    // Computed property: How much time is left
    // Example: 3600 goal - 1800 used = 1800 seconds (30 min) remaining
    var remaining: TimeInterval {
        max(goal - totalUsage, 0)  // Never go negative
    }
}

// MARK: - Main Widget Entry View
// Purpose: Decides which widget size to show based on what user chose
// iOS has different widget sizes: Small, Medium, Large (and others)
struct TimerWidgetEntryView: View {
    var entry: Provider.Entry           // The data to display
    @Environment(\.widgetFamily) var family  // Which size widget is this?

    var body: some View {
        // Check the widget size and show the appropriate view
        switch family {
        case .systemSmall:   // Small square widget
            SmallWidgetView(entry: entry)
        case .systemMedium:  // Rectangular widget (2x1)
            MediumWidgetView(entry: entry)
        case .systemLarge:   // Large square widget (2x2)
            LargeWidgetView(entry: entry)
        default:             // Fallback for any other size
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget View
// Purpose: The UI for the small (square) widget size
// Shows: Just the circular progress and time remaining
struct SmallWidgetView: View {
    let entry: SimpleEntry  // The data to display
    
    var body: some View {
        GeometryReader { geometry in
            // Get the available size and calculate dimensions
            let size = min(geometry.size.width, geometry.size.height)  // Use smallest dimension
            let lineWidth: CGFloat = size * 0.15  // Ring thickness = 15% of size
            
            ZStack {
                // CIRCLE 1: Gray background ring (shows the full circle)
                Circle()
                    .stroke(lineWidth: lineWidth)
                    .foregroundStyle(Color.secondary.opacity(0.1))
                
                // CIRCLE 2: Inner border (subtle outline)
                Circle()
                    .stroke(lineWidth: 2)
                    .foregroundStyle(Color.secondary.opacity(0.15))
                
                // CIRCLE 3: Blue progress ring (shows how much time is used)
                // trim(from:to:) cuts the circle - from progress to 1.0 means "show remaining portion"
                // Example: if progress is 0.3, show from 0.3 to 1.0 (70% of circle)
                Circle()
                    .trim(from: entry.progress, to: 1)
                    .stroke(
                        style: StrokeStyle(
                            lineWidth: lineWidth * 0.85,  // Slightly thinner than background
                            lineCap: .round               // Rounded ends
                        )
                    )
                    .rotationEffect(.degrees(-90))  // Start at top (12 o'clock)
                    .foregroundStyle(Color.skyBlue)
                
                // CIRCLE 4: Progress ring border (gives it depth)
                Circle()
                    .trim(from: entry.progress, to: 1)
                    .stroke(lineWidth: 2)
                    .rotationEffect(.degrees(-90))
                    .foregroundStyle(Color.skyBlue)
                    .brightness(0.8)   // Slightly brighter
                    .opacity(0.15)     // Very transparent
                
                // CENTER TEXT: Time remaining and label
                VStack(spacing: 2) {
                    Text(TimeFormatter.display(entry.remaining, style: .short))
                        .font(.grotesk(size: size * 0.19, weight: .medium))
                        .foregroundStyle(Color.primary)
                    
                    Text("Left".uppercased())  // Shorter label for medium size
                        .font(.grotesk(size: size * 0.09, weight: .medium))
                        .kerning(1.5)
                        .foregroundStyle(Color.secondary.opacity(0.75))
                }
            }
            .padding(size * 0.05)  // Add some padding around the circle
        }
        .aspectRatio(1, contentMode: .fit)  // Keep it square

    }
}

// MARK: - Medium Widget View
// Purpose: The UI for the medium (rectangular) widget size
// Shows: Circular progress on left, stats on right
struct MediumWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        HStack(spacing: 20) {
            // LEFT SIDE: Circular progress (same as small widget)
            GeometryReader { geometry in
                let size = min(geometry.size.width, geometry.size.height)
                let lineWidth: CGFloat = size * 0.15
                
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(lineWidth: lineWidth)
                        .foregroundStyle(Color.secondary.opacity(0.1))
                    
                    // Border
                    Circle()
                        .stroke(lineWidth: 2)
                        .foregroundStyle(Color.secondary.opacity(0.15))
                    
                    // Progress ring
                    Circle()
                        .trim(from: entry.progress, to: 1)
                        .stroke(
                            style: StrokeStyle(
                                lineWidth: lineWidth * 0.85,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(.degrees(-90))
                        .foregroundStyle(Color.skyBlue)
                    
                    // Progress border
                    Circle()
                        .trim(from: entry.progress, to: 1)
                        .stroke(lineWidth: 2)
                        .rotationEffect(.degrees(-90))
                        .foregroundStyle(Color.skyBlue)
                        .brightness(0.8)
                        .opacity(0.15)
                    
                    // Center text (abbreviated to save space)
                    VStack(spacing: 2) {
                        Text(TimeFormatter.display(entry.remaining, style: .short))
                            .font(.grotesk(size: size * 0.16, weight: .medium))
                            .foregroundStyle(Color.primary)
                        
                        Text("Left".uppercased())  // Shorter label for medium size
                            .font(.grotesk(size: size * 0.08, weight: .medium))
                            .kerning(1.5)
                            .foregroundStyle(Color.secondary.opacity(0.75))
                    }
                }
                .padding(size * 0.1)
            }
            .aspectRatio(1, contentMode: .fit)  // Keep circle square
            
            // RIGHT SIDE: Text stats
            // VStack = Vertical layout (stacked top to bottom)
            VStack(alignment: .leading, spacing: 12) {
                // STAT 1: Daily Goal
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today's usage".uppercased())
                        .font(.grotesk(.footnote, weight: .medium))
                        .foregroundStyle(Color.secondary)
                        .kerning(1.5)
                    
                    Text(TimeFormatter.display(entry.totalUsage, style: .short))
                        .font(.grotesk(.title, weight: .medium))
                        .foregroundStyle(Color.textC)
                }
                
                // STAT 2: Used Today
                VStack(alignment: .leading, spacing: 4) {
                    Text("Goal".uppercased())
                        .font(.grotesk(.footnote, weight: .medium))
                        .foregroundStyle(Color.secondary)
                        .kerning(1.5)
                    
                    Text(TimeFormatter.display(entry.goal, style: .short))
                        .font(.grotesk(.body, weight: .medium))
                        .foregroundStyle(Color.textC)
                }
            }
            .padding(.trailing, 16)  // Space from right edge
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
}

// MARK: - Large Widget View
// Purpose: The UI for the large (2x2 square) widget size
// Shows: Big circular progress on top, stats boxes on bottom
struct LargeWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            Theme.backgroundC
            
            // VStack = Vertical layout
            VStack(spacing: 20) {
                // TOP: Large circular progress
                GeometryReader { geometry in
                    // Make circle take 60% of available height
                    let size = min(geometry.size.width, geometry.size.height * 0.6)
                    let lineWidth: CGFloat = size * 0.12
                    
                    ZStack {
                        // Background ring
                        Circle()
                            .stroke(lineWidth: lineWidth)
                            .foregroundStyle(Color.secondary.opacity(0.1))
                        
                        // Border
                        Circle()
                            .stroke(lineWidth: 2)
                            .foregroundStyle(Color.secondary.opacity(0.15))
                        
                        // Progress ring
                        Circle()
                            .trim(from: entry.progress, to: 1)
                            .stroke(
                                style: StrokeStyle(
                                    lineWidth: lineWidth * 0.85,
                                    lineCap: .round
                                )
                            )
                            .rotationEffect(.degrees(-90))
                            .foregroundStyle(Color.skyBlue)
                        
                        // Progress border
                        Circle()
                            .trim(from: entry.progress, to: 1)
                            .stroke(lineWidth: 2)
                            .rotationEffect(.degrees(-90))
                            .foregroundStyle(Color.skyBlue)
                            .brightness(0.8)
                            .opacity(0.15)
                        
                        // Center content - more detailed for large size
                        VStack(spacing: 4) {
                            // Top label: Shows the goal
                            Text("Daily goal: \(TimeFormatter.display(entry.goal, style: .short))".uppercased())
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(Color.secondary)
                                .kerning(1.0)  // Letter spacing for style
                            
                            // Big number: Time remaining
                            Text(TimeFormatter.display(entry.remaining, style: .short))
                                .font(.system(size: size * 0.15, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.primary)
                            
                            // Bottom label
                            Text("Remaining")
                                .font(.callout.weight(.medium))
                                .foregroundStyle(Color.secondary.opacity(0.75))
                        }
                    }
                    .frame(width: size, height: size)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .aspectRatio(1, contentMode: .fit)
                
                // BOTTOM: Stats in boxes
                HStack(spacing: 20) {
                    // Left box: Daily Goal
                    StatBox(
                        title: "Daily Goal",
                        value: TimeFormatter.display(entry.goal, style: .short)
                    )
                    
                    // Right box: Used Today
                    StatBox(
                        title: "Used Today",
                        value: TimeFormatter.display(entry.totalUsage, style: .short)
                    )
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

// MARK: - Helper Views
// Purpose: A reusable stat box component
// Shows: Title on top, value below, in a rounded rectangle
struct StatBox: View {
    let title: String   // e.g., "Daily Goal"
    let value: String   // e.g., "1h 30m"
    
    var body: some View {
        VStack(spacing: 6) {
            // Title (small, gray)
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.secondary)
            
            // Value (larger, bold, white)
            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.primary)
        }
        .frame(maxWidth: .infinity)  // Expand to fill available space
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .foregroundStyle(Color.secondary.opacity(0.1))
        }
    }
}

// MARK: - Widget Configuration
// Purpose: Defines your widget and its properties
// This is what gets added to the TimerWidgetBundle above
struct TimerWidget: Widget {
    let kind: String = "TimerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TimerWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Theme.backgroundC
                }
        }
        .configurationDisplayName("Screen Time")
        .description("Track your daily screen time goal.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Previews
// Purpose: Shows what the widget looks like in Xcode without running on device
// You can preview different states (50% used, 83% used, etc.)
#Preview(as: .systemSmall) {
    TimerWidget()
} timeline: {
    // Preview state 1: 50% through goal
    SimpleEntry(date: .now, totalUsage: 1800, goal: 3600, progress: 0.5)
    // Preview state 2: 83% through goal
    SimpleEntry(date: .now, totalUsage: 3000, goal: 3600, progress: 0.83)
}

#Preview(as: .systemMedium) {
    TimerWidget()
} timeline: {
    SimpleEntry(date: .now, totalUsage: 1800, goal: 3600, progress: 0.5)
}

#Preview(as: .systemLarge) {
    TimerWidget()
} timeline: {
    SimpleEntry(date: .now, totalUsage: 1800, goal: 3600, progress: 0.5)
}
