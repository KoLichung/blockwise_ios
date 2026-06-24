//
//  OBW1.swift
//  Blockwise
//
//  Created by Ivan Sanna on 29/12/25.
//

import SwiftUI

struct OBW1: View {
    @EnvironmentObject var vm: OBVM
    @State private var appearAnimation: Bool = false
        
    var body: some View {
        VStack(spacing: 32) {
            Text("Stress Less")
                .font(.grotesk(size: 32, weight: .semibold))
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            GlassButton("Continue") {
                vm.nextPage()
            }
            .padding(.horizontal, 32)
            .padding(.vertical)
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.3), value: appearAnimation)
        }
        .onAppear(perform: setup)
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.1) {
            withAnimation {
                appearAnimation = true
            }
        }
    }
}

#Preview {
    OBW1()
        .environmentObject(OBVM())
}

/*
 struct OBW1: View {
     @EnvironmentObject var vm: OBVM
     @State private var appearAnimation: Bool = false
     
     let columns: [GridItem] = .init(repeating: GridItem(spacing: 0), count: 2)
     
     var body: some View {
         VStack(spacing: 32) {
             Group {
                 Text("What do") +
                 Text(" successful ").foregroundStyle(Color.blueAccent) +
                 Text("people have in common?")
             }
             .font(.grotesk(size: 26, weight: .semibold))
             .multilineTextAlignment(.center)
             .frame(height: 120)
             .opacity(appearAnimation ? 1 : 0)
             .offset(y: appearAnimation ? 0 : 32)
             .scaleEffect(appearAnimation ? 1 : 0.95)
             .animation(.smooth, value: appearAnimation)
             
             LazyVGrid(columns: columns, spacing: 18) {
                 Image(.bezos)
                     .resizable()
                     .scaledToFit()
                     .grayscale(1.0)
                     .clipShape(Circle())
                     .frame(square: 128)
                     .overlay {
                         Circle()
                             .stroke(lineWidth: 2.0)
                             .foregroundStyle(.secondary.opacity(0.15))
                     }
                 
                 Image(.nvidia)
                     .resizable()
                     .scaledToFit()
                     .grayscale(1.0)
                     .clipShape(Circle())
                     .frame(square: 128)
                     .overlay {
                         Circle()
                             .stroke(lineWidth: 2.0)
                             .foregroundStyle(.secondary.opacity(0.15))
                     }

                 Image(.hormozi)
                     .resizable()
                     .scaledToFit()
                     .grayscale(1.0)
                     .clipShape(Circle())
                     .frame(square: 128)
                     .overlay {
                         Circle()
                             .stroke(lineWidth: 2.0)
                             .foregroundStyle(.secondary.opacity(0.15))
                     }

                 Image(.emma)
                     .resizable()
                     .scaledToFit()
                     .grayscale(1.0)
                     .clipShape(Circle())
                     .frame(square: 128)
                     .overlay {
                         Circle()
                             .stroke(lineWidth: 2.0)
                             .foregroundStyle(.secondary.opacity(0.15))
                     }

                 Image(.jobs)
                     .resizable()
                     .scaledToFit()
                     .grayscale(1.0)
                     .clipShape(Circle())
                     .frame(square: 128)
                     .overlay {
                         Circle()
                             .stroke(lineWidth: 2.0)
                             .foregroundStyle(.secondary.opacity(0.15))
                     }

                 Image(.oprah)
                     .resizable()
                     .scaledToFit()
                     .grayscale(1.0)
                     .clipShape(Circle())
                     .frame(square: 128)
                     .overlay {
                         Circle()
                             .stroke(lineWidth: 2.0)
                             .foregroundStyle(.secondary.opacity(0.15))
                     }

             }
             .opacity(appearAnimation ? 1 : 0)
             .offset(y: appearAnimation ? 0 : 32)
             .scaleEffect(appearAnimation ? 1 : 0.95)
             .animation(.smooth.delay(0.1), value: appearAnimation)
         }
         .padding(32)
         .frame(maxWidth: .infinity, maxHeight: .infinity)
         .safeAreaInset(edge: .bottom) {
             GlassButton("Continue") {
                 vm.nextPage()
             }
             .padding(.horizontal, 32)
             .padding(.vertical)
             .opacity(appearAnimation ? 1 : 0)
             .offset(y: appearAnimation ? 0 : 32)
             .scaleEffect(appearAnimation ? 1 : 0.95)
             .animation(.smooth.delay(0.3), value: appearAnimation)
         }
         .onAppear(perform: setup)
     }
     
     private func setup() {
         SleepTask.sleep(seconds: 0.1) {
             withAnimation {
                 appearAnimation = true
             }
         }
     }
 }

 */
