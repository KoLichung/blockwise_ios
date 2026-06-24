//
//  OBTutorialStack.swift
//  Blockwise
//
//  Created by Ivan Sanna on 07/01/26.
//

import SwiftUI

struct OBTutorialStack: View {
    @StateObject private var vm = OBTVM()
    
    var body: some View {
        NavigationStack(path: $vm.path) {
            vm.views[0]
                .navigationDestination(
                    for: Int.self,
                    destination: destination
                )
        }
        .overlay(alignment: .top) {
            ProgressBar()
        }
        .environmentObject(vm)
    }
    
    // MARK: - UI components
    @ViewBuilder
    private func destination(_ step: Int) -> some View {
        Group {
            if step >= 0 && step < vm.views.count {
                vm.views[step]
            } else {
                AnyView(EmptyView())
            }
        }
        .navigationBarBackButtonHidden()
    }
        
    @ViewBuilder
    private func ProgressBar() -> some View {
        HStack(spacing: 14) {
            GeometryReader { geo in
                let width = geo.size.width
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 4)
                    .foregroundStyle(.secondary.opacity(0.15))
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 3)
                            .frame(width: width * vm.progressBar)
                    }
                    .padding(.vertical, 10)
            }
        }
        .padding(.horizontal, 32)
        .frame(height: 32)
        .opacity(vm.showProgressBar ? 1 : 0)
        .offset(y: vm.showProgressBar ? 0 : -100)
        .animation(.smooth, value: vm.progressBar)
        .animation(.smooth(duration: 0.5, extraBounce: 0.15), value: vm.showProgressBar)
    }

}

#Preview {
    OBTutorialStack()
}
