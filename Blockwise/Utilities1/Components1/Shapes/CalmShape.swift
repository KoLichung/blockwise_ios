//
//  CalmShape.swift
//  Mindspace
//
//  Created by Ivan Sanna on 25/11/24.
//

import SwiftUI

struct CalmShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.08839*width, y: 0.41161*height))
        path.addLine(to: CGPoint(x: 0.41161*width, y: 0.08839*height))
        path.addCurve(to: CGPoint(x: 0.58839*width, y: 0.08839*height), control1: CGPoint(x: 0.46043*width, y: 0.03957*height), control2: CGPoint(x: 0.53957*width, y: 0.03957*height))
        path.addLine(to: CGPoint(x: 0.91161*width, y: 0.41161*height))
        path.addCurve(to: CGPoint(x: 0.91161*width, y: 0.58839*height), control1: CGPoint(x: 0.96043*width, y: 0.46043*height), control2: CGPoint(x: 0.96043*width, y: 0.53957*height))
        path.addLine(to: CGPoint(x: 0.58839*width, y: 0.91161*height))
        path.addCurve(to: CGPoint(x: 0.41161*width, y: 0.91161*height), control1: CGPoint(x: 0.53957*width, y: 0.96043*height), control2: CGPoint(x: 0.46043*width, y: 0.96043*height))
        path.addLine(to: CGPoint(x: 0.08839*width, y: 0.58839*height))
        path.addCurve(to: CGPoint(x: 0.08839*width, y: 0.41161*height), control1: CGPoint(x: 0.03957*width, y: 0.53957*height), control2: CGPoint(x: 0.03957*width, y: 0.46043*height))
        path.closeSubpath()
        return path
    }

}

#Preview {
    CalmShape()
}
