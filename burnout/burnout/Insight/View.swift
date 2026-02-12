import SwiftUI
import Charts
import SwiftData

struct BurnoutChartScreen: View {

    @StateObject private var vm = BurnoutViewModel()
    @Query private var dailyRiskScores: [DailyRiskScore]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var chartScrollResetID = UUID()

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Title
            Text("Burnout Insights")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white.opacity(0.95))
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
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
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
            // Reflect profile changes (work days / work time) immediately.
            vm.updateData(dailyRiskScores)
            chartScrollResetID = UUID()
        }
        .onChange(of: vm.data.count) { _, _ in
            chartScrollResetID = UUID()
        }
    }
}

// MARK: - Small Views
private extension BurnoutChartScreen {

    // MARK: - Chart line styling
    var gridLineStyle: StrokeStyle { StrokeStyle(lineWidth: 1, dash: [4, 4]) }
    var gridLineColor: Color { .white.opacity(0.12) }

    // ✅ عرض العنصر حسب الفترة المختارة
    var chartItemWidth: CGFloat {
        switch vm.selectedFilter {
        case .week:  return 44
        case .month: return 28
        }
    }
    
    // مساحة إضافية للنهاية فقط (تمنع قص آخر label بدون ما تسوي فراغ بالبداية)
    var xAxisTrailingPadding: CGFloat {
        max(24, chartItemWidth)
    }

    var fixedYAxisWidth: CGFloat { 56 } // wider so "Medium" stays on one line
    var xAxisBottomSpace: CGFloat { 26 }
    var plotHeight: CGFloat { 240 - xAxisBottomSpace }

    var chartWidth: CGFloat {
        // Add trailing space so the last day is always fully visible (no leading blank space).
        max((CGFloat(vm.data.count) * chartItemWidth) + xAxisTrailingPadding,
            UIScreen.main.bounds.width - 80)
    }

    // MARK: - Glass Theme
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


    // MARK: - Filter Menu
    var filterMenu: some View {
        Menu {
            ForEach(TimeFilter.allCases, id: \.self) { filter in
                Button(filter.rawValue) { vm.setFilter(filter) }
            }
        } label: {
            HStack(spacing: 8) {
                Text(vm.selectedFilter.rawValue)
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

    // ✅ Controls تظهر فقط في Month (يمين زي التقويم)
    var monthControls: some View {
        HStack {
            Spacer()

            Text(vm.monthTitle)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.90))

            HStack(spacing: 8) {
                Button { vm.prevMonth() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.95))
                        .frame(width: 30, height: 30)
                }
                .background(glassButton(RoundedRectangle(cornerRadius: 10)))

                Button { vm.nextMonth() } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.95))
                        .frame(width: 30, height: 30)
                }
                .background(glassButton(RoundedRectangle(cornerRadius: 10)))
            }
        }
        .padding(.bottom, 6)
    }

    // MARK: - Chart Card
    var chartCard: some View {
        VStack(spacing: 10) {
            HStack {
                let workDaysCount = vm.data.filter { $0.isWorkDay }.count
                let answeredDaysCount = vm.data.filter { $0.hasResponse }.count
                Text(vm.selectedFilter == .month
                     ? "Answered days: \(answeredDaysCount) • Work days this month: \(workDaysCount) • Total days: \(vm.data.count)"
                     : "Answered days: \(answeredDaysCount) • Work days shown: \(workDaysCount)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
            }
            
            // ✅ يطلع فقط وقت Month
            if vm.selectedFilter == .month {
                monthControls
            }

            HStack(alignment: .top, spacing: 8) {

                ScrollView(.horizontal, showsIndicators: false) {
                    chartCore
                        .frame(width: chartWidth, height: 240)
                }
                .id(chartScrollResetID) // reset to leading when data/filter changes

                fixedYAxis
                    .frame(width: fixedYAxisWidth, height: 240)
            }

            // ✅ التوضيح تحت التشارت بشوي
            riskLevelsLegend
                .padding(.top, 8)
        }
        .padding(14)
        .background(glassCard(RoundedRectangle(cornerRadius: 22)))
    }
    
    // ✅ توضيح معنى المستويات
    var riskLevelsLegend: some View {
        HStack(spacing: 20) {
            RiskLevelItem(label: "Low", color: Color(red: 0.30, green: 0.60, blue: 0.60), description: "Normal range")
            RiskLevelItem(label: "Medium", color: Color(red: 1.0, green: 0.65, blue: 0.0), description: "Early warning")
            RiskLevelItem(label: "High", color: Color.red, description: "High risk")
        }
        .padding(.bottom, 2)
    }
    
    // ✅ دالة لتحديد اللون حسب Risk Score مباشرة
    // Low: 1-2, Medium: 2-3.5, High: 3.5-5
    func colorForRiskLevel(_ riskScore: Double) -> Color {
        if riskScore <= 0 {
            return Color.white.opacity(0.3) // لا توجد بيانات
        } else if riskScore < 2.0 {
            // Low: teal (1 إلى أقل من 2)
            return Color(red: 0.30, green: 0.60, blue: 0.60)
        } else if riskScore < 3.5 {
            // Medium: تدرج من teal إلى orange (2 إلى أقل من 3.5)
            let factor = (riskScore - 2.0) / 1.5 // من 0 إلى 1
            return Color(
                red: 0.30 + (1.0 - 0.30) * factor,
                green: 0.60 - (0.60 - 0.65) * factor,
                blue: 0.60 - 0.60 * factor
            )
        } else {
            // High: red (3.5 وأعلى)
            return Color.red
        }
    }
    
    // ✅ دالة لتحويل Risk Score إلى نسبة مئوية للعرض على المحور Y
    func riskScoreToPercentage(_ riskScore: Double) -> Double {
        // Risk Score من 1-5 → تحويل إلى 0-100
        // Low (1-2) → 0-25%
        // Medium (2-3.5) → 25-62.5%
        // High (3.5-5) → 62.5-100%
        if riskScore <= 0 {
            return 0
        } else if riskScore <= 2.0 {
            // Low: 1-2 → 0-25%
            return ((riskScore - 1.0) / 1.0) * 25.0
        } else if riskScore <= 3.5 {
            // Medium: 2-3.5 → 25-62.5%
            return 25.0 + ((riskScore - 2.0) / 1.5) * 37.5
        } else {
            // High: 3.5-5 → 62.5-100%
            return 62.5 + ((riskScore - 3.5) / 1.5) * 37.5
        }
    }

    // ✅ أعمدة = Risk Score من DailyRiskScore مع تدرج لوني
    var chartCore: some View {
        Chart {
            ForEach(Array(vm.data.enumerated()), id: \.element.id) { index, item in
                let riskScore = item.riskScore
                let percentage = riskScoreToPercentage(riskScore)
                // إذا اليوزر جاوب، لازم يبان العمود حتى لو اليوم مو Work day
                let barColor = colorForRiskLevel(riskScore)

                // ✅ نعرض عمود فقط إذا اليوزر جاوب فعليًا في هذا اليوم
                if item.hasResponse {
                    BarMark(
                        x: .value("Index", index),
                        y: .value("Risk Score", percentage)
                    )
                    .foregroundStyle(barColor)
                    .cornerRadius(6)
                }
            }
        }
        .chartYScale(domain: 0...100)
        .chartYAxis {
            // Low = 0-25%, Medium = 25-62.5%, High = 62.5-100%
            AxisMarks(position: .trailing, values: [0, 25, 62.5, 100]) { _ in
                AxisGridLine(stroke: gridLineStyle).foregroundStyle(gridLineColor)
                AxisValueLabel().foregroundStyle(.clear) // إخفاء التسميات لتجنب التكرار
            }
        }
        .chartXAxis {
            switch vm.selectedFilter {
            case .week:
                AxisMarks(values: Array(vm.data.indices)) { value in
                    AxisGridLine(stroke: gridLineStyle)
                        .foregroundStyle(gridLineColor)
                    AxisValueLabel().foregroundStyle(.clear) // نخلي الـ labels مخصصة تحت
                }

            case .month:
                AxisMarks(values: Array(vm.data.indices)) { value in
                    AxisGridLine(stroke: gridLineStyle)
                        .foregroundStyle(gridLineColor)
                    AxisValueLabel().foregroundStyle(.clear) // نخلي الـ labels مخصصة تحت
                }
            }
        }
        .chartPlotStyle {
            $0.background(Color.white.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        // Small symmetric padding so the first bar/label doesn't look "stuck",
        // without introducing a huge blank space at the beginning.
        .chartXScale(range: .plotDimension(padding: 12))
        .overlay(alignment: .bottomLeading) {
            customXAxisLabels
                .padding(.leading, 8)
                .padding(.trailing, xAxisTrailingPadding) // keep last day fully visible
                .padding(.bottom, 6)
        }
        .padding(.bottom, 8)
    }

    // ✅ X-Axis labels custom (to avoid Charts pruning labels)
    var customXAxisLabels: some View {
        HStack(spacing: 0) {
            ForEach(Array(vm.data.indices), id: \.self) { i in
                Text(xLabel(for: i))
                    .foregroundStyle(.white.opacity(0.7))
                    .font(.system(size: 11))
                    .frame(width: chartItemWidth, alignment: .center)
            }
        }
        // Extra trailing space so the last label isn't clipped by the ScrollView edge.
        .padding(.trailing, xAxisTrailingPadding)
        .frame(width: (CGFloat(vm.data.count) * chartItemWidth) + xAxisTrailingPadding, alignment: .leading)
        .allowsHitTesting(false)
    }

    func dayAxisLabel(for hourIndex: Int) -> String {
        switch hourIndex {
        case 0:  return "12 AM"
        case 6:  return "6"
        case 12: return "12 PM"
        case 18: return "6"
        default: return ""
        }
    }

    func xLabel(for index: Int) -> String {
        guard vm.data.indices.contains(index) else { return "" }
        return vm.data[index].label
    }

    var fixedYAxis: some View {
        VStack(spacing: 0) {
            // Low = 0%, Medium = 62.5%, High = 100%
            ForEach([100, 62.5, 0], id: \.self) { v in
                Text(yAxisLabel(for: v))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.65))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .frame(height: plotHeight / 3)
            }
            Spacer(minLength: xAxisBottomSpace)
        }
        .allowsHitTesting(false)
    }
    
    func yAxisLabel(for value: Double) -> String {
        switch value {
        case 0: return "Low"
        case 62.5: return "Medium"
        case 100: return "High"
        default: return ""
        }
    }
    
    // MARK: - ✅ About Section (بنفس ستايل الكروت + Read more)
    var aboutSection: some View {
        ExpandableInfoCard(
            title: "About Burnout",
            actionCollapsed: "Read more",
            actionExpanded: "Show less",
            bodyText: """
Burnout is an occupational phenomenon — not a medical condition.
It results from chronic workplace stress that has not been successfully managed.

According to ICD-11, burnout is characterized by:
• Feelings of energy depletion or exhaustion
• Increased mental distance or cynicism toward work
• Reduced professional efficacy
""",
            linkTitle: "Learn more — World Health Organization (ICD-11)",
            linkURL: URL(string: "https://www.who.int/standards/classifications/frequently-asked-questions/burn-out-an-occupational-phenomenon")!,
            openURL: { url in openURL(url) }
        )
        .padding(.top, 6)
    }

    // ✅ خلفية HEX: #2C1E2F
    var appBackground: some View {
        Color(red: 44/255, green: 30/255, blue: 47/255)
            .ignoresSafeArea()
    }
}

// MARK: - Risk Level Legend Component
private struct RiskLevelItem: View {
    let label: String
    let color: Color
    let description: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white)
                Text(description)
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }
}

// MARK: - Expandable Card Component (✅ يصغر مع النص ثم ينسدل)
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

            // Header
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

            // ✅ النص موجود دائمًا، ويحدد حجم الكارد
            Text(bodyText)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.75))
                .lineSpacing(3)
                .lineLimit(expanded ? nil : 3) // ← هنا يصغر ثم يكبر
                .fixedSize(horizontal: false, vertical: true)

            // الرابط يطلع بعد التوسيع فقط (ويبقى أزرق)
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
    BurnoutChartScreen()
}
