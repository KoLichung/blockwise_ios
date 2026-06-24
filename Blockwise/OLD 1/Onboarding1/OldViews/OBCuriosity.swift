//
//  OBCuriosity.swift
//  Blockwise
//
//  Created by Ivan Sanna on 23/06/25.
//

import SwiftUI
import Lottie

struct OBCuriosity: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func action() {
        
    }
}

#Preview {
    OBCuriosity()
        .environmentObject(OBUserViewModel())
}
