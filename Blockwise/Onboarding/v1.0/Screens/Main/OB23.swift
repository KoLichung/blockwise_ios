//
//  OB23.swift
//  Blockwise
//
//  Created by Ivan Sanna on 24/11/25.
//

import SwiftUI
import SuperwallKit

struct OB23: View {
    @EnvironmentObject var vm: OBVM
    @State private var appearAnimation: Bool = false

    var body: some View {
        VStack(spacing: 32) {
            Space(height: 2)
            
//            Image(.mascotteAndStairs)
//                .resizable()
//                .scaledToFit()
//                .padding(.horizontal, 8)
//                .opacity(appearAnimation ? 1 : 0)
//                .offset(y: appearAnimation ? 0 : 32)
//                .scaleEffect(appearAnimation ? 1 : 0.95)
//                .animation(.smooth, value: appearAnimation)
            
            VStack(spacing: 14) {
                Text("Changing habits isn’t easy.")
                    .font(.grotesk(size: 24, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2.0)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 32)
                    .scaleEffect(appearAnimation ? 1 : 0.95)
                    .animation(.smooth.delay(0.1), value: appearAnimation)
                
                Group {
                    Text("And you've already taken") +
                    Text(" the hardest step.").foregroundStyle(Color.blueAccent)
                }
                .font(.grotesk(size: 26, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineSpacing(2.0)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 0.95)
                .animation(.smooth.delay(0.2), value: appearAnimation)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(32)
        .safeAreaInset(edge: .bottom) {
            GlassButton("Start Now") {
                action()
            }
            .padding(.horizontal, 32)
            .padding()
            .opacity(appearAnimation ? 1 : 0)
            .offset(y: appearAnimation ? 0 : 32)
            .scaleEffect(appearAnimation ? 1 : 0.95)
            .animation(.smooth.delay(0.3), value: appearAnimation)
        }
        .background(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .foregroundStyle(Color.blueAccent.opacity(0.15))
                .overlay {
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .stroke(lineWidth: 2.0)
                        .foregroundStyle(Color.blueAccent.opacity(0.5))
                }
                .frame(height: 180)
                .overlay(alignment: .top) {
                    HStack(spacing: 32) {
                        ZStack {
                            Star()
                                .scaledToFit()
                                .frame(square: 16)
                                .phaseAnimator([true, false]) { view, phase in
                                    view
                                        .opacity(phase ? 1 : 0.5)
                                } animation: { _ in
                                        .easeInOut(duration: 0.25).delay(1.0)
                                }
                            
                            Star()
                                .scaledToFit()
                                .frame(square: 12)
                                .offset(x: 12, y: 24)
                                .phaseAnimator([false, true]) { view, phase in
                                    view
                                        .opacity(phase ? 1 : 0.5)
                                } animation: { _ in
                                        .easeInOut(duration: 0.25).delay(2.0)
                                }
                            
                            Star()
                                .scaledToFit()
                                .frame(square: 12)
                                .offset(x: 8, y: -24)
                                .phaseAnimator([false, true]) { view, phase in
                                    view
                                        .opacity(phase ? 1 : 0.5)
                                } animation: { _ in
                                        .easeInOut(duration: 0.25).delay(3.0)
                                }
                        }
                        .foregroundStyle(Color.blueAccent)
                        
                        Text("**We’re proud of you** for being here.")
                            .font(.grotesk(size: 17, weight: .regular))
                            .foregroundStyle(Color.blueAccent)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2.0)
                        
                        ZStack {
                            Star()
                                .scaledToFit()
                                .frame(square: 16)
                                .offset(x: -12, y: 24)
                                .phaseAnimator([true, false]) { view, phase in
                                    view
                                        .opacity(phase ? 1 : 0.5)
                                } animation: { _ in
                                        .easeInOut(duration: 0.25).delay(1.0)
                                }
                            
                            Star()
                                .scaledToFit()
                                .frame(square: 12)
                                .phaseAnimator([false, true]) { view, phase in
                                    view
                                        .opacity(phase ? 1 : 0.5)
                                } animation: { _ in
                                        .easeInOut(duration: 0.25).delay(2.0)
                                }
                            
                            Star()
                                .scaledToFit()
                                .frame(square: 12)
                                .offset(x: -8, y: -24)
                                .phaseAnimator([false, true]) { view, phase in
                                    view
                                        .opacity(phase ? 1 : 0.5)
                                } animation: { _ in
                                        .easeInOut(duration: 0.25).delay(3.0)
                                }
                        }
                        .foregroundStyle(Color.blueAccent)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 32)
                }
                .padding(.horizontal, 28)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 32)
                .scaleEffect(appearAnimation ? 1 : 1.15)
                .animation(.smooth.delay(0.4), value: appearAnimation)
        }
        .onAppear(perform: setup)
    }
    
    private func setup() {
        SleepTask.sleep(seconds: 0.1) {
            appearAnimation = true
        }
    }
    
    private func action() {
        vm.nextPage()
    }
}

#Preview {
    OB23()
        .environmentObject(OBVM())
}

struct Star: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.44501*width, y: 0.02719*height))
        path.addCurve(to: CGPoint(x: 0.52317*width, y: 0.02719*height), control1: CGPoint(x: 0.45844*width, y: -0.00908*height), control2: CGPoint(x: 0.50975*width, y: -0.00908*height))
        path.addLine(to: CGPoint(x: 0.55623*width, y: 0.11654*height))
        path.addCurve(to: CGPoint(x: 0.85164*width, y: 0.41195*height), control1: CGPoint(x: 0.60687*width, y: 0.2534*height), control2: CGPoint(x: 0.71478*width, y: 0.36131*height))
        path.addLine(to: CGPoint(x: 0.94099*width, y: 0.44501*height))
        path.addCurve(to: CGPoint(x: 0.94099*width, y: 0.52317*height), control1: CGPoint(x: 0.97726*width, y: 0.45844*height), control2: CGPoint(x: 0.97726*width, y: 0.50975*height))
        path.addLine(to: CGPoint(x: 0.85164*width, y: 0.55623*height))
        path.addCurve(to: CGPoint(x: 0.55623*width, y: 0.85164*height), control1: CGPoint(x: 0.71478*width, y: 0.60687*height), control2: CGPoint(x: 0.60687*width, y: 0.71478*height))
        path.addLine(to: CGPoint(x: 0.52317*width, y: 0.94099*height))
        path.addCurve(to: CGPoint(x: 0.44501*width, y: 0.94099*height), control1: CGPoint(x: 0.50975*width, y: 0.97726*height), control2: CGPoint(x: 0.45844*width, y: 0.97726*height))
        path.addLine(to: CGPoint(x: 0.41195*width, y: 0.85164*height))
        path.addCurve(to: CGPoint(x: 0.11654*width, y: 0.55623*height), control1: CGPoint(x: 0.36131*width, y: 0.71478*height), control2: CGPoint(x: 0.2534*width, y: 0.60687*height))
        path.addLine(to: CGPoint(x: 0.02719*width, y: 0.52317*height))
        path.addCurve(to: CGPoint(x: 0.02719*width, y: 0.44501*height), control1: CGPoint(x: -0.00908*width, y: 0.50975*height), control2: CGPoint(x: -0.00908*width, y: 0.45844*height))
        path.addLine(to: CGPoint(x: 0.11654*width, y: 0.41195*height))
        path.addCurve(to: CGPoint(x: 0.41195*width, y: 0.11654*height), control1: CGPoint(x: 0.2534*width, y: 0.36131*height), control2: CGPoint(x: 0.36131*width, y: 0.2534*height))
        path.addLine(to: CGPoint(x: 0.44501*width, y: 0.02719*height))
        path.closeSubpath()
        return path
    }
}


/*
 
 import SwiftUI
 import FamilyControls
 import ManagedSettings

 struct OB23: View {
     @EnvironmentObject var vm: OBVM
     @State private var appearAnimation: Bool = false
     
     @State private var tokenOne: ApplicationToken? = nil
     @State private var tokenTwo: ApplicationToken? = nil
     @State private var tokenThree: ApplicationToken? = nil
     
     @State private var showFirstAppPicker: Bool = false
     @State private var showSecondAppPicker: Bool = false
     @State private var showThirdAppPicker: Bool = false
     
     var body: some View {
         VStack(spacing: 32) {
             Space(height: 18)
             
             VStack(spacing: 14) {
                 Text("Block up to 3 distracting apps")
                     .font(.grotesk(size: 28, weight: .semibold))
                     .multilineTextAlignment(.center)
                     .lineSpacing(2.0)
                 
                 Text("You can always change this later")
                     .padding(.horizontal)
                     .font(.grotesk(.subheadline, weight: .regular))
                     .foregroundStyle(.secondary)
                     .multilineTextAlignment(.center)
                     .lineSpacing(2.0)
             }
             .opacity(appearAnimation ? 1 : 0)
             .offset(y: appearAnimation ? 0 : 32)
             .scaleEffect(appearAnimation ? 1 : 0.95)
             .animation(.smooth, value: appearAnimation)
             
             Space(height: 18)
             
             HStack(spacing: 0) {
                 Button {
                     showFirstAppPicker = true
                 } label: {
                     VStack(spacing: 10) {
                         RoundedRectangle(cornerRadius: 18, style: .continuous)
                             .stroke(lineWidth: 2.0)
                             .foregroundStyle(.secondary.opacity(0.25))
                             .frame(square: 64)
                             .overlay {
                                 if let token = tokenOne {
                                     Label(token)
                                         .labelStyle(.iconOnly)
                                         .scaleEffect(2.0)
                                 } else {
                                     Image(systemName: "plus")
                                         .font(.system(size: 28, weight: .light))
                                         .foregroundStyle(.secondary.opacity(0.5))
                                 }
                             }
                         
                         Text("1st app")
                             .font(.grotesk(size: 15, weight: .regular))
                             .foregroundStyle(.secondary)
                     }
                     .frame(maxWidth: .infinity)
                 }
                 
                 Button {
                     showSecondAppPicker = true
                 } label: {
                     VStack(spacing: 10) {
                         RoundedRectangle(cornerRadius: 18, style: .continuous)
                             .stroke(lineWidth: 2.0)
                             .foregroundStyle(.secondary.opacity(0.25))
                             .frame(square: 64)
                             .overlay {
                                 if let token = tokenTwo {
                                     Label(token)
                                         .labelStyle(.iconOnly)
                                         .scaleEffect(2.0)
                                 } else {
                                     Image(systemName: "plus")
                                         .font(.system(size: 28, weight: .light))
                                         .foregroundStyle(.secondary.opacity(0.5))
                                 }
                             }
                         
                         Text("2nd app")
                             .font(.grotesk(size: 15, weight: .regular))
                             .foregroundStyle(.secondary)
                     }
                     .frame(maxWidth: .infinity)
                 }

                 Button {
                     showThirdAppPicker = true
                 } label: {
                     VStack(spacing: 10) {
                         RoundedRectangle(cornerRadius: 18, style: .continuous)
                             .stroke(lineWidth: 2.0)
                             .foregroundStyle(.secondary.opacity(0.25))
                             .frame(square: 64)
                             .overlay {
                                 if let token = tokenThree {
                                     Label(token)
                                         .labelStyle(.iconOnly)
                                         .scaleEffect(2.0)
                                 } else {
                                     Image(systemName: "plus")
                                         .font(.system(size: 28, weight: .light))
                                         .foregroundStyle(.secondary.opacity(0.5))
                                 }
                             }
                         
                         Text("3rd app")
                             .font(.grotesk(size: 15, weight: .regular))
                             .foregroundStyle(.secondary)
                     }
                     .frame(maxWidth: .infinity)
                 }

             }
             .tint(.primary)
             .padding(.horizontal)
             .opacity(appearAnimation ? 1 : 0)
             .offset(y: appearAnimation ? 0 : 32)
             .scaleEffect(appearAnimation ? 1 : 0.95)
             .animation(.smooth.delay(0.1), value: appearAnimation)
         }
         .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
         .padding(32)
         .overlay(alignment: .topTrailing) {
             Button {
                 vm.nextPage()
             } label: {
                 Text("Skip")
                     .font(.grotesk(.body, weight: .regular))
                     .foregroundStyle(.secondary)
             }
             .padding(.top, 8)
             .padding(.horizontal, 20)
             .tint(.primary)
         }
         .safeAreaInset(edge: .bottom) {
             VStack(spacing: 32) {
                 HStack(spacing: 10) {
                     Bubble(direction: .right,
                            fill: Color.primaryBlue.opacity(0.15),
                            stroke: Color.primaryBlue.opacity(0.5)) {
                         Text("**Tip**: think about which apps keep you at your phone the most.")
                             .font(.grotesk(.subheadline, weight: .medium))
                             .foregroundStyle(Color.primaryBlue)
                     }

                     Image(.mascotteWriting)
                         .resizable()
                         .scaledToFit()
                         .frame(square: 128)
                 }
                 .opacity(appearAnimation ? 1 : 0)
                 .offset(y: appearAnimation ? 0 : 32)
                 .scaleEffect(appearAnimation ? 1 : 0.95)
                 .animation(.smooth.delay(0.25), value: appearAnimation)
                 
                 if tokenOne != nil || tokenTwo != nil || tokenThree != nil {
                     GlassButton("Confirm selection") {
                         action()
                     }
                     .transition(.offset(y: 128))
                 }
             }
             .padding(.horizontal, 32)
             .padding(.vertical)
         }
         .sheet(isPresented: $showFirstAppPicker) {
             OBAppPickerOne(tokenOne: $tokenOne, tokenTwo: tokenTwo, tokenThree: tokenThree)
         }
         .sheet(isPresented: $showSecondAppPicker) {
             OBAppPickerTwo(tokenOne: tokenOne, tokenTwo: $tokenTwo, tokenThree: tokenThree)
         }
         .sheet(isPresented: $showThirdAppPicker) {
             OBAppPickerThree(tokenOne: tokenOne, tokenTwo: tokenTwo, tokenThree: $tokenThree)
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
     
     private func action() {
         vm.nextPage()
     }
 }

 #Preview {
     OB23()
         .environmentObject(OBVM())
 }

 struct OBAppPickerOne: View {
     @Environment(\.dismiss) var dismiss
     @State var familyActivitySelection = FamilyActivitySelection(includeEntireCategory: true)
     
     @State private var showWarning: Bool = false
     @State private var showCategoryWarning: Bool = false
     @State private var refreshID: Int = 0
     
     @Binding var tokenOne: ApplicationToken?
     var tokenTwo: ApplicationToken?
     var tokenThree: ApplicationToken?
     
     var body: some View {
         NavigationStack {
             FamilyActivityPicker(
                 headerText: "",
                 footerText: "",
                 selection: $familyActivitySelection
             )
             .id(refreshID)
             .ignoresSafeArea()
             .toolbar {
                 ToolbarItem(placement: .topBarTrailing) {
                     Button {
                         dismiss()
                     } label: {
                         Image(systemName: "xmark")
                     }
                 }
             }
             .onChange(of: familyActivitySelection) { _, newValue in
                 // Disallow selecting categories or multiple items
                 guard newValue.applicationTokens.count <= 1 else {
                     // Category warning: Selecting category is not allowed
                     showCategoryWarning = true
                     Haptics.warningFeedback()
                     return
                 }
                 
                 if let tokenTwo, newValue.applicationTokens.contains(tokenTwo) {
                     showWarning = true
                     return
                 } else if let tokenThree, newValue.applicationTokens.contains(tokenThree) {
                     showWarning = true
                     return
                 }

                 // If a single app is selected, assign and dismiss
                 if let first = newValue.applicationTokens.first {
                     tokenOne = first
                     dismiss()
                 }
             }
             .sheet(isPresented: $showWarning) {
                 VStack(spacing: 32) {
                     Text("This app is already selected")
                         .font(.grotesk(.title, weight: .semibold))
                 }
                 .frame(maxWidth: .infinity, maxHeight: .infinity)
                 .padding(32)
                 .safeAreaInset(edge: .bottom) {
                     GlassButton("Back") {
                         refreshID += 1
                         showWarning = false
                         familyActivitySelection = .init()
                     }
                 }
                 .presentationDetents([.height(400)])
             }
             .sheet(isPresented: $showCategoryWarning) {
                 VStack(spacing: 32) {
                     VStack(alignment: .center, spacing: 14) {
                         Text("Please select an individual app")
                             .font(.grotesk(.title, weight: .semibold))
                             .multilineTextAlignment(.center)
                         
                         Text("(not a category)")
                             .font(.grotesk(.title3, weight: .regular))
                             .foregroundStyle(.white.opacity(0.5))
                     }
                 }
                 .frame(maxWidth: .infinity, maxHeight: .infinity)
                 .padding(32)
                 .safeAreaInset(edge: .bottom) {
                     GlassButton("Back") {
                         refreshID += 1
                         showCategoryWarning = false
                     }
                 }
                 .presentationDetents([.height(400)])
             }
         }
         .onAppear {
             tokenOne = nil
         }
     }
 }

 struct OBAppPickerTwo: View {
     @Environment(\.dismiss) var dismiss
     @State var familyActivitySelection = FamilyActivitySelection(includeEntireCategory: true)
     
     @State private var showWarning: Bool = false
     @State private var showCategoryWarning: Bool = false
     @State private var refreshID: Int = 0
     
     var tokenOne: ApplicationToken?
     @Binding var tokenTwo: ApplicationToken?
     var tokenThree: ApplicationToken?

     var body: some View {
         NavigationStack {
             FamilyActivityPicker(
                 headerText: "",
                 footerText: "",
                 selection: $familyActivitySelection
             )
             .id(refreshID)
             .ignoresSafeArea()
             .toolbar {
                 ToolbarItem(placement: .topBarTrailing) {
                     Button {
                         dismiss()
                     } label: {
                         Image(systemName: "xmark")
                     }
                 }
             }
             .onChange(of: familyActivitySelection) { _, newValue in
                 // Disallow selecting categories or multiple items
                 guard newValue.applicationTokens.count <= 1 else {
                     // Category warning: Selecting category is not allowed
                     showCategoryWarning = true
                     Haptics.warningFeedback()
                     return
                 }
                 
                 if let tokenOne, newValue.applicationTokens.contains(tokenOne) {
                     showWarning = true
                     return
                 } else if let tokenThree, newValue.applicationTokens.contains(tokenThree) {
                     showWarning = true
                     return
                 }

                 // If a single app is selected, assign and dismiss
                 if let first = newValue.applicationTokens.first {
                     tokenTwo = first
                     dismiss()
                 }
             }
             .sheet(isPresented: $showWarning) {
                 VStack(spacing: 32) {
                     Text("This app is already selected")
                         .font(.grotesk(.title, weight: .semibold))
                 }
                 .frame(maxWidth: .infinity, maxHeight: .infinity)
                 .padding(32)
                 .safeAreaInset(edge: .bottom) {
                     GlassButton("Back") {
                         refreshID += 1
                         showWarning = false
                         familyActivitySelection = .init()
                     }
                 }
                 .presentationDetents([.height(400)])
             }
             .sheet(isPresented: $showCategoryWarning) {
                 VStack(spacing: 32) {
                     VStack(alignment: .center, spacing: 14) {
                         Text("Please select an individual app")
                             .font(.grotesk(.title, weight: .semibold))
                             .multilineTextAlignment(.center)
                         
                         Text("(not a category)")
                             .font(.grotesk(.title3, weight: .regular))
                             .foregroundStyle(.white.opacity(0.5))
                     }
                 }
                 .frame(maxWidth: .infinity, maxHeight: .infinity)
                 .padding(32)
                 .safeAreaInset(edge: .bottom) {
                     GlassButton("Back") {
                         refreshID += 1
                         showCategoryWarning = false
                     }
                 }
                 .presentationDetents([.height(400)])
             }
         }
         .onAppear {
             tokenTwo = nil
         }
     }
 }

 struct OBAppPickerThree: View {
     @Environment(\.dismiss) var dismiss
     @State var familyActivitySelection = FamilyActivitySelection(includeEntireCategory: true)
     
     @State private var showWarning: Bool = false
     @State private var showCategoryWarning: Bool = false
     @State private var refreshID: Int = 0
     
     var tokenOne: ApplicationToken?
     var tokenTwo: ApplicationToken?
     @Binding var tokenThree: ApplicationToken?
     
     var body: some View {
         NavigationStack {
             FamilyActivityPicker(
                 headerText: "",
                 footerText: "",
                 selection: $familyActivitySelection
             )
             .id(refreshID)
             .ignoresSafeArea()
             .toolbar {
                 ToolbarItem(placement: .topBarTrailing) {
                     Button {
                         dismiss()
                     } label: {
                         Image(systemName: "xmark")
                     }
                 }
             }
             .onChange(of: familyActivitySelection) { _, newValue in
                 // Disallow selecting categories or multiple items
                 guard newValue.applicationTokens.count <= 1 else {
                     // Category warning: Selecting category is not allowed
                     showCategoryWarning = true
                     Haptics.warningFeedback()
                     return
                 }
                 
                 if let tokenOne, newValue.applicationTokens.contains(tokenOne) {
                     showWarning = true
                     return
                 } else if let tokenTwo, newValue.applicationTokens.contains(tokenTwo) {
                     showWarning = true
                     return
                 }

                 // If a single app is selected, assign and dismiss
                 if let first = newValue.applicationTokens.first {
                     tokenThree = first
                     dismiss()
                 }
             }
             .sheet(isPresented: $showWarning) {
                 VStack(spacing: 32) {
                     Text("This app is already selected")
                         .font(.grotesk(.title, weight: .semibold))
                 }
                 .frame(maxWidth: .infinity, maxHeight: .infinity)
                 .padding(32)
                 .safeAreaInset(edge: .bottom) {
                     GlassButton("Back") {
                         refreshID += 1
                         showWarning = false
                         familyActivitySelection = .init()
                     }
                 }
                 .presentationDetents([.height(400)])
             }
             .sheet(isPresented: $showCategoryWarning) {
                 VStack(spacing: 32) {
                     VStack(alignment: .center, spacing: 14) {
                         Text("Please select an individual app")
                             .font(.grotesk(.title, weight: .semibold))
                             .multilineTextAlignment(.center)
                         
                         Text("(not a category)")
                             .font(.grotesk(.title3, weight: .regular))
                             .foregroundStyle(.white.opacity(0.5))
                     }
                 }
                 .frame(maxWidth: .infinity, maxHeight: .infinity)
                 .padding(32)
                 .safeAreaInset(edge: .bottom) {
                     GlassButton("Back") {
                         refreshID += 1
                         showCategoryWarning = false
                     }
                 }
                 .presentationDetents([.height(400)])
             }
         }
         .onAppear {
             tokenThree = nil
         }
     }
 }

 
 */
