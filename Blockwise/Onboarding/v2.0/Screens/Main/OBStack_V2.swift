//
//  OBStack_V2.swift
//  Blockwise
//
//  Created by Ivan Sanna on 18/01/26.
//

import SwiftUI

struct OBStack_V2: View {
    @StateObject private var vm = OBVM_V2()
    
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
        .overlay(alignment: .top) {
            ProgressBarTwo()
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
            
            Button {
                vm.previousPage()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .bold))
                    .opacity(0.5)
                    .clipShape(.rect)
                    .frame(width: 32, alignment: .center)
            }
            .tint(.gray)
            
            GeometryReader { geo in
                let width = geo.size.width
                
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.secondary.opacity(0.15))
                    .frame(height: 12)
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 12)
                            .overlay(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(height: 6)
                                    .padding(.leading)
                                    .padding(.trailing, 6)
                                    .brightness(0.15)
                                    .opacity(0.5)
                                    .offset(y: -1)
                            }
                            .foregroundStyle(.skyBlue)
                            .frame(width: width * vm.progressBarValue)
                    }
                    .padding(.vertical, 10)
            }
        }
        .padding(.trailing, 32)
        .padding(.leading)
        .frame(height: 32)
        .opacity(vm.showProgressBar ? 1 : 0)
        .offset(y: vm.showProgressBar ? 0 : -100)
        .animation(.smooth, value: vm.progressBarValue)
        .animation(.smooth(duration: 0.5, extraBounce: 0.15), value: vm.showProgressBar)
    }
    
    @ViewBuilder
    private func ProgressBarTwo() -> some View {
        HStack(spacing: 14) {
            
            Button {
                vm.previousPage()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .bold))
                    .opacity(0.5)
                    .clipShape(.rect)
                    .frame(width: 32, alignment: .center)
            }
            .tint(.gray)
            
            GeometryReader { geo in
                let width = geo.size.width
                
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.secondary.opacity(0.15))
                    .frame(height: 12)
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 12)
                            .overlay(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(height: 6)
                                    .padding(.leading)
                                    .padding(.trailing, 6)
                                    .brightness(0.15)
                                    .opacity(0.5)
                                    .offset(y: -1)
                            }
                            .foregroundStyle(.skyBlue)
                            .frame(width: width * vm.progressBarValueTwo)
                    }
                    .padding(.vertical, 10)
            }
        }
        .padding(.trailing, 32)
        .padding(.leading)
        .frame(height: 32)
        .opacity(vm.showProgressBarTwo ? 1 : 0)
        .offset(y: vm.showProgressBarTwo ? 0 : -100)
        .animation(.smooth, value: vm.progressBarValueTwo)
        .animation(.smooth(duration: 0.5, extraBounce: 0.15), value: vm.showProgressBarTwo)
    }

}

#Preview {
    OBStack_V2()
}
