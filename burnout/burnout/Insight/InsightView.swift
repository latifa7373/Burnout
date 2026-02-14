import SwiftUI
import Charts
import SwiftData

struct InsightView: View {
    @StateObject private var vm = InsightViewModel()
    @Query private var dailyRiskScores: [DailyRiskScore]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var chartScrollResetID = UUID()

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(String(localized: "Burnout Insights"))
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white.opacity(0.95))
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .padding(.top, 4)

            filterMenu
            chartCard
            aboutSection

            Spacer()
        }
        .padding()
        .background(appBackground)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
        }
        .onAppear {
            vm.updateData(dailyRiskScores)
        }
        .onChange(of: dailyRiskScores) { _, _ in
            vm.updateData(dailyRiskScores)
        }
        .onChange(of: vm.selectedFilter) { _, _ in
            vm.updateData(dailyRiskScores)
            chartScrollResetID = UUID()
        }
        .onChange(of: vm.selectedMonth) { _, _ in
            vm.updateData(dailyRiskScores)
            chartScrollResetID = UUID()
        }
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            vm.updateData(dailyRiskScores)
            chartScrollResetID = UUID()
        }
        .onChange(of: vm.data.count) { _, _ in
            chartScrollResetID = UUID()
        }
    }
}

private extension InsightView {
    var gridLineStyle: StrokeStyle { StrokeStyle(lineWidth: 1, dash: [4, 4]) }
    var gridLineColor: Color { .white.opacity(0.12) }

    var chartItemWidth: CGFloat {
        switch vm.selectedFilter {
        case .week: return 44
        case .month: return 28
        }
    }

    var xAxisTrailingPadding: CGFloat { max(24, chartItemWidth) }
    var fixedYAxisWidth: CGFloat { 56 }
    var xAxisBottomSpace: CGFloat { 26 }
    var plotHeight: CGFloat { 240 - xAxisBottomSpace }

    var chartWidth: CGFloat {
        max((CGFloat(vm.data.count) * chartItemWidth) + xAxisTrailingPadding,
            UIScreen.main.bounds.width - 80)
    }

    var glassFill: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.62, green: 0.58, blue: 0.70).opacity(0.32),
                Color(red: 0.40, green: 0.34, blue: 0.52).opacity(0.28)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    var riskLineLegend: some View {
        HStack(spacing: 8) {
            Canvas { context, size in
                var path = Path()
                path.move(to: CGPoint(x: 0, y: size.height / 2))
                path.addLine(to: CGPoint(x: size.width, y: size.height / 2))
                context.stroke(
                    path,
                    with: .color(Color.red.opacity(0.9)),
                    style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                )
            }
            .frame(width: 24, height: 6)

            Text(String(localized: "Risk line"))
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.68))

            Spacer()
        }
    }

    var glassStroke: Color { .white.opacity(0.10) }
    var glassShadow: Color { .black.opacity(0.18) }

    func glassButton<S: Shape>(_ shape: S) -> some View {
        shape
            .fill(glassFill)
            .overlay(shape.stroke(glassStroke, lineWidth: 1))
            .shadow(color: glassShadow, radius: 10, x: 0, y: 8)
    }

    func glassCard<S: Shape>(_ shape: S) -> some View {
        shape
            .fill(glassFill)
            .overlay(shape.stroke(glassStroke, lineWidth: 1))
            .shadow(color: glassShadow, radius: 18, x: 0, y: 10)
    }

    var filterMenu: some View {
        Menu {
            ForEach(TimeFilter.allCases, id: \.self) { filter in
                Button(filter.localizedTitle) { vm.setFilter(filter) }
            }
        } label: {
            HStack(spacing: 8) {
                Text(vm.selectedFilter.localizedTitle)
                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .semibold))
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white.opacity(0.95))
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(glassButton(RoundedRectangle(cornerRadius: 14)))
        }
    }

    var monthControls: some View {
        HStack {
            Spacer()

            Text(vm.monthTitle)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.90))

            HStack(spacing: 8) {
                Button { vm.prevMonth() } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.95))
                        .frame(width: 30, height: 30)
                }
                .background(glassButton(RoundedRectangle(cornerRadius: 10)))

                Button { vm.nextMonth() } label: {
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.95))
                        .frame(width: 30, height: 30)
                }
                .background(glassButton(RoundedRectangle(cornerRadius: 10)))
            }
        }
        .padding(.bottom, 6)
    }

    var chartCard: some View {
        VStack(spacing: 10) {
            HStack {
                let workDaysCount = vm.data.filter { $0.isWorkDay }.count
                let answeredDaysCount = vm.data.filter { $0.hasResponse }.count

                Text(summaryText(answeredDaysCount: answeredDaysCount, workDaysCount: workDaysCount))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
            }

            if vm.selectedFilter == .month {
                monthControls
            }

            HStack(alignment: .top, spacing: 8) {
                ScrollView(.horizontal, showsIndicators: false) {
                    chartCore
                        .frame(width: chartWidth, height: 240)
                }
                .id(chartScrollResetID)
                .environment(\.layoutDirection, .leftToRight)

                fixedYAxis
                    .frame(width: fixedYAxisWidth, height: 240)
            }

            VStack(alignment: .leading, spacing: 6) {
                riskLineLegend

                Text(String(localized: "Note: High means your score is above the risk line for 3 days in a row."))
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.62))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 2)

        }
        .padding(14)
        .background(glassCard(RoundedRectangle(cornerRadius: 22)))
    }

    func riskScoreToPercentage(_ riskScore: Double) -> Double {
        let percentage = ((riskScore - 1.0) / 4.0) * 100.0
        return min(max(percentage, 0), 100)
    }

    var chartCore: some View {
        Chart {
            RuleMark(y: .value(String(localized: "Danger Line"), 70))
                .foregroundStyle(Color.red.opacity(0.9))
                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [6, 4]))

            ForEach(Array(vm.data.enumerated()), id: \.element.id) { index, item in
                if item.hasResponse {
                    let percentage = riskScoreToPercentage(item.riskScore)

                    BarMark(
                        x: .value(String(localized: "Index"), index),
                        y: .value(String(localized: "Risk %"), percentage)
                    )
                    .foregroundStyle(Color(red: 0.30, green: 0.60, blue: 0.60))
                    .cornerRadius(6)
                }
            }
        }
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(position: .trailing, values: [0, 25, 50, 75, 100]) { _ in
                AxisGridLine(stroke: gridLineStyle).foregroundStyle(gridLineColor)
                AxisValueLabel().foregroundStyle(.clear)
            }
        }
        .chartXAxis {
            AxisMarks(values: Array(vm.data.indices)) { _ in
                AxisGridLine(stroke: gridLineStyle).foregroundStyle(gridLineColor)
                AxisValueLabel().foregroundStyle(.clear)
            }
        }
        .chartPlotStyle {
            $0.background(Color.white.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .chartXScale(range: .plotDimension(padding: 12))
        .overlay(alignment: .bottomLeading) {
            customXAxisLabels
                .padding(.leading, 8)
                .padding(.trailing, xAxisTrailingPadding)
                .padding(.bottom, 6)
        }
        .padding(.bottom, 8)
    }

    var customXAxisLabels: some View {
        HStack(spacing: 0) {
            ForEach(Array(vm.data.indices), id: \.self) { i in
                Text(xLabel(for: i))
                    .foregroundStyle(.white.opacity(0.7))
                    .font(.system(size: 11))
                    .frame(width: chartItemWidth, alignment: .center)
            }
        }
        .padding(.trailing, xAxisTrailingPadding)
        .frame(width: (CGFloat(vm.data.count) * chartItemWidth) + xAxisTrailingPadding, alignment: .leading)
        .allowsHitTesting(false)
    }

    func xLabel(for index: Int) -> String {
        guard vm.data.indices.contains(index) else { return "" }
        return vm.data[index].label
    }

    var fixedYAxis: some View {
        VStack(spacing: 0) {
            ForEach([100.0, 75.0, 50.0, 25.0, 0.0], id: \.self) { v in
                Text(yAxisLabel(for: v))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.65))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .frame(height: plotHeight / 5)
            }
            Spacer(minLength: xAxisBottomSpace)
        }
        .allowsHitTesting(false)
    }

    func yAxisLabel(for value: Double) -> String {
        "\(Int(value))%"
    }

    var aboutSection: some View {
        ExpandableInfoCard(
            title: String(localized: "About Burnout"),
            actionCollapsed: String(localized: "Read more"),
            actionExpanded: String(localized: "Show less"),
            bodyText: String(localized: """
Burnout is an occupational phenomenon — not a medical condition.
It results from chronic workplace stress that has not been successfully managed.

According to ICD-11, burnout is characterized by:
• Feelings of energy depletion or exhaustion
• Increased mental distance or cynicism toward work
• Reduced professional efficacy
"""),
            linkTitle: String(localized: "Learn more — World Health Organization (ICD-11)"),
            linkURL: URL(string: "https://www.who.int/standards/classifications/frequently-asked-questions/burn-out-an-occupational-phenomenon")!,
            openURL: { url in openURL(url) }
        )
        .padding(.top, 6)
    }

    var appBackground: some View {
        Color(red: 44/255, green: 30/255, blue: 47/255).ignoresSafeArea()
    }

    func summaryText(answeredDaysCount: Int, workDaysCount: Int) -> String {
        if vm.selectedFilter == .month {
            let format = String(localized: "Answered days: %lld • Work days this month: %lld • Total days: %lld")
            return String(
                format: format,
                locale: Locale.current,
                Int64(answeredDaysCount),
                Int64(workDaysCount),
                Int64(vm.data.count)
            )
        }

        let format = String(localized: "Answered days: %lld • Work days shown: %lld")
        return String(
            format: format,
            locale: Locale.current,
            Int64(answeredDaysCount),
            Int64(workDaysCount)
        )
    }
}

private struct ExpandableInfoCard: View {
    let title: String
    let actionCollapsed: String
    let actionExpanded: String
    let bodyText: String
    let linkTitle: String
    let linkURL: URL
    let openURL: (URL) -> Void

    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        expanded.toggle()
                    }
                } label: {
                    Text(expanded ? actionExpanded : actionCollapsed)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.55))
                }
                .buttonStyle(.plain)
            }

            Text(bodyText)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.75))
                .lineSpacing(3)
                .lineLimit(expanded ? nil : 3)
                .fixedSize(horizontal: false, vertical: true)

            if expanded {
                Button {
                    openURL(linkURL)
                } label: {
                    Text(linkTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(cardGradient)
        )
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

#Preview {
    InsightView()
}
