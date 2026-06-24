//
//  ConfusedShape.swift
//  Mindspace
//
//  Created by Ivan Sanna on 25/11/24.
//

import SwiftUI

struct ConfusedShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.625*width, y: 0))
        path.addLine(to: CGPoint(x: 0.375*width, y: 0.25*height))
        path.addLine(to: CGPoint(x: 0.01172*width, y: 0.00781*height))
        path.addLine(to: CGPoint(x: 0, y: 0.75*height))
        path.addLine(to: CGPoint(x: 0.375*width, y: height))
        path.addLine(to: CGPoint(x: 0.625*width, y: 0.75*height))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: width, y: 0.25*height))
        path.addLine(to: CGPoint(x: 0.625*width, y: 0))
        path.closeSubpath()
        return path
    }

}

#Preview {
    ConfusedShape()
}
