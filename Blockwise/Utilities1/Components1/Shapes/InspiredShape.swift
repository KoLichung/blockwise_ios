//
//  InspiredShape.swift
//  Mindspace
//
//  Created by Ivan Sanna on 25/11/24.
//

import SwiftUI

struct InspiredShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0, y: 0.79775*height))
        path.addLine(to: CGPoint(x: 0, y: 0.5*height))
        path.addCurve(to: CGPoint(x: 0.5*width, y: 0), control1: CGPoint(x: 0, y: 0.22386*height), control2: CGPoint(x: 0.22386*width, y: 0))
        path.addCurve(to: CGPoint(x: width, y: 0.5*height), control1: CGPoint(x: 0.77614*width, y: 0), control2: CGPoint(x: width, y: 0.22386*height))
        path.addLine(to: CGPoint(x: width, y: 0.79775*height))
        path.addCurve(to: CGPoint(x: 0.8191*width, y: 0.90955*height), control1: CGPoint(x: width, y: 0.89067*height), control2: CGPoint(x: 0.90221*width, y: 0.9511*height))
        path.addLine(to: CGPoint(x: 0.77951*width, y: 0.88975*height))
        path.addCurve(to: CGPoint(x: 0.22049*width, y: 0.88975*height), control1: CGPoint(x: 0.60355*width, y: 0.80178*height), control2: CGPoint(x: 0.39645*width, y: 0.80178*height))
        path.addLine(to: CGPoint(x: 0.1809*width, y: 0.90955*height))
        path.addCurve(to: CGPoint(x: 0, y: 0.79775*height), control1: CGPoint(x: 0.09779*width, y: 0.9511*height), control2: CGPoint(x: 0, y: 0.89067*height))
        path.closeSubpath()
        return path
    }

}

#Preview {
    InspiredShape()
}
