//
//  PressureShape.swift
//  Mindspace
//
//  Created by Ivan Sanna on 25/11/24.
//

import SwiftUI

struct PressureShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.83333*width, y: 0))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.25*height))
        path.addLine(to: CGPoint(x: 0.16667*width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: height))
        path.addLine(to: CGPoint(x: width, y: 0.5*height))
        path.closeSubpath()
        return path
    }
}

#Preview {
    PressureShape()
}
