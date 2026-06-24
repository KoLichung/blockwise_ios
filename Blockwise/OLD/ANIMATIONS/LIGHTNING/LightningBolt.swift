//
//  LightningBolt.swift
//  Blockwise
//
//  Created by Ivan Sanna on 16/12/25.
//

import SwiftUI

class LightningBolt {
    var points = [CGPoint]()
    var width: Double
    var angle: Double
    
    init(start: CGPoint, width: Double, angle: Double) {
        points.append(start)
        self.width = width
        self.angle = angle
    }
}
