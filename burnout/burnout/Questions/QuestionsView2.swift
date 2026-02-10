// =========================
//  QuestionView.swift
// =========================
import SwiftUI

// MARK: - Motion Glow Ring (tuned: slightly softer + colored)
struct MotionGlowRing: View {
    var size: CGFloat = 320
    var strength: Double // 0...1

    // ✅ لون قريب من ألوان الدائرة (موف/بنفسجي ناعم بدل الأبيض الصريح)
    private let glowColor = Color(red: 0.62, green: 0.56, blue: 0.78)

    var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate

            // Motion بسيط جدًا (نخليه أخف شوي)
            let motion = 3.5 + (strength * 5.5)              // كان 4...10 صار تقريبًا 3.5...9
            let dx = cos(t * 0.9) * motion
            let dy = sin(t * 1.1) * motion

            // ✅ خففنا التوهج "شوي" فقط + لون أقرب للدائرة
            let outerBlur   = 11 + (strength * 23)           // كان 12...38 صار 11...34
            let innerBlur   = 2.5 + (strength * 8)           // كان 3...13 صار 2.5...10.5

            let glowOpacity = 0.12 + (strength * 0.45)       // كان 0.15...0.70 صار 0.12...0.57
            let rimOpacity  = 0.16 + (strength * 0.45)       // كان 0.18...0.73 صار 0.16...0.61

            let rimWidth    = 2.3 + (strength * 1.8)         // كان 2.5...4.5 صار 2.3...4.1
            let shadowOp    = 0.08 + (strength * 0.28)       // كان 0.10...0.45 صار 0.08...0.36
            let shadowRad   = 5 + (strength * 15)            // كان 6...24 صار 5...20

            // نبض خفيف (نخففه شوي)
            let pulse = 1.0 + (sin(t * 1.6) * (0.004 + strength * 0.015))

            ZStack {
                // 1) هالة كبيرة ناعمة (Premium glow) — ملونة بدل الأبيض
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
                    .frame(width: size * 1.13, height: size * 1.13) // كان 1.15 خففناه شوي
                    .blur(radius: outerBlur)
                    .scaleEffect(pulse)
                    .offset(x: dx, y: dy)
                    .blendMode(.screen)
                    .opacity(0.9)

                // 2) Rim واضح — ملون بدل الأبيض + شادو أخف
                Circle()
                    .stroke(glowColor.opacity(rimOpacity), lineWidth: rimWidth)
                    .frame(width: size, height: size)
                    .shadow(color: glowColor.opacity(shadowOp),
                            radius: shadowRad,
                            x: 0, y: 0)
                    .blur(radius: innerBlur)
                    .opacity(0.95)

                // 3) Rim داخلي خفيف — ملون وخفيف
                Circle()
                    .stroke(glowColor.opacity(0.07 + strength * 0.14), lineWidth: 8)
                    .frame(width: size * 0.92, height: size * 0.92)
                    .blur(radius: 10 + strength * 8) // كان 10 + 10
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
        case 1: return "Never"
        case 2: return "A Little"
        case 3: return "Somewhat"
        case 4: return "A Lot"
        case 5: return "Extremely"
        default: return "Somewhat"
        }
    }

    // ✅ قوة التوهج مرتبطة بالسلايدر: 1...5 -> 0...1
    private var glowStrength: Double {
        (sliderValue - 1) / 4
    }

    var body: some View {
        ZStack {
            Color(.primary)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header بدون back button (QuestionsFlowView لديه toolbar)
                CheckHeader(title: "Today's Check", showBack: false) {
                    dismiss()
                }

                Spacer()

                // السؤال الثابت
                VStack(spacing: 16) {
                    Text("How much does this describe you?")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // ✅ دائرة ثابتة + سؤال داخلها + Glow يتغير مع السلايدر
                    ZStack {
                        MotionGlowRing(size: 320, strength: glowStrength)

                        Image(dimension.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320, height: 320) // ثبات الحجم
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

                // النص + السلايدر + الزر
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

                    Button {
                        onContinue(Int(sliderValue))
                    } label: {
                        Text("Continue")
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
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        QuestionView(
            dimension: DimensionsData.dimensions[0],
            question: DimensionsData.dimensions[0].questions[0],
            onContinue: { print("Response:", $0) }
        )
    }
}
