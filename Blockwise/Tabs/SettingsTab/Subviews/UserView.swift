//
//  UserView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 12/02/26.
//

import SwiftUI
import RevenueCatUI

struct UserView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userViewModel: UserViewModel
    
    @State private var showCustomerCenter: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    HStack(spacing: 14) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 56))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.secondary)
                            .frame(square: 56)
                        
                        if let user = userViewModel.user, let dateCreated = user.dateCreated {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(user.name ?? "")")
                                    .font(.grotesk(.title3, weight: .medium))
                                
                                Text("Joined \(dateCreated.formatted(components: [.monthFull, .day, .year]))")
                                    .font(.grotesk(.footnote, weight: .medium))
                                    .foregroundStyle(Color.secondary)
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("unknown")
                                    .font(.grotesk(.title3, weight: .medium))
                                
                                Text("there was an error loading your profile")
                                    .font(.grotesk(.footnote, weight: .medium))
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .foregroundStyle(Theme.foregroundC)
                            .border(cornerRadius: 32)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Button {
                            showCustomerCenter = true
                        } label: {
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .frame(height: 78)
                                .foregroundStyle(Theme.foregroundC)
                                .border(cornerRadius: 26)
                                .overlay {
                                    HStack {
                                        Text("Customer Center")
                                            .font(.grotesk(.title2, weight: .semibold))
                                            .foregroundStyle(.textC)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(.subheadline, weight: .semibold))
                                            .foregroundStyle(.secondary.opacity(0.5))
                                    }
                                    .padding(.horizontal, 24)
                                }
                        }
                        .tint(.primary)
                        
                        Text("Manage your subscription")
                            .font(.grotesk(.footnote, weight: .regular))
                            .foregroundStyle(.secondary.opacity(0.8))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 20)
                            .lineSpacing(4.0)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
            .presentCustomerCenter(isPresented: $showCustomerCenter)
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
    UserView()
        .environmentObject(UserViewModel())
}
