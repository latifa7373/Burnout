// =========================
//  QuestionView.swift
// =========================
import SwiftUI

// MARK: - Motion Glow Ring (tuned: slightly softer + colored)
struct MotionGlowRing: View {
    var size: CGFloat = 320
    var strength: Double // 0...1

    private let glowColor = Color(red: 0.62, green: 0.56, blue: 0.78)

    var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate

            let motion = 3.5 + (strength * 5.5)
            let dx = cos(t * 0.9) * motion
            let dy = sin(t * 1.1) * motion

            let outerBlur   = 11 + (strength * 23)
            let innerBlur   = 2.5 + (strength * 8)

            let glowOpacity = 0.12 + (strength * 0.45)
            let rimOpacity  = 0.16 + (strength * 0.45)

            let rimWidth    = 2.3 + (strength * 1.8)
            let shadowOp    = 0.08 + (strength * 0.28)
            let shadowRad   = 5 + (strength * 15)

            let pulse = 1.0 + (sin(t * 1.6) * (0.004 + strength * 0.015))

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                glowColor.opacity(0.0),
                                glowColor.opacity(glowOpacity),
                                glowColor.opacity(0.0)
                            ]),
                            center: .center,
                            startRadius: size * 0.25,
                            endRadius: size * 0.62
                        )
                    )
                    .frame(width: size * 1.13, height: size * 1.13)
                    .blur(radius: outerBlur)
                    .scaleEffect(pulse)
                    .offset(x: dx, y: dy)
                    .blendMode(.screen)
                    .opacity(0.9)

                Circle()
                    .stroke(glowColor.opacity(rimOpacity), lineWidth: rimWidth)
                    .frame(width: size, height: size)
                    .shadow(color: glowColor.opacity(shadowOp),
                            radius: shadowRad,
                            x: 0, y: 0)
                    .blur(radius: innerBlur)
                    .opacity(0.95)

                Circle()
                    .stroke(glowColor.opacity(0.07 + strength * 0.14), lineWidth: 8)
                    .frame(width: size * 0.92, height: size * 0.92)
                    .blur(radius: 10 + strength * 8)
                    .opacity(0.65)
            }
            .compositingGroup()
        }
    }
}

// MARK: - QuestionView
struct QuestionView: View {
    @Environment(\.dismiss) private var dismiss

    let dimension: Dimension
    let question: String
    let onContinue: (Int) -> Void

    @State private var sliderValue: Double = 3.0

    private var sliderText: String {
        switch Int(sliderValue) {
        case 1: return String(localized: "Never", comment: "Slider label: Never (1/5)")
        case 2: return String(localized: "A Little", comment: "Slider label: A Little (2/5)")
        case 3: return String(localized: "Somewhat", comment: "Slider label: Somewhat (3/5)")
        case 4: return String(localized: "A Lot", comment: "Slider label: A Lot (4/5)")
        case 5: return String(localized: "Extremely", comment: "Slider label: Extremely (5/5)")
        default: return String(localized: "Somewhat", comment: "Slider label: default mid value")
        }
    }

    private var glowStrength: Double {
        (sliderValue - 1) / 4
    }

    var body: some View {
        ZStack {
            // ✅ نفس خلفية InsightView بالضبط (ثابتة)
            Color(red: 44/255, green: 30/255, blue: 47/255)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Text(String(localized: "Today's Check"))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 30)

                Spacer()

                VStack(spacing: 16) {
                    Text(String(localized: "How much does this describe you?"))
                        .font(.title3)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    ZStack {
                        MotionGlowRing(size: 320, strength: glowStrength)

                        Image(dimension.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320, height: 320)
                            .frame(maxWidth: .infinity, alignment: .center)

                        Text(question)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(4)
                            .minimumScaleFactor(0.75)
                            .padding(.horizontal, 8)
                            .frame(width: 200, alignment: .center)
                    }
                    .frame(height: 320)
                }

                Spacer()

                VStack(spacing: 20) {
                    Text(sliderText)
                        .font(.title)
                        .fontWeight(.regular)
                        .foregroundStyle(.white)

                    CapsuleSlider(
                        value: $sliderValue,
                        range: 1...5,
                        step: 1,
                        trackHeight: 30,
                        thumbSize: 30,
                        trackColor: .white.opacity(0.25),
                        fillColor: .white.opacity(0.0),
                        thumbColor: .white
                    )
                    .padding(.horizontal, 40)
                    .environment(\.layoutDirection, .leftToRight)

                    Button {
                        onContinue(Int(sliderValue))
                    } label: {
                        Text(String(localized: "Continue"))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(.white.opacity(0.15))
                            )
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)
            }
        }
    }
}
