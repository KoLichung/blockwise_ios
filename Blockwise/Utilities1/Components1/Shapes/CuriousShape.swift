//
//  CuriousShape.swift
//  Mindspace
//
//  Created by Ivan Sanna on 25/11/24.
//

import SwiftUI

struct CuriousShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.5*width, y: 0))
        path.addCurve(to: CGPoint(x: 0.25*width, y: 0.25*height), control1: CGPoint(x: 0.36193*width, y: 0), control2: CGPoint(x: 0.25*width, y: 0.11193*height))
        path.addCurve(to: CGPoint(x: 0, y: 0.5*height), control1: CGPoint(x: 0.11193*width, y: 0.25*height), control2: CGPoint(x: 0, y: 0.36193*height))
        path.addCurve(to: CGPoint(x: 0.25*width, y: 0.75*height), control1: CGPoint(x: 0, y: 0.63807*height), control2: CGPoint(x: 0.11193*width, y: 0.75*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: height), control1: CGPoint(x: 0.25*width, y: 0.88807*height), control2: CGPoint(x: 0.36193*width, y: height))
        path.addCurve(to: CGPoint(x: 0.75*width, y: 0.75*height), control1: CGPoint(x: 0.63807*width, y: height), control2: CGPoint(x: 0.75*width, y: 0.88807*height))
        path.addCurve(to: CGPoint(x: width, y: 0.5*height), control1: CGPoint(x: 0.88807*width, y: 0.75*height), control2: CGPoint(x: width, y: 0.63807*height))
        path.addCurve(to: CGPoint(x: 0.75*width, y: 0.25*height), control1: CGPoint(x: width, y: 0.36193*height), control2: CGPoint(x: 0.88807*width, y: 0.25*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0), control1: CGPoint(x: 0.75*width, y: 0.11193*height), control2: CGPoint(x: 0.63807*width, y: 0))
        path.closeSubpath()
        return path
    }
}

#Preview {
    CuriousShape()
}
