//
//  BlankSpace.swift
//  Blockwise
//
//  Created by Ivan Sanna on 14/05/25.
//

import SwiftUI

struct Space: View {
    let height: CGFloat
    let color: Color
    
    init(height: CGFloat, color: Color = .clear) {
        self.height = height
        self.color = color
    }
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: height)
    }
}

#Preview {
    Space(height: 50, color: .green)
}
