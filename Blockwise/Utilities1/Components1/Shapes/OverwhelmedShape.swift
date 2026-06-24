//
//  OverwhelmedShape.swift
//  Mindspace
//
//  Created by Ivan Sanna on 25/11/24.
//

import SwiftUI

struct OverwhelmedShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.25*width, y: 0))
        path.addLine(to: CGPoint(x: 0.5*width, y: 0.125*height))
        path.addLine(to: CGPoint(x: 0.75*width, y: 0))
        path.addLine(to: CGPoint(x: width, y: 0.625*height))
        path.addLine(to: CGPoint(x: 0.75*width, y: 0.75*height))
        path.addLine(to: CGPoint(x: 0.5*width, y: height))
        path.addLine(to: CGPoint(x: 0.25*width, y: 0.75*height))
        path.addLine(to: CGPoint(x: 0, y: 0.625*height))
        path.addLine(to: CGPoint(x: 0.25*width, y: 0))
        path.closeSubpath()
        return path
    }

}

#Preview {
    OverwhelmedShape()
        .aspectRatio(1.0, contentMode: .fit)
        .foregroundStyle(.orange.gradient)
}
