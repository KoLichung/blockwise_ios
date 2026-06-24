//
//  ContactService.swift
//  Blockwise
//
//  Created by Ivan Sanna on 12/02/26.
//

import SwiftUI
import MessageUI
import UIKit

// MARK: - ContactService

enum ContactService {
    static let supportEmail = AppConfiguration.supportEmail

    static func canSendMail() -> Bool {
        MFMailComposeViewController.canSendMail()
    }

    static func fallbackToMailApp(subject: String, body: String) {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "mailto:\(supportEmail)?subject=\(subjectEncoded)&body=\(bodyEncoded)"
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    static func defaultBody() -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        let systemVersion = UIDevice.current.systemVersion
        let device = UIDevice.current.model

        return """

        Please describe your issue here.

        ---
        App Version: \(appVersion) (\(build))
        iOS Version: \(systemVersion)
        Device: \(device)
        """
    }
}

// MARK: - MailView

struct MailView: UIViewControllerRepresentable {
    let to: [String]
    let subject: String
    let body: String

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients(to)
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(dismiss: dismiss) }

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        private let dismiss: DismissAction
        init(dismiss: DismissAction) { self.dismiss = dismiss }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            dismiss()
        }
    }
}

// MARK: - ContactSupportButton (drop-in reusable)

struct ContactSupportButton<Label: View>: View {
    var subject: String = "App Support"
    var bodyText: String = ContactService.defaultBody()
    @ViewBuilder var label: () -> Label

    @State private var showComposer = false

    var body: some View {
        Button {
            if ContactService.canSendMail() {
                showComposer = true
            } else {
                ContactService.fallbackToMailApp(subject: subject, body: bodyText)
            }
        } label: {
            label()
        }
        .sheet(isPresented: $showComposer) {
            MailView(to: [ContactService.supportEmail], subject: subject, body: bodyText)
        }
    }
}
