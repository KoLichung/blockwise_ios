//
//  DeleteReasonView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 04/02/26.
//

import SwiftUI

struct DeleteReasonView: View {
    @AppStorage(AppStorageKeys.User.name.key) var name: String = ""
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedReason: DeleteReason?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(Array(DeleteReason.allCases.enumerated()), id: \.offset) { (index, reason) in
                        ReasonRow(reason: reason)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
            .navigationTitle("What's going on, \(name)?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(.primary)
                }
            }
            .navigationDestination(item: $selectedReason) { reason in
                DeleteOptionsView(selectedReason: reason)
            }
        }
    }
    
    @ViewBuilder
    private func ReasonRow(reason: DeleteReason) -> some View {
        Button {
            selectedReason = reason
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Text(reason.rawValue)
                    .font(.grotesk(.title3, weight: .semibold))
                    .foregroundStyle(.textC)
            }
            .padding(.trailing, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .trailing) {
                Image(systemName: "chevron.right")
                    .font(.system(.subheadline, weight: .semibold))
                    .foregroundStyle(.secondary.opacity(0.5))
            }
            .padding(24)
            .background {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .foregroundStyle(Theme.foregroundC)
                    .border(cornerRadius: 28)
            }
        }
        .tint(.primary)

    }
}

#Preview {
    DeleteReasonView()
}

enum DeleteReason: String, CaseIterable {
    case dontNeedAnymore = "I don't need it anymore"
    case wrongLimit = "I set the wrong limit"
    case removeTemporarly = "I'll remove it temporarly"
    case bored = "I'm feeling bored"
}
