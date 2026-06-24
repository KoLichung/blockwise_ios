//
//  LonelyShape.swift
//  Mindspace
//
//  Created by Ivan Sanna on 25/11/24.
//

import SwiftUI

struct LonelyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.5*width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: 0, y: 0.42857*height))
        path.addCurve(to: CGPoint(x: 0.39182*width, y: 0.16226*height), control1: CGPoint(x: 0.16031*width, y: 0.39422*height), control2: CGPoint(x: 0.30088*width, y: 0.29868*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0))
        path.addLine(to: CGPoint(x: 0.60818*width, y: 0.16226*height))
        path.addCurve(to: CGPoint(x: width, y: 0.42857*height), control1: CGPoint(x: 0.69912*width, y: 0.29868*height), control2: CGPoint(x: 0.83969*width, y: 0.39422*height))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0.5*width, y: height))
        path.closeSubpath()
        return path
    }

}

#Preview {
    LonelyShape()
}
