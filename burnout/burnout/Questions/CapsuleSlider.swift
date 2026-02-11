import SwiftUI

struct CapsuleSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    var step: Double? = nil

    var trackHeight: CGFloat = 30
    var thumbSize: CGFloat = 30
    var trackColor: Color = Color.white.opacity(0.25)
    var fillColor: Color = Color.white.opacity(0.0)
    var thumbColor: Color = .white

    // سموذ أكثر (أبطأ شوي + تخميد أعلى)
    private let spring = Animation.interactiveSpring(
        response: 0.50,
        dampingFraction: 0.92,
        blendDuration: 0.25
    )

    @State private var animatedX: CGFloat = 0
    @GestureState private var isDragging = false

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let usable = max(1, width - thumbSize)
            let targetX = normalized(value) * usable

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(trackColor)
                    .frame(height: trackHeight)

                Capsule()
                    .fill(fillColor)
                    .frame(width: animatedX + thumbSize / 2, height: trackHeight)

                Circle()
                    .fill(thumbColor)
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: animatedX)
                    .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 4)
                    .animation(spring, value: animatedX)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .updating($isDragging) { _, state, _ in
                                state = true
                            }
                            .onChanged { g in
                                // 1) حركة ناعمة للـ thumb (بدون step)
                                let localX = min(max(0, g.location.x - thumbSize / 2), usable)

                                withAnimation(spring) {
                                    animatedX = localX
                                }

                                // 2) حدثي value بشكل ناعم (بدون snap أثناء السحب)
                                let continuousValue = range.lowerBound
                                    + (Double(localX) / Double(usable)) * (range.upperBound - range.lowerBound)

                                value = min(max(continuousValue, range.lowerBound), range.upperBound)
                            }
                            .onEnded { _ in
                                // 3) عند الإفلات: اسنبي للـ step إذا موجود
                                var finalValue = value
                                if let step {
                                    finalValue = (finalValue / step).rounded() * step
                                    finalValue = min(max(finalValue, range.lowerBound), range.upperBound)
                                }

                                value = finalValue

                                // حرّكي thumb لمكان القيمة النهائية بنعومة
                                let snappedX = normalized(finalValue) * usable
                                withAnimation(spring) {
                                    animatedX = snappedX
                                }
                            }
                    )
            }
            .frame(height: max(trackHeight, thumbSize))
            .onAppear {
                animatedX = targetX
            }
            .onChange(of: value) { newValue in
                // لو القيمة تغيرت من برا، نحدّث thumb بس إذا مو dragging
                if !isDragging {
                    let x = normalized(newValue) * usable
                    withAnimation(spring) {
                        animatedX = x
                    }
                }
            }
        }
        .frame(height: max(trackHeight, thumbSize))
    }

    private func normalized(_ v: Double) -> CGFloat {
        guard range.upperBound != range.lowerBound else { return 0 }
        let t = (v - range.lowerBound) / (range.upperBound - range.lowerBound)
        return CGFloat(min(max(t, 0), 1))
    }
}
