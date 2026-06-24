//
//  UnmotivatedShape.swift
//  Mindspace
//
//  Created by Ivan Sanna on 25/11/24.
//

import SwiftUI

struct UnmotivatedShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0, y: 0.5*height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: 0.3675*width, y: 0.77031*height))
        path.addCurve(to: CGPoint(x: 0.6325*width, y: 0.77031*height), control1: CGPoint(x: 0.44857*width, y: 0.71964*height), control2: CGPoint(x: 0.55143*width, y: 0.71964*height))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: width, y: 0.5*height))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: 0.6325*width, y: 0.22969*height))
        path.addCurve(to: CGPoint(x: 0.3675*width, y: 0.22969*height), control1: CGPoint(x: 0.55143*width, y: 0.28036*height), control2: CGPoint(x: 0.44857*width, y: 0.28036*height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0.5*height))
        path.closeSubpath()
        return path
    }

}

#Preview {
    UnmotivatedShape()
}
