//
//  OBBeforeAfterView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 10/06/25.
//

import SwiftUI
import Lottie

struct OBBeforeAfterView: View {
    @EnvironmentObject var vm: OBUserViewModel
    
    let width: CGFloat = UIScreen.main.bounds.width

    var body: some View {
        VStack(spacing: 32) {
            VStack(alignment: .center, spacing: 14) {
                Text("subtitle".uppercased())
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.primaryBlue)
                    .kerning(1.0)
                
                Text("Feel the difference with \(AppConfiguration.name)")
                    .font(.system(size: 30).weight(.bold))
                    .multilineTextAlignment(.center)
            }
            
            HStack(spacing: 0) {
                
                VStack {
                    Pill(title: "High stress", icon: "arrow.up", color: .red)
                        .rotationEffect(.degrees(10))
                    //                    .offset(x: 100, y: 30)
                    //                    .opacity(showPills[0] ? 1.0 : 0.0)
                    //                    .scaleEffect(showPills[0] ? 1.0 : 0.95)
                    
                    Pill(title: "Reduced creativity", icon: "paintbrush", color: .orange)
                        .rotationEffect(.degrees(-5))
                    //                    .offset(x: -90, y: 160)
                    //                    .opacity(showPills[1] ? 1.0 : 0.0)
                    //                    .scaleEffect(showPills[1] ? 1.0 : 0.95)
                    
                    Pill(title: "Brain fog", icon: "brain", color: .purple)
                        .rotationEffect(.degrees(5))
                    //                    .offset(x: -30, y: 230)
                    //                    .opacity(showPills[2] ? 1.0 : 0.0)
                    //                    .scaleEffect(showPills[2] ? 1.0 : 0.95)
                    
                    Pill(title: "Low confidence", icon: "arrow.down", color: .red)
                        .rotationEffect(.degrees(5))
                    //                    .offset(x: -90, y: 50)
                    //                    .opacity(showPills[3] ? 1.0 : 0.0)
                    //                    .scaleEffect(showPills[3] ? 1.0 : 0.95)
                    
                    Pill(title: "Struggle to focus", icon: "target", color: .gray)
                        .rotationEffect(.degrees(5))
                    //                    .offset(x: 95, y: 100)
                    //                    .opacity(showPills[4] ? 1.0 : 0.0)
                    //                    .scaleEffect(showPills[4] ? 1.0 : 0.95)
                    
                    Pill(title: "Anxiety", icon: "waveform.path.ecg", color: .indigo)
                        .rotationEffect(.degrees(5))
                    //                    .offset(x: 80, y: 190)
                    //                    .opacity(showPills[5] ? 1.0 : 0.0)
                    //                    .scaleEffect(showPills[5] ? 1.0 : 0.95)
                    
                }
                
                VStack {
                    Pill(title: "More energy", icon: "bolt", color: .orange)
                        .rotationEffect(.degrees(-5))
                    //                    .offset(x: 100, y: 30)
                    //                    .pillKeyframeAnimation(phaseThree, delay: 0.11, rotation: 1)
                    
                    Pill(title: "Mental clarity", icon: "brain", color: .teal)
                        .rotationEffect(.degrees(-2))
                    //                    .offset(x: -90, y: 140)
                    //                    .pillKeyframeAnimation(phaseThree, delay: 0.02, rotation: 1)
                    
                    Pill(title: "Peace of mind", icon: "leaf", color: .green)
                        .rotationEffect(.degrees(2))
                    //                    .offset(x: -90, y: 50)
                    //                    .pillKeyframeAnimation(phaseThree, delay: 0.1, rotation: -2)
                    
                    Pill(title: "Boosted focus", icon: "target", color: .brown)
                        .rotationEffect(.degrees(-2))
                    //                    .offset(x: 95, y: 100)
                    //                    .pillKeyframeAnimation(phaseThree, delay: 0.05, rotation: -1)
                    
                    Pill(title: "Better sleep", icon: "zzz", color: Color.primaryBlue)
                        .rotationEffect(.degrees(2))
                    //                    .offset(x: 70, y: 170)
                    //                    .pillKeyframeAnimation(phaseThree, rotation: -1)
                }
                
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            Button {
                action()
            } label: {
                RoundedRectangle(cornerRadius: 100, style: .continuous)
                    .frame(height: 60)
                    .overlay {
                        Text("Continue")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.background)
                    }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 32)
        }
        .onAppear(perform: setup)
    }
    
    private func setup() {
        // ...
    }
    
    private func action() {
        // Call MixPanel

        // Continue
        vm.goToNextStep(step: 11)
    }

    @ViewBuilder
    private func Pill(title: String, icon: String, color: Color, scale: CGFloat = 1.0) -> some View {
        HStack {
            Image(systemName: icon)
                .fontWeight(.semibold)
                .foregroundStyle(color)
            
            Text(title)
                .font(.title3.weight(.semibold))
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 18.0, style: .continuous)
                .foregroundStyle(Color(UIColor.secondarySystemGroupedBackground))
            
            RoundedRectangle(cornerRadius: 18.0, style: .continuous)
                .stroke(lineWidth: 2.0)
                .foregroundStyle(Color(UIColor.secondarySystemBackground))
        }
        .padding(1)
        .background {
            RoundedRectangle(cornerRadius: 18.0, style: .continuous)
                .stroke(lineWidth: 4.0)
                .foregroundStyle(Color(UIColor.systemBackground))
        }
        .scaleEffect(scale)
    }

}

#Preview {
    OBBeforeAfterView()
        .environmentObject(OBUserViewModel())
}

struct ArrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.63268*width, y: 0.35947*height))
        path.addLine(to: CGPoint(x: 0.55174*width, y: 0.3272*height))
        path.addCurve(to: CGPoint(x: 0.54415*width, y: 0.27636*height), control1: CGPoint(x: 0.5319*width, y: 0.31929*height), control2: CGPoint(x: 0.52764*width, y: 0.29073*height))
        path.addLine(to: CGPoint(x: 0.8525*width, y: 0.00788*height))
        path.addCurve(to: CGPoint(x: 0.89557*width, y: 0.02355*height), control1: CGPoint(x: 0.86782*width, y: -0.00546*height), control2: CGPoint(x: 0.89065*width, y: 0.00284*height))
        path.addLine(to: CGPoint(x: 0.99835*width, y: 0.45594*height))
        path.addCurve(to: CGPoint(x: 0.96287*width, y: 0.49111*height), control1: CGPoint(x: 1.00383*width, y: 0.47899*height), control2: CGPoint(x: 0.98336*width, y: 0.49928*height))
        path.addLine(to: CGPoint(x: 0.8851*width, y: 0.4601*height))
        path.addCurve(to: CGPoint(x: 0, y: 0.99181*height), control1: CGPoint(x: 0.84864*width, y: 0.59675*height), control2: CGPoint(x: 0.59485*width, y: 1.0605*height))
        path.addCurve(to: CGPoint(x: 0.63268*width, y: 0.35947*height), control1: CGPoint(x: 0.42527*width, y: 0.97937*height), control2: CGPoint(x: 0.62809*width, y: 0.48178*height))
        path.closeSubpath()
        return path
    }
}
