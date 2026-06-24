//
//  OBAwardView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 19/06/25.
//

import SwiftUI

struct OBAwardView: View {
    let darkOrange: Color = Color(hex: 0xE65100)
//    let darkOrange: Color = Color.primaryBlue

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text("19 Jun 2025".uppercased())
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
                    .kerning(1.0)
                
                Text("Early Bird")
                    .font(
                        .system(
                            size: 40,
                            weight: .regular,
                            design: .serif
                        )
                    )
            }
            
            Image("balloon-award")
                .resizable()
                .scaledToFit()
                .frame(square: 250)
                .shadow(color: .black.opacity(0.15), radius: 8, x: /*@START_MENU_TOKEN@*/0.0/*@END_MENU_TOKEN@*/, y: 8)
//                .makeReflection(size: 225)
            
            VStack(spacing: 14) {
//                Text("19 Jun 2025".uppercased())
//                    .font(.footnote.weight(.medium))
//                    .foregroundStyle(.secondary)
//                    .kerning(1.0)
//                
//                Text("New Award")
//                    .font(
//                        .system(
//                            size: 34,
//                            weight: .medium,
//                            design: .serif
//                        )
//                    )
                
                Text("Jump start your journey, whoever starts this road never forget itself. You should be proud of yourself. It's going to be memorable.")
                    .multilineTextAlignment(.center)
                    .opacity(0.8)
                    .font(.subheadline)
                    .lineSpacing(6.0)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            GlassButton("Collect Award") {
                
            }
            .foregroundStyle(darkOrange)
            .padding(32)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 22))
            }
            .foregroundStyle(darkOrange)
            .padding(.horizontal)
            .padding(.top, 10)
        }
    }
}

#Preview {
    OBAwardView()
}
