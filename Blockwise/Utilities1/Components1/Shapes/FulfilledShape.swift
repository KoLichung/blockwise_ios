//
//  FulfilledShape.swift
//  Mindspace
//
//  Created by Ivan Sanna on 25/11/24.
//

import SwiftUI

struct FulfilledShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.5*width, y: height))
        path.addLine(to: CGPoint(x: 0.38963*width, y: height))
        path.addCurve(to: CGPoint(x: 0, y: 0.61037*height), control1: CGPoint(x: 0.17444*width, y: height), control2: CGPoint(x: 0, y: 0.82556*height))
        path.addCurve(to: CGPoint(x: 0.04936*width, y: 0.40128*height), control1: CGPoint(x: 0, y: 0.53779*height), control2: CGPoint(x: 0.0169*width, y: 0.4662*height))
        path.addLine(to: CGPoint(x: 0.17417*width, y: 0.15165*height))
        path.addCurve(to: CGPoint(x: 0.36989*width, y: 0.11989*height), control1: CGPoint(x: 0.21148*width, y: 0.07705*height), control2: CGPoint(x: 0.31091*width, y: 0.06091*height))
        path.addLine(to: CGPoint(x: 0.39528*width, y: 0.14528*height))
        path.addCurve(to: CGPoint(x: 0.60472*width, y: 0.14528*height), control1: CGPoint(x: 0.45312*width, y: 0.20312*height), control2: CGPoint(x: 0.54688*width, y: 0.20312*height))
        path.addLine(to: CGPoint(x: 0.63011*width, y: 0.11989*height))
        path.addCurve(to: CGPoint(x: 0.82583*width, y: 0.15165*height), control1: CGPoint(x: 0.68909*width, y: 0.06091*height), control2: CGPoint(x: 0.78852*width, y: 0.07705*height))
        path.addLine(to: CGPoint(x: 0.95064*width, y: 0.40128*height))
        path.addCurve(to: CGPoint(x: width, y: 0.61037*height), control1: CGPoint(x: 0.9831*width, y: 0.4662*height), control2: CGPoint(x: width, y: 0.53779*height))
        path.addCurve(to: CGPoint(x: 0.61037*width, y: height), control1: CGPoint(x: width, y: 0.82556*height), control2: CGPoint(x: 0.82556*width, y: height))
        path.addLine(to: CGPoint(x: 0.5*width, y: height))
        path.closeSubpath()
        return path
    }

}

#Preview {
    FulfilledShape()
}
