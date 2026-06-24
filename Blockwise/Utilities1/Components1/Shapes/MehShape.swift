//
//  MehShape.swift
//  Mindspace
//
//  Created by Ivan Sanna on 25/11/24.
//

import SwiftUI

struct MehShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.125*width, y: 0.375*height))
        path.addLine(to: CGPoint(x: 0, y: 0.5*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: height), control1: CGPoint(x: 0, y: 0.77614*height), control2: CGPoint(x: 0.22386*width, y: height))
        path.addCurve(to: CGPoint(x: width, y: 0.5*height), control1: CGPoint(x: 0.77614*width, y: height), control2: CGPoint(x: width, y: 0.77614*height))
        path.addLine(to: CGPoint(x: 0.875*width, y: 0.375*height))
        path.addLine(to: CGPoint(x: width, y: 0.25*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0.25*height))
        path.addLine(to: CGPoint(x: 0.125*width, y: 0.375*height))
        path.closeSubpath()
        return path
    }

}

#Preview {
    MehShape()
}
