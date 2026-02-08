import SwiftUI

struct homeView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.18, green: 0.12, blue: 0.22),
                    Color(red: 0.14, green: 0.10, blue: 0.18)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    topBar
                    header
                    gaugeSection
                    infoCards
                    insightsCard
                }
                .padding(.horizontal, 25)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
    }
}

// MARK: - ألوان موحّدة (الـ gauge)
private enum Palette {
    static let pink = Color(red: 0.95, green: 0.45, blue: 0.55)
    static let purple = Color(red: 0.55, green: 0.35, blue: 0.65)
    static let teal = Color(red: 0.25, green: 0.55, blue: 0.55)

    static var gaugeGradient: LinearGradient {
        LinearGradient(colors: [pink, purple, teal], startPoint: .leading, endPoint: .trailing)
    }
}

// MARK: - ألوان اللوقو (الشارت تحت)
private enum LogoPalette {
    static let one = Color(red: 98/255.0, green: 62/255.0, blue: 83/255.0)
    static let two = Color(red: 58/255.0, green: 27/255.0, blue: 79/255.0)
    static let three = Color(red: 22/255.0, green: 46/255.0, blue: 53/255.0)
}

// MARK: - Sections
private extension homeView {
    var topBar: some View {
        HStack {
            Image(systemName: "person.circle")
                .font(.system(size: 40, weight: .regular))
                .foregroundColor(.white.opacity(0.85))
            Spacer()
        }
        .padding(.top, 4)
    }

    var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Hello, Nourah")
                .font(.system(size: 28, weight: .regular))
                .foregroundColor(.white)
                .padding(.bottom, 2)

            Text("Here is your Burnout Risk Index")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.white.opacity(0.85))
        }
        .padding(.top, 8)
    }

    var gaugeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            BurnoutGaugeView(value: 0.2)
                .frame(height: 140)
                .padding(.leading, -8)

            Text("Low")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 36)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .stroke(Color.white.opacity(0.55), lineWidth: 1)
                )
                .padding(.leading, 4)

            Text("Some signs are starting to slightly increase")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.6))
                .padding(.leading, 4)
        }
        .padding(.top, 20)
    }

    var infoCards: some View {
        HStack(alignment: .top, spacing: 16) {
            SmallInfoCard(
                title: "Status",
                actionText: "learn more",
                badgeTitle: "Low Risk",
                bodyText: "Your responses indicate that your productivity level is currently normal"
            )

            SmallInfoCard(
                title: "Today’s\nCheck",
                actionText: "View more",
                badgeTitle: "All Done",
                bodyText: "Keep checking in daily for more accurate insights"
            )
        }
        .padding(.top, 4)
    }

    var insightsCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(cardGradient)

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Burnout Insights")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    Spacer()
                    HStack(spacing: 1) {
                        Text("View details")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.55))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.55))
                    }
                }

                HStack(alignment: .bottom, spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Average")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        Text("30%")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    HStack(alignment: .bottom, spacing: 10) {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(LogoPalette.one)
                            .frame(width: 14, height: 28)
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(LogoPalette.two)
                            .frame(width: 14, height: 42)
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(LogoPalette.three)
                            .frame(width: 14, height: 56)
                    }
                }
                .padding(.top, 16)
            }
            .padding(16)
        }
        .frame(height: 140)
        .padding(.top, 10)
    }

    private var cardGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.12),
                Color.white.opacity(0.04)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Components
    private struct BurnoutGaugeView: View {
        var value: Double = 0.2

        private let lineWidth: CGFloat = 14
        private let gaugeSize: CGFloat = 180

        private var arcCenterY: CGFloat { gaugeSize / 2 + lineWidth - 8 }
        private var radius: CGFloat { gaugeSize / 2 - 10 }

        var body: some View {
            ZStack {
                GaugeArcShape(radius: radius, centerY: arcCenterY)
                    .stroke(Palette.gaugeGradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .frame(width: gaugeSize, height: gaugeSize / 2 + lineWidth)

                GaugeNeedleView(
                    value: value,
                    pivotY: arcCenterY,
                    frameWidth: gaugeSize,
                    frameHeight: gaugeSize / 2 + lineWidth
                )
                .frame(width: gaugeSize, height: gaugeSize / 2 + lineWidth)

                Circle()
                    .fill(Color.white)
                    .frame(width: 12, height: 12)
                    .position(x: gaugeSize / 2, y: arcCenterY)
            }
            .frame(width: gaugeSize, height: gaugeSize / 2 + lineWidth)
        }
    }

    private struct GaugeArcShape: Shape {
        var radius: CGFloat
        var centerY: CGFloat

        func path(in rect: CGRect) -> Path {
            var p = Path()
            let center = CGPoint(x: rect.midX, y: centerY)
            p.addArc(center: center, radius: radius, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
            return p
        }
    }

    private struct GaugeNeedleView: View {
        var value: Double
        var pivotY: CGFloat
        var frameWidth: CGFloat
        var frameHeight: CGFloat

        private let needleHeight: CGFloat = 52
        private let needleWidth: CGFloat = 4

        private var needleAngle: Double { 180 * value }

        var body: some View {
            let pivot = CGPoint(x: frameWidth / 2, y: pivotY)

            NeedleShape()
                .fill(Color.white)
                .frame(width: needleWidth, height: needleHeight)
                .position(x: pivot.x, y: pivot.y)
                .rotationEffect(.degrees(needleAngle), anchor: .bottom)
        }
    }

    private struct NeedleShape: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            p.closeSubpath()
            return p
        }
    }

    private struct SmallInfoCard: View {
        let title: String
        let actionText: String
        let badgeTitle: String
        let bodyText: String

        var body: some View {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(cardGradient)

                VStack(alignment: .leading, spacing: 1) {
                    HStack {
                        Text(title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)

                        Spacer()

                        HStack(spacing: 1) {
                            Text(actionText)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.55))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.55))
                        }
                    }

                    Text(badgeTitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))

                    Text(bodyText)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()

                    HStack {
                        Spacer()
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 56, height: 48)
                    }
                }
                .padding(16)
            }
            .frame(height: 170)
        }

        private var cardGradient: LinearGradient {
            LinearGradient(
                colors: [
                    Color.white.opacity(0.12),
                    Color.white.opacity(0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

#Preview {
    homeView()
}


