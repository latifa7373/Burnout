import SwiftUI
import SwiftData

struct homeView: View {
    @Query private var dailyRiskScores: [DailyRiskScore]
    @StateObject private var viewModel = HomeViewModel()
    @State private var gaugeValue: Double = 0.0

    var body: some View {
        NavigationStack {
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

                VStack(alignment: .center, spacing: 22) {
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
        .onAppear {
            viewModel.loadUserName()
            viewModel.calculateRiskFromLastWeek(dailyRiskScores: dailyRiskScores)
            withAnimation(.easeOut(duration: 1.2)) {
                gaugeValue = viewModel.model.riskIndex
            }
        }
        .onChange(of: dailyRiskScores) { _, _ in
            viewModel.calculateRiskFromLastWeek(dailyRiskScores: dailyRiskScores)
            withAnimation(.easeOut(duration: 1.2)) {
                gaugeValue = viewModel.model.riskIndex
            }
        }
    }
}

// MARK: - Colors
private enum Palette {
    static let green = LogoPalette.three
    static let purple = LogoPalette.two

    static var gaugeGradient: LinearGradient {
        LinearGradient(colors: [green, purple], startPoint: .leading, endPoint: .trailing)
    }
}

private enum LogoPalette {
    static let one = Color(red: 98/255.0, green: 62/255.0, blue: 83/255.0)
    static let two = Color(red: 58/255.0, green: 27/255.0, blue: 79/255.0)
    static let three = Color(red: 22/255.0, green: 46/255.0, blue: 53/255.0)
}

// MARK: - Sections
private extension homeView {
    enum Layout {
        static let infoCardHeight: CGFloat = 176
    }

    var topBar: some View {
        HStack {
            NavigationLink(destination: ProfileView()) {
                Image(systemName: "person.circle")
                    .font(.system(size: 40, weight: .regular))
                    .foregroundColor(.white.opacity(0.85))
                    .offset(x: 0, y: 8)
            }
            .buttonStyle(.plain)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(.top, 4)
    }

    var header: some View {
        VStack(alignment: .center, spacing: 6) {
            Text("Hello, \(viewModel.model.userName)")
                .font(.system(size: 28, weight: .regular))
                .foregroundColor(.white)
                .padding(.bottom, 3)

            Text("Here is your Burnout Risk Index")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.white.opacity(0.85))
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 8)
    }

    var gaugeSection: some View {
        VStack(alignment: .center, spacing: 14) {
            BurnoutGaugeView(value: gaugeValue)
                .frame(height: 140)

            Text(viewModel.model.riskLabel)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 36)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.gray.opacity(0.1))
                )

            Text(
                viewModel.hasMinimumData
                ? "your average on the past 3 days looks"
                : "complete 3 daily check-ins to unlock your average"
            )
            .font(.system(size: 15))
            .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .multilineTextAlignment(.center)
        .padding(.top, -25)
    }

   var infoCards: some View {
        HStack(alignment: .top, spacing: 16) {
            NavigationLink {
                StatusView()
            } label: {
                SmallInfoCard(
                    title: viewModel.model.statusCard.title,
                    actionText: viewModel.model.statusCard.actionText,
                    badgeTitle: viewModel.model.statusCard.badgeTitle,
                    bodyText: viewModel.model.statusCard.bodyText
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .buttonStyle(.plain)

            NavigationLink {
                QuestionsFlowView()
            } label: {
                SmallInfoCard(
                    title: viewModel.model.todayCard.title,
                    actionText: viewModel.model.todayCard.actionText,
                    badgeTitle: viewModel.model.todayCard.badgeTitle,
                    bodyText: viewModel.model.todayCard.bodyText
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 168)   // نفس الارتفاع للكاردين
        .padding(.top, 4)
    }


    var insightsCard: some View {
        NavigationLink {
            InsightView()
        } label: {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(cardGradient)

                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Burnout Insights")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
                        HStack(spacing: 2) {
                            Text("View details")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.55))
                            Image(systemName: "chevron.forward")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white.opacity(0.55))
                        }
                    }

                    HStack(alignment: .bottom, spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            if viewModel.isFirstTimeUser {
                                Text("No data yet")
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundColor(.white)
                                Text("Start with today's check-in")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.75))
                            } else if !viewModel.hasMinimumData {
                                Text("Pending")
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundColor(.white)
                                Text("Need 3 days to calculate average")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.75))
                            } else {
                                Text(viewModel.model.insights.averageLabel)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                Text("\(viewModel.model.insights.averagePercent)%")
                                    .font(.system(size: 32, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }

                        Spacer()

                        HStack(alignment: .bottom, spacing: 10) {
                            ForEach(viewModel.model.insights.bars) { bar in
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(bar.color)
                                    .frame(width: 14, height: bar.height)
                            }
                        }
                    }
                    .padding(.top, 16)
                }
                .padding(16)
            }
            .frame(height: 168)
            .padding(.top, 10)
        }
        .buttonStyle(.plain)
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
        var value: Double = 0.0

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
                    frameHeight: gaugeSize / 2 + lineWidth,
                    radius: radius
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

    // Needle is now a line drawn from pivot to arc direction.
    // This keeps it always inside gauge bounds for 0...100%.
    private struct GaugeNeedleView: View {
        var value: Double
        var pivotY: CGFloat
        var frameWidth: CGFloat
        var frameHeight: CGFloat
        var radius: CGFloat

        private var normalizedValue: CGFloat {
            if value > 1 {
                return CGFloat(min(max((value - 1.0) / 4.0, 0.0), 1.0))
            } else {
                return CGFloat(min(max(value, 0.0), 1.0))
            }
        }

        var body: some View {
            let cx = frameWidth / 2
            let cy = pivotY

            // 0 -> left, 0.5 -> top, 1 -> right
            let angle = Double.pi - (Double(normalizedValue) * Double.pi)
            let needleLength = radius - 10

            let tipX = cx + CGFloat(cos(angle)) * needleLength
            let tipY = cy - CGFloat(sin(angle)) * needleLength

            return ZStack {
                Path { p in
                    p.move(to: CGPoint(x: cx, y: cy))
                    p.addLine(to: CGPoint(x: tipX, y: tipY))
                }
                .stroke(Color.white, style: StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round))
            }
            .frame(width: frameWidth, height: frameHeight)
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(alignment: .leading, spacing: -3) {
                    ZStack(alignment: .topLeading) {
                        Text(title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 2) {
                            Text(actionText)
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.55))
                            Image(systemName: "chevron.forward")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white.opacity(0.55))
                        }
                        .frame(maxWidth: .infinity, alignment: .topTrailing)
                    }

                    Spacer().frame(height: 8)

                    Text(badgeTitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))

                    Spacer().frame(height: 8)

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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    NavigationStack {
        homeView()
    }
}
