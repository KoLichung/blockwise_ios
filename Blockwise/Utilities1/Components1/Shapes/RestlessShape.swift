//
//  RestlessShape.swift
//  Mindspace
//
//  Created by Ivan Sanna on 25/11/24.
//

import SwiftUI

struct RestlessShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.75*width, y: height))
        path.addLine(to: CGPoint(x: width, y: 0.5*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0), control1: CGPoint(x: width, y: 0.22386*height), control2: CGPoint(x: 0.77614*width, y: 0))
        path.addCurve(to: CGPoint(x: 0, y: 0.5*height), control1: CGPoint(x: 0.22386*width, y: 0), control2: CGPoint(x: 0, y: 0.22386*height))
        path.addLine(to: CGPoint(x: 0.25*width, y: height))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.625*height))
        path.addLine(to: CGPoint(x: 0.75*width, y: height))
        path.closeSubpath()
        return path
    }

}

#Preview {
    RestlessShape()
}
