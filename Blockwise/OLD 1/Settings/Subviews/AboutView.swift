//
//  AboutView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 10/04/25.
//

import SwiftUI

struct AboutView: View {
    @State private var appearAnimation: Bool = false
    
    let iconSize: CGFloat = 90.0
    
    var body: some View {
        List {
            Section {
                VStack(spacing: 24) {
                    Image(AppConfiguration.appIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(square: iconSize)
                        .clipShape(.rect(cornerRadius: iconSize / 4.0, style: .continuous))
                        .frame(maxWidth: .infinity, alignment: .center)

                    VStack(spacing: 8) {
                        Text("\(AppConfiguration.name) for iOS")
                            .font(.grotesk(.title2, weight: .regular))
                            
                        Text("Version \(AppConfiguration.Info.version)")
                            .font(.grotesk(.subheadline, weight: .regular))
                            .opacity(0.65)
                    }
                }
                .padding(.vertical, 32)
            }
            .listRowBackground(Color.clear)

            
            Section {
                if let url = URL(string: AppConfiguration.termsURL) {
                    Link(destination: url) {
                        HStack(spacing: 14) {
                            Image(systemName: "signature")
                                .frame(width: 32)
                            
                            Text("Terms of Service")
                                .font(.grotesk())
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right")
                                .font(.subheadline.weight(.medium))
                                .opacity(0.5)
                        }
                    }
                }
                
                if let url = URL(string: AppConfiguration.privacyURL) {
                    Link(destination: url) {
                        HStack(spacing: 14) {
                            Image(systemName: "hand.raised")
                                .frame(width: 32)
                            
                            Text("Privacy Policy")
                                .font(.grotesk())
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right")
                                .font(.subheadline.weight(.medium))
                                .opacity(0.5)
                        }
                    }
                }

            }
            .listRowBackground(Theme.foregroundC)
            
            Section {
                
                NavigationLink {
                    UserLibrariesView()
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "book")
                            .frame(width: 32)
                        
                        Text("Used Libraries")
                            .font(.grotesk())
                    }
                }

            }
            .listRowBackground(Theme.foregroundC)
        }
        .scrollContentBackground(.hidden)
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        .onAppear(perform: setup)
        .tint(.primary)
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.15) {
            withAnimation() {
                appearAnimation = true
            }
        }
    }
    
    @ViewBuilder
    private func UserLibrariesView() -> some View {
        List {
            ForEach(Library.libraries) { library in
                NavigationLink {
                    ScrollView {
                        Text(library.description)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding()
                    }
                    .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
                    .navigationTitle(library.packageName)
                    .navigationBarTitleDisplayMode(.inline)
                } label: {
                    Text(library.packageName)
                }
            }
            .listRowBackground(Theme.foregroundC)
        }
        .scrollContentBackground(.hidden)
        .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        .navigationTitle("Used Libraries")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}

private struct Library: Identifiable {
    let id = UUID()
    
    let packageName: String
    let description: String
    
    static let libraries: [Library] = [
        Library(
            packageName: "RevenueCat",
            description: """
MIT License

Copyright (c) 2017 Jacob Eiting

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""
        ),
        
        Library(
            packageName: "SuperwallKit",
            description: """
MIT License

Copyright (c) 2025 Nest22

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""
        )
    ]
}
