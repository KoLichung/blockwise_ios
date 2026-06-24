//
//  OBT4.swift
//  Blockwise
//
//  Created by Ivan Sanna on 30/12/25.
//

import SwiftUI

struct OBT4: View {
    @EnvironmentObject var vm: OBTVM
    @State private var appearAnimation: Bool = false
    
    @State private var showSelectionPicker: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            Space(height: 18)
            
            VStack(alignment: .leading, spacing: 14) {
                
                Text("Let's start by choosing a distracting app")
                    .font(.grotesk(size: 26, weight: .semibold))
                    .padding(.trailing)
                    .lineSpacing(2.0)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth, value: appearAnimation)

                Text("You can always add more later")
                    .foregroundStyle(.secondary)
                    .font(.grotesk(.subheadline, weight: .regular))
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.1), value: appearAnimation)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

//            Image(.chooseApps)
//                .resizable()
//                .scaledToFit()
//                .padding(.horizontal, 20)
//                .overlay {
//                    LinearGradient(
//                        colors: [
//                            .clear, .clear,
//                            .white
//                        ],
//                        startPoint: .top,
//                        endPoint: .bottom
//                    )
//                }
//                .opacity(appearAnimation ? 1 : 0)
//                .offset(y: appearAnimation ? 0 : 32)
//                .scaleEffect(appearAnimation ? 1 : 0.95)
//                .animation(.smooth.delay(0.2), value: appearAnimation)
//                .frame(maxHeight: .infinity, alignment: .bottom)
//                .offset(y: -24)
            
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .overlay(alignment: .bottom) {
            GeometryReader { geo in
                let height = geo.size.height
                
                Image(.iphoneIg)
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.2), value: appearAnimation)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .offset(y: height * 0.4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }

        }
        .overlay(alignment: .bottom) {
            LinearGradient(
                colors: [
                    .clear, .clear,
                    Color(UIColor.systemBackground),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .frame(height: 300)
        }
        .safeAreaInset(edge: .bottom) {
            GlassButton {
                showSelection()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Choose app")
                        .font(.grotesk(size: 20, weight: .semibold))
                }
            }
            .padding(.horizontal, 32)
            .padding()
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.3), value: appearAnimation)
        }
        .sheet(isPresented: $showSelectionPicker) {
            OBFamilySelection {
                action()
            }
        }
        .onAppear(perform: setup)
    }
    
    private func action() {
        SleepTask.sleep(seconds: 0.01) {
            vm.nextPage(progressBar: 0.9)
        }
    }
    
    private func showSelection() {
        showSelectionPicker = true
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.1) {
            withAnimation {
                appearAnimation = true
            }
        }
    }

}

#Preview {
    OBT4()
        .environmentObject(OBTVM())
}
