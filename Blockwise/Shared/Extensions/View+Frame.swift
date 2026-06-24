//
//  Frame+View.swift
//  Blockwise
//
//  Created by Ivan Sanna on 01/12/24.
//

import SwiftUI

extension View {
    func frame(square: CGFloat) -> some View {
        self.frame(width: square, height: square)
    }
}
