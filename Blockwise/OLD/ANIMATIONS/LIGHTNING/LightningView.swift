//
//  LightningView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 17/12/25.
//

import SwiftUI

struct LightningView: View {
    @State private var lightning = Lightning()
    @Binding var trigger: Bool

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0 / 60.0)) { timeline in
            Canvas { context, size in
                lightning.update(date: timeline.date, in: size)

                let fullScreen = Path(CGRect(origin: .zero, size: size))
                context.fill(fullScreen, with: .color(.white.opacity(lightning.flashOpacity)))

                for _ in 0..<2 {
                    for bolt in lightning.bolts {
                        var path = Path()
                        path.addLines(bolt.points)
                        context.stroke(path, with: .color(.white), lineWidth: bolt.width)
                    }
                    context.addFilter(.blur(radius: 5))
                }
            }
        }
        .ignoresSafeArea()
        .onChange(of: trigger) {
            lightning.strike()
        }
    }
}

#Preview {
    LigthiningViewPreview()
}

private struct LigthiningViewPreview: View {
    @State private var trigger: Bool = false
    
    var body: some View {
        LightningView(trigger: $trigger)
            .onTapGesture {
                trigger.toggle()
            }
            .background(.black, ignoresSafeAreaEdges: .all)
    }
}
