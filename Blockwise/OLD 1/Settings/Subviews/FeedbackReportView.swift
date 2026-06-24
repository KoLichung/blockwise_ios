//
//  FeedbackReportView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 10/07/25.
//

import SwiftUI
import PhotosUI
import AVFoundation
import MessageUI

struct FeedbackReportView: View {
    @State private var feedbackMessage = ""
    @State private var showPhotoPicker = false
    @State private var selectedMedia: [PhotosPickerItem] = []
    @State private var mediaAttachments: [MediaAttachment] = []
    @State private var isSubmitting = false
    @State private var showingSuccess = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingConfirmationDialog = false
    @State private var showingMailComposer = false
    @Environment(\.dismiss) private var dismiss
    
    let onFeedbackSent: () -> Void
    
    let prompt: String = "Briefly explain what happened or what isn't working."
        
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider()
                ScrollView {
                    VStack(spacing: 0) {
                        TextField(
                            "",
                            text: $feedbackMessage,
                            prompt: Text(prompt),
                            axis: .vertical
                        )
                        .frame(maxHeight: .infinity)
                        .immediateKeyboard()
                        .lineLimit(5...15)
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationBarTitleDisplayMode(.inline)
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
//            .toolbar(edge: .center) {
//                Text("Report problem")
//                    .font(.grotesk(.body, weight: .semibold))
//            }
//            .toolbar(edge: .trailing) {
//                if isSubmitting {
//                    ProgressView()
//                } else {
//                    Button {
//                        showingConfirmationDialog = true
//                        Haptics.feedback(style: .light)
//                    } label: {
//                        Text("Send")
//                            .font(.grotesk(.body, weight: .semibold))
//                    }
//                    .tint(Color.primaryBlue)
//                    .disabled(!canSubmit || isSubmitting)
//                }
//            }
//            .toolbar(edge: .leading) {
//                Button {
//                    dismiss()
//                    Haptics.feedback(style: .rigid)
//                } label: {
//                    Text("Cancel")
//                        .font(.grotesk())
//                }
//            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 10) {
                    if !mediaAttachments.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(mediaAttachments.indices, id: \.self) { index in
                                    MediaThumbnailView(
                                        attachment: mediaAttachments[index],
                                        onRemove: { removeAttachment(at: index) }
                                    )
                                }
                            }
                            .padding(.top)
                        }
                        .contentMargins(.horizontal, 16, for: .scrollContent)
                    }

                    Button {
                        showPhotoPicker = true
                        Haptics.feedback(style: .soft)
                    } label: {
                        Rectangle()
                            .foregroundStyle(.thinMaterial)
                            .frame(height: 44)
                            .overlay {
                                HStack(spacing: 10) {
                                    Image(systemName: "camera")
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Text("Upload Screenshot")
                                        .font(.grotesk(.subheadline, weight: .medium))
                                }
                            }
                    }
                    .tint(.primary)
                    .disabled(mediaAttachments.count == 5)
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .onChange(of: selectedMedia) {
                Task {
                    await loadSelectedMedia(selectedMedia)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .confirmationDialog("Send Feedback", isPresented: $showingConfirmationDialog) {
                Button("Send Anonymously") {
                    submitFeedback(isAnonymous: true)
                }
                Button("Send via Email") {
                    if MFMailComposeViewController.canSendMail() {
                        // Send notification to Telegram first
                        Task {
                            await sendEmailNotificationToTelegram()
                        }
                        showingMailComposer = true
                    } else {
                        errorMessage = "Mail is not configured on this device"
                        showingError = true
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Anonymous feedback is welcome, but please note we won’t be able to respond without your contact details.")
            }
            .sheet(isPresented: $showingMailComposer) {
                MailComposerView(
                    feedbackMessage: feedbackMessage,
                    mediaAttachments: mediaAttachments,
                    onDismiss: {
                        showingMailComposer = false
                        dismiss()
                        onFeedbackSent()
                    }
                )
            }
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $selectedMedia,
                maxSelectionCount: 5,
                matching: .images, // Only allow images, no videos
                photoLibrary: .shared()
            )
            .interactiveDismissDisabled(isSubmitting)
        }
    }
        
    private var canSubmit: Bool {
        !feedbackMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func loadSelectedMedia(_ items: [PhotosPickerItem]) async {
        var newAttachments: [MediaAttachment] = []
        
        for item in items {
            // Only process images now
            if let data = try? await item.loadTransferable(type: Data.self) {
                let attachment = MediaAttachment(
                    id: UUID(),
                    data: data,
                    isVideo: false // Always false since we only allow images
                )
                newAttachments.append(attachment)
            }
        }
        
        await MainActor.run {
            mediaAttachments = newAttachments
        }
    }
    
    private func removeAttachment(at index: Int) {
        Haptics.feedback(style: .light)
        mediaAttachments.remove(at: index)
    }
    
    private func submitFeedback(isAnonymous: Bool) {
        guard canSubmit else { return }
        
        isSubmitting = true
        Haptics.feedback(style: .light)
        
        Task {
            do {
                try await sendFeedbackToTelegram(isAnonymous: isAnonymous)
                await MainActor.run {
                    isSubmitting = false
                    dismiss()
                    onFeedbackSent()
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    private func sendFeedbackToTelegram(isAnonymous: Bool) async throws {
        let botToken = Secrets.telegramBotToken
        let chatId = Secrets.telegramChatId
        
        // Send text message first
        try await sendTextMessage(botToken: botToken, chatId: chatId, isAnonymous: isAnonymous)
        
        // Send media attachments
        for attachment in mediaAttachments {
            try await sendMediaAttachment(
                botToken: botToken,
                chatId: chatId,
                attachment: attachment
            )
        }
    }
    
    private func sendTextMessage(botToken: String, chatId: String, isAnonymous: Bool) async throws {
        let device = UIDevice.current
        let deviceModel = device.model
        let systemVersion = device.systemVersion
//        let deviceName = device.name
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        
        // Get device identifier (more specific model info)
        let deviceIdentifier = getDeviceIdentifier()
        
        // Get available storage
        let availableStorage = getAvailableStorage()
        
        // Get memory info
//        let memoryInfo = getMemoryInfo()
        
        // Get timezone
        let timeZone = TimeZone.current.localizedName(for: .standard, locale: .current) ?? "Unknown"
        
        // Get locale
//        let locale = Locale.current.identifier
        
        // Format timestamp as requested
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy, HH:mm"
        let timestamp = dateFormatter.string(from: Date())
        
        // Create feedback type indicator
        let feedbackType = isAnonymous ? "Anonymous" : "Contact Requested"
        let feedbackIcon = isAnonymous ? "🕶️" : "📧"
        
        // Clean, well-formatted message for Telegram
        let message = """
\(feedbackIcon) <b>Feedback Type: \(feedbackType)</b>

💬 <b>Feedback Message</b>
\(feedbackMessage.trimmingCharacters(in: .whitespacesAndNewlines))

📱 <b>Device Information</b>
• Model: \(deviceModel) (\(deviceIdentifier))
• iOS: \(systemVersion)
• App Version: \(appVersion) (\(buildNumber))
• Available Storage: \(availableStorage)
• Timezone: \(timeZone)
• Time: \(timestamp)
"""
        
        let urlString = "https://api.telegram.org/bot\(botToken)/sendMessage"
        guard let url = URL(string: urlString) else {
            throw FeedbackError.invalidURL
        }
        
        let body: [String: Any] = [
            "chat_id": chatId,
            "text": message,
            "parse_mode": "HTML"
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw FeedbackError.networkError
        }
    }
    
    private func sendMediaAttachment(botToken: String, chatId: String, attachment: MediaAttachment) async throws {
        let boundary = UUID().uuidString
        let endpoint = "sendPhoto" // Only photos now
        let fieldName = "photo"
        
        let urlString = "https://api.telegram.org/bot\(botToken)/\(endpoint)"
        guard let url = URL(string: urlString) else {
            throw FeedbackError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let httpBody = createMultipartBody(
            boundary: boundary,
            chatId: chatId,
            fieldName: fieldName,
            attachment: attachment
        )
        
        request.httpBody = httpBody
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw FeedbackError.networkError
        }
    }
    
    private func createMultipartBody(boundary: String, chatId: String, fieldName: String, attachment: MediaAttachment) -> Data {
        var body = Data()
        
        // Chat ID
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"chat_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(chatId)\r\n".data(using: .utf8)!)
        
        // Media file (only images now)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        let filename = "image.jpg"
        let mimeType = "image/jpeg"
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(attachment.data)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
    
    // Helper functions for device information
    private func getDeviceIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    private func getAvailableStorage() -> String {
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
            let freeSpace = systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber
            if let freeBytes = freeSpace?.int64Value {
                return ByteCountFormatter.string(fromByteCount: freeBytes, countStyle: .file)
            }
        } catch {
            return "Unknown"
        }
        return "Unknown"
    }
    
    private func getMemoryInfo() -> String {
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        let memoryFormatter = ByteCountFormatter()
        memoryFormatter.countStyle = .memory
        return memoryFormatter.string(fromByteCount: Int64(totalMemory))
    }
    
    private func sendEmailNotificationToTelegram() async {
        let botToken = Secrets.telegramBotToken
        let chatId = Secrets.telegramChatId
        
        let device = UIDevice.current
        let deviceModel = device.model
        let systemVersion = device.systemVersion
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy, HH:mm"
        let timestamp = dateFormatter.string(from: Date())
        
        let message = """
📧 <b>Feedback received via Email</b>

📱 <b>Device Information</b>
• Model: \(deviceModel)
• iOS: \(systemVersion)  
• App Version: \(appVersion) (\(buildNumber))
• Time: \(timestamp)

💌 User chose to send detailed feedback via email instead of anonymous submission.
"""
        
        let urlString = "https://api.telegram.org/bot\(botToken)/sendMessage"
        guard let url = URL(string: urlString) else { return }
        
        let body: [String: Any] = [
            "chat_id": chatId,
            "text": message,
            "parse_mode": "HTML"
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            _ = try await URLSession.shared.data(for: request)
            // Silently handle any errors - this is just a notification
        } catch {
            // Ignore errors for this notification
        }
    }
}

struct MediaAttachment: Identifiable {
    let id: UUID
    let data: Data
    let isVideo: Bool
}

struct MediaThumbnailView: View {
    let attachment: MediaAttachment
    let onRemove: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .aspectRatio(9/16, contentMode: .fit)
                .frame(height: 100)
            
            // Removed video handling since we only allow images now
            if let uiImage = UIImage(data: attachment.data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(9/16, contentMode: .fit)
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
            } else {
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                onRemove()
            } label: {
                Circle()
                    .foregroundStyle(.white)
                    .frame(square: 28)
                    .overlay {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white, .red)
                    }
            }
            .offset(x: 10, y: -10)
        }
    }
}

enum FeedbackError: Error, LocalizedError {
    case invalidURL
    case networkError
    case encodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError:
            return "Network error occurred"
        case .encodingError:
            return "Failed to encode data"
        }
    }
}

// Mail Composer View
struct MailComposerView: UIViewControllerRepresentable {
    let feedbackMessage: String
    let mediaAttachments: [MediaAttachment]
    let onDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        
        // Set up the email
        composer.setToRecipients([AppConfiguration.supportEmail]) // Replace with your support email
        composer.setSubject("App Feedback Report")
        
        // Create email body with device info
        let device = UIDevice.current
        let deviceModel = device.model
        let systemVersion = device.systemVersion
//        let deviceName = device.name
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        
        // Get available storage
        let availableStorage = getAvailableStorage()
                
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy, HH:mm"
        let timestamp = dateFormatter.string(from: Date())
        
        let emailBody = """
        \(feedbackMessage)
        
        ---
        Device Information:
        • Model: \(deviceModel)
        • iOS: \(systemVersion)
        • Available Storage: \(availableStorage)
        • App Version: \(appVersion) (\(buildNumber))
        • Time: \(timestamp)
        """
        
        composer.setMessageBody(emailBody, isHTML: false)
        
        // Attach images
        for (index, attachment) in mediaAttachments.enumerated() {
            composer.addAttachmentData(
                attachment.data,
                mimeType: "image/jpeg",
                fileName: "screenshot_\(index + 1).jpg"
            )
        }
        
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss)
    }
    
    private func getAvailableStorage() -> String {
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String)
            let freeSpace = systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber
            if let freeBytes = freeSpace?.int64Value {
                return ByteCountFormatter.string(fromByteCount: freeBytes, countStyle: .file)
            }
        } catch {
            return "Unknown"
        }
        return "Unknown"
    }
    
    private func getMemoryInfo() -> String {
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        let memoryFormatter = ByteCountFormatter()
        memoryFormatter.countStyle = .memory
        return memoryFormatter.string(fromByteCount: Int64(totalMemory))
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onDismiss: () -> Void
        
        init(onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            // Only call onDismiss if the email was sent or saved as draft
            if result == .sent || result == .saved {
                onDismiss()
            } else {
                // Just dismiss the mail composer without calling onDismiss
                controller.dismiss(animated: true)
            }
        }
    }
}

#Preview {
    FeedbackReportView {
        Logger.success("Feedback Sent!")
    }
}

// Keep the ImmediateKeyboardViewModifier extension unchanged
import SwiftUI
import UIKit

struct ImmediateKeyboardViewModifier: ViewModifier {
    @State private var isFirstResponder: Bool = false
    @FocusState private var textFieldFocused: Bool
    
    func body(content: Content) -> some View {
        content
            .focused($textFieldFocused)
            .background(ImmediateKeyboardHelper(isFirstResponder: $isFirstResponder, onKeyboardShown: {
                // Transfer focus to the actual text field after keyboard is shown
                DispatchQueue.main.async {
                    textFieldFocused = true
                }
            }))
            .onAppear {
                isFirstResponder = true
            }
    }
}

extension View {
    func immediateKeyboard() -> some View {
        self.modifier(ImmediateKeyboardViewModifier())
    }
}

struct ImmediateKeyboardHelper: UIViewRepresentable {
    @Binding var isFirstResponder: Bool
    let onKeyboardShown: () -> Void
    
    func makeUIView(context: Context) -> UIView {
        let textView = UITextView()
        textView.isHidden = true
        textView.delegate = context.coordinator
        return textView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if isFirstResponder {
            uiView.becomeFirstResponder()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onKeyboardShown: onKeyboardShown)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        let onKeyboardShown: () -> Void
        
        init(onKeyboardShown: @escaping () -> Void) {
            self.onKeyboardShown = onKeyboardShown
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            // When the hidden text view becomes first responder, trigger the callback
            onKeyboardShown()
        }
    }
}
