//
//  ToastManager.swift
//  Blockwise
//
//  Created by Ivan Sanna on 10/07/25.
//

import SwiftUI

// MARK: - Toast Manager
@MainActor
class ToastManager: ObservableObject {
    @Published var currentToast: ToastData?
    private var dismissTask: Task<Void, Never>?
    
    func show(_ toast: ToastData) {
        // Cancel any existing dismiss task
        dismissTask?.cancel()
        
        // Show the toast
        currentToast = toast
        
        // Schedule auto-dismiss
        dismissTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(toast.duration * 1_000_000_000))
            if !Task.isCancelled {
                dismiss()
            }
        }
    }
    
    func dismiss() {
        dismissTask?.cancel()
        currentToast = nil
    }
    
    // Convenience methods
    func success(_ message: String, duration: TimeInterval = 3.0) {
        show(ToastData(type: .success, message: message, duration: duration))
    }
    
    func error(_ message: String, duration: TimeInterval = 4.0) {
        show(ToastData(type: .error, message: message, duration: duration))
    }
    
    func info(_ message: String, duration: TimeInterval = 3.0) {
        show(ToastData(type: .info, message: message, duration: duration))
    }
    
    func warning(_ message: String, duration: TimeInterval = 3.5) {
        show(ToastData(type: .warning, message: message, duration: duration))
    }
}

// MARK: - Toast Types
enum ToastType {
    case success
    case error
    case info
    case warning
    
    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .info: return Color.blueAccent
        case .warning: return .orange
        }
    }
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - Toast Data Model
struct ToastData: Equatable {
    let type: ToastType
    let message: String
    let duration: TimeInterval
    
    init(type: ToastType, message: String, duration: TimeInterval = 3.0) {
        self.type = type
        self.message = message
        self.duration = duration
    }
}

// MARK: - Toast View
struct ToastView: View {
    let toast: ToastData
    let onDismiss: () -> Void
    
    @State private var appearAnimation: Bool = false
    
    var body: some View {
        Rectangle()
            .foregroundStyle(toast.type.color)
            .frame(height: 128)
            .overlay(alignment: .bottom) {
                HStack(spacing: 8) {
                    Image(systemName: toast.type.icon)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white)
                    
                    Text(toast.message)
                        .font(.grotesk(.subheadline, weight: .medium))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .overlay(alignment: .bottomLeading) {
                Rectangle()
                    .frame(height: 3)
                    .frame(maxWidth: appearAnimation ? .infinity : .zero)
                    .foregroundStyle(toast.type.color)
                    .brightness(-0.15)
            }
            .ignoresSafeArea()
            .onTapGesture {
                onDismiss()
            }
            .onAppear(perform: setup)
    }
    
    private func setup() {
        withAnimation(.linear(duration: toast.duration)) {
            appearAnimation = true
        }
    }
}

// MARK: - Toast Modifier
struct ToastModifier: ViewModifier {
    @ObservedObject var toastManager: ToastManager
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let toast = toastManager.currentToast {
                    ToastView(toast: toast) {
                        toastManager.dismiss()
                    }
                    .transition(.offset(y: -256))
                }
            }
            .animation(.smooth(duration: 0.35), value: toastManager.currentToast)
    }
}

// MARK: - View Extension
extension View {
    func toast(manager: ToastManager) -> some View {
        self.modifier(ToastModifier(toastManager: manager))
    }
}

// MARK: - Usage Example
struct ToastPreviewView: View {
    @StateObject private var toastManager = ToastManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Show Success Toast") {
                toastManager.success("Feedback sent successfully!")
            }
            .buttonStyle(.borderedProminent)
            
            Button("Show Error Toast") {
                toastManager.error("Failed to send feedback. Please try again. Operation couldn't be completed. Error: 432 URLSessionNetworkAuthenticationRequired.")
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            
            Button("Show Info Toast") {
                toastManager.info("New update available in the App Store.")
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.primaryBlue)
            
            Button("Show Warning Toast") {
                toastManager.warning("Your session will expire in 5 minutes.")
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            
            Button("Show Custom Toast") {
                let customToast = ToastData(
                    type: .success,
                    message: "Custom message with longer duration",
                    duration: 5.0
                )
                toastManager.show(customToast)
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toast(manager: toastManager)
    }
}

#Preview {
    ToastPreviewView()
}
