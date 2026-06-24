//
//  PanickedShape.swift
//  Mindspace
//
//  Created by Ivan Sanna on 25/11/24.
//

import SwiftUI

struct PanickedShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.375*width, y: 0.25*height))
        path.addLine(to: CGPoint(x: 0.4375*width, y: 0.125*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0))
        path.addLine(to: CGPoint(x: 0.5625*width, y: 0.125*height))
        path.addLine(to: CGPoint(x: 0.625*width, y: 0.25*height))
        path.addLine(to: CGPoint(x: 0.875*width, y: 0.125*height))
        path.addLine(to: CGPoint(x: width, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.87201*width, y: 0.8735*height))
        path.addLine(to: CGPoint(x: 0.625*width, y: 0.75*height))
        path.addLine(to: CGPoint(x: 0.5625*width, y: 0.875*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: height))
        path.addLine(to: CGPoint(x: 0.4375*width, y: 0.875*height))
        path.addLine(to: CGPoint(x: 0.375*width, y: 0.75*height))
        path.addLine(to: CGPoint(x: 0.125*width, y: 0.875*height))
        path.addLine(to: CGPoint(x: 0, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0.125*width, y: 0.125*height))
        path.addLine(to: CGPoint(x: 0.375*width, y: 0.25*height))
        path.closeSubpath()
        return path
    }

}

#Preview {
    PanickedShape()
}
