//
//  OBTutorial.swift
//  Blockwise
//
//  Created by Ivan Sanna on 07/09/25.
//

import SwiftUI

final class OBTutorialUserViewModel: ObservableObject {
    @Published var path: [Int] = []

    func nextStep(step: Int? = nil) {
        
        if let step {
            // For testing purposes
            let last = path.last ?? 0
            if step > last {
                path.append(contentsOf: (last + 1)...step)
            } else {
                path.append(step)
            }
            // End test
        } else {
            path.append(path.count + 1)
        }
    }
}

struct OBTutorial: View {
    @StateObject private var vm = OBTutorialUserViewModel()
    
    var body: some View {
        NavigationStack(path: $vm.path) {
            OBCongratulations()
                .navigationDestination(
                    for: Int.self,
                    destination: destination
                )
        }
        .environmentObject(vm)
    }
    
    @ViewBuilder
    private func destination(_ step: Int) -> some View {
        Group {
            if step >= 0 && step < navigationSteps.count {
                navigationSteps[step]
            } else {
                AnyView(EmptyView())
            }
        }
        .navigationBarBackButtonHidden()
    }

    // Define your navigation steps as an array
    private let navigationSteps: [AnyView] = [
        AnyView(OBCongratulations()),
        AnyView(OBQuizTutorial()),
        AnyView(OBCreateFirstBlock()),
        AnyView(EmptyView())
    ]

}


#Preview {
    OBTutorial()
}
