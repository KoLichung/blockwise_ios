//
//  LimitViewModel.swift
//  Blockwise
//
//  Created by Ivan Sanna on 03/02/26.
//

import Foundation

final class LimitViewModel: ObservableObject {
    @Published var timeRemaining: Int = 60
    @Published var isCompleted: Bool = false
    
    @Published var showDurationPicker: Bool = false

    private var timer: Timer?  // Don't need @Published for this
    
    // Timer functions
    func startTimer() {
        timeRemaining = 60
        isCompleted = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.isCompleted = true
                self.stopTimer()
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stopTimer()  // Clean up when ViewModel is deallocated
    }

}
