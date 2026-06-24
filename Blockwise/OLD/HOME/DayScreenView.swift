//
//  DayScreenView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 14/12/25.
//

import SwiftUI

struct DayScreenView: View {
    @EnvironmentObject var vm: UserViewModel
    @Environment(\.dismiss) var dismiss
    
    let blocks: FetchedResults<BlockEntity>
    let selection: DateSelection
    
    var screenTime: TimeInterval { blocks.reduce(0) { usage, block in
        usage + block.records
            .filtered(by: selection.date)
            .reduce(0) { $0 + $1.duration }}
    }
    
    var screenTimeGoal: TimeInterval {
        vm.user?.goal(for: selection.date) ?? 3600
    }
    
    var remaining: TimeInterval {
        max(0, screenTimeGoal - screenTime)
    }
    
    var opens: Int {
        blocks.reduce(0) { count, block in
            count + block.records
                .filtered(by: selection.date)
                .count
        }
    }

    var body: some View {
        let progress: CGFloat = min(1, screenTime / max(1, screenTimeGoal))
        
        let isLimit: Bool = progress >= 1
        
//        let color: Color = isLimit ? .orange : .blueAccent
        
        NavigationStack {
            VStack(spacing: 32) {
                VStack(spacing: -16) {
                    
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 38)
                            .foregroundStyle(.gray.opacity(0.15))
                        
                        Circle()
                            .stroke(lineWidth: 2)
                            .foregroundStyle(.gray.opacity(0.15))
                        
                        Circle()
                            .trim(from: progress, to: 1.0)
                            .stroke(style: .init(lineWidth: 30, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .foregroundStyle(.gray)
                    }
                    .frame(square: 100)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 12)
                    .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        date
                            .font(.grotesk(.footnote, weight: .semibold))
                            .kerning(1.0)
                            .foregroundStyle(.secondary)
                        
                        Text(TimeFormatter.display(screenTime, style: .short))
                            .font(.grotesk(size: 48, weight: .semibold))
                            .foregroundStyle(.textC)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Remaining".uppercased())
                            .font(.grotesk(.footnote, weight: .semibold))
                            .kerning(1.0)
                            .foregroundStyle(.secondary)
                        
                        Text(TimeFormatter.display(remaining, style: .short))
                            .font(.grotesk(size: 32, weight: .semibold))
                            .foregroundStyle(.textC)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Opens".uppercased())
                            .font(.grotesk(.footnote, weight: .semibold))
                            .kerning(1.0)
                            .foregroundStyle(.secondary)
                        
                        Text("\(opens)")
                            .font(.grotesk(size: 32, weight: .semibold))
                            .foregroundStyle(.textC)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(32)
            .safeAreaInset(edge: .bottom) {
                GlassButton("Show details", labelColor: .secondary, background: .secondary.opacity(0.15)) {
                    
                }
                .padding(.horizontal, 32)
            }
            .background(Theme.backgroundC, ignoresSafeAreaEdges: .all)
        }
    }
    
    var date: Text {
        Text(
            selection.date.formatted(
                .dateTime
                    .weekday(.abbreviated)
                    .day()
                    .month(.abbreviated)
            )
            .uppercased()
        )
    }
    
}

#Preview("Sheet Preview") {
    Text("Hello, World!")
        .sheet(isPresented: .constant(true)) {
            DayScreenViewPreview()
                .environmentObject(UserViewModel())
                .presentationDragIndicator(.visible)
                .presentationDetents([.height(600)])

        }
}


#Preview {
    DayScreenViewPreview()
        .environmentObject(UserViewModel())
}

private struct DayScreenViewPreview: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BlockEntity.dateCreated, ascending: false)],
        animation: .default
    )
    private var blocks: FetchedResults<BlockEntity>

    var body: some View {
        DayScreenView(blocks: blocks, selection: .init(date: .now))
    }
}

/*
 
 VStack(spacing: 32) {
     ZStack {
         Circle()
             .stroke(lineWidth: 38)
             .foregroundStyle(color.opacity(0.15))
         
         Circle()
             .stroke(lineWidth: 2)
             .foregroundStyle(color.opacity(0.15))
         
         Circle()
             .trim(from: progress, to: 1.0)
             .stroke(style: .init(lineWidth: 30, lineCap: .round))
             .rotationEffect(.degrees(-90))
             .foregroundStyle(color)
         
         Text(TimeFormatter.display(screenTime, style: .short))
             .font(.grotesk(size: 44, weight: .semibold))
     }
     .padding(.horizontal, 56)
     .padding(.bottom, 32)
     
     if (progress > 1) {
         HStack(spacing: 8) {
             Image(systemName: "xmark")
                 .font(.system(size: 16, weight: .semibold))

             Text("Limit exceeded")
                 .font(.grotesk(.body, weight: .semibold))
         }
         .foregroundStyle(Color.red)
         .padding(.horizontal, 12)
         .padding(.vertical, 8)
         .background {
             Capsule(style: .continuous)
                 .foregroundStyle(Color.red.opacity(0.15))
         }
     } else {
         HStack(spacing: 8) {
             let checkSize: CGFloat = 32.0
             
             CheckmarkShape(trimEnd: 1.0)
                 .trim(from: 0.0, to: 1.0)
                 .stroke(
                     Color.blueAccent,
                     style: StrokeStyle(
                         lineWidth: checkSize / 14,
                         lineCap: .round,
                         lineJoin: .round
                     )
                 )
                 .frame(square: checkSize / 2.0)

             Text("Under limit")
                 .font(.grotesk(.body, weight: .semibold))
         }
         .foregroundStyle(Color.blueAccent)
         .padding(.horizontal, 12)
         .padding(.vertical, 8)
         .background {
             Capsule(style: .continuous)
                 .foregroundStyle(Color.blueAccent.opacity(0.15))
         }
     }
     
     Text("Goal: \(TimeFormatter.display(screenTimeGoal, style: .short))")
     
 }
 
 */
