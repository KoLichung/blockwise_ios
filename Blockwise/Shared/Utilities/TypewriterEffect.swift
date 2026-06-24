//
//  TypewriterEffect.swift
//  Blockwise
//
//  Created by Ivan Sanna on 18/01/26.
//

import SwiftUI

// MARK: - Better Implementation with Highlight String Storage
struct TypewriterText: View {
    @Binding var text: String
    let fullText: String
    let highlightString: String?
    let highlightColor: Color?
    let speed: TimeInterval
    let delay: TimeInterval
    let hapticFeedback: Bool
    
    @State private var displayedText = AttributedString()
    @State private var currentIndex = 0
    @State private var timer: Timer?
    
    // MARK: - Initializers
    
    /// Typewriter with binding (no highlight)
    init(
        string: Binding<String>,
        speed: TimeInterval = 0.05,
        delay: TimeInterval = 0.15,
        hapticFeedback: Bool = true
    ) {
        self._text = string
        self.fullText = string.wrappedValue
        self.speed = speed
        self.delay = delay
        self.hapticFeedback = hapticFeedback
        self.highlightString = nil
        self.highlightColor = nil
    }
    
    /// Typewriter with binding and highlighting
    init(
        string: Binding<String>,
        highlight: String,
        color: Color,
        speed: TimeInterval = 0.05,
        delay: TimeInterval = 0.15,
        hapticFeedback: Bool = true
    ) {
        self._text = string
        self.fullText = string.wrappedValue
        self.speed = speed
        self.delay = delay
        self.hapticFeedback = hapticFeedback
        self.highlightString = highlight
        self.highlightColor = color
    }
    
    var body: some View {
        Text(displayedText)
            .animation(nil, value: displayedText)
            .onAppear {
                text = "" // Start with empty text
                startTypewriter()
            }
            .onDisappear {
                stopTypewriter()
            }
    }
    
    private func startTypewriter() {
        displayedText = AttributedString()
        currentIndex = 0
        
        // Compute highlight ranges
        var highlightRanges: [Range<String.Index>] = []
        if let highlight = highlightString {
            var searchRange = fullText.startIndex..<fullText.endIndex
            while let range = fullText.range(of: highlight, range: searchRange) {
                highlightRanges.append(range)
                searchRange = range.upperBound..<fullText.endIndex
            }
        }
        
        SleepTask.sleep(seconds: delay) {
            self.timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { timer in
                guard currentIndex < fullText.count else {
                    timer.invalidate()
                    return
                }
                
                let stringIndex = fullText.index(fullText.startIndex, offsetBy: currentIndex)
                let character = fullText[stringIndex]
                
                let isHighlighted = highlightRanges.contains { $0.contains(stringIndex) }
                var charString = AttributedString(String(character))
                
                if isHighlighted, let color = highlightColor {
                    charString.foregroundColor = color
                }
                
                displayedText.append(charString)
                currentIndex += 1
                
                // Update the binding with current displayed text
                text = String(displayedText.characters)
                
                if hapticFeedback {
                    Haptics.feedback(style: .soft)
                }
            }
        }
    }
    
    private func stopTypewriter() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Usage Examples

#Preview("Basic with Binding") {
    struct Example: View {
        @State private var displayedText = "Hi! I'm Blok!"
        
        var body: some View {
            VStack(spacing: 32) {
                TypewriterText(string: $displayedText)
                    .font(.title)
                    .padding()
                
                Text("Current: '\(displayedText)'")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .animation(.smooth(duration: 0.2), value: displayedText)
            .padding()
        }
    }
    
    return Example()
}

#Preview("With Highlight") {
    struct Example: View {
        @State private var displayedText = "Hi! I'm Blok!"
        
        var body: some View {
            VStack(spacing: 32) {
                TypewriterText(
                    string: $displayedText,
                    highlight: "Blok!",
                    color: .blue
                )
                .font(.title)
                .padding()
                .multilineTextAlignment(.center)
            }
            .animation(.smooth(duration: 0.2), value: displayedText)
            .padding()
        }
    }
    
    return Example()
}

#Preview("Complete Example with Animation") {
    struct Example: View {
        @State private var displayedText = "Hi! I'm Blok!"
        
        var body: some View {
            VStack(spacing: 32) {
                TypewriterText(
                    string: $displayedText,
                    highlight: "Blok!",
                    color: .blue
                )
                .font(.title2)
                .padding()
                .multilineTextAlignment(.center)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(radius: 5)
                )
                
                Image(systemName: "eye.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88, height: 88)
            }
            .animation(.smooth(duration: 0.2), value: displayedText)
            .padding(32)
        }
    }
    
    return Example()
}

#Preview("Multiple Highlights") {
    struct Example: View {
        @State private var displayedText = "Blok is here! Use Blok to focus!"
        
        var body: some View {
            TypewriterText(
                string: $displayedText,
                highlight: "Blok",
                color: .blue
            )
            .font(.title2)
            .padding()
        }
    }
    
    return Example()
}

#Preview("Custom Speed") {
    struct Example: View {
        @State private var displayedText = "Typing slowly..."
        
        var body: some View {
            TypewriterText(
                string: $displayedText,
                speed: 0.15,
                delay: 0.5,
                hapticFeedback: false
            )
            .font(.title)
            .padding()
        }
    }
    
    return Example()
}
