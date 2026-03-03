import SwiftUI

struct StatusView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            background
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // Header (نفس Profile بس مرفوع أكثر)
                    HStack {
                        Spacer()
                        Text(String(localized: "Status"))
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, -40)      // ✅ رفعناه لفوق
                    .padding(.bottom, 30)

                    StatusLevelsCard(
                        title: String(localized: "Status"),
                        note: String(localized: "Note : We Provide general insights not a medical diagnosis"),
                        items: [
                            .init(color: .green,
                                  title: String(localized: "Low"),
                                  subtitle: String(localized: "Stable Pattern")),
                            .init(color: .yellow,
                                  title: String(localized: "Medium"),
                                  subtitle: String(localized: "Increased Strain")),
                            .init(color: .red,
                                  title: String(localized: "High"),
                                  subtitle: String(localized: "Elevated Strain"))
                        ]
                    )
                    
                    CalculationStepsCard(
                        title: String(localized: "How Is this caculated"),
                        subtitle: String(localized: "Based on your daily check-ins"),
                        footer: String(localized: "Your Status Changes Only After the same level repeats for 3 days in a row"),
                        steps: [
                            .init(
                                icon: "person.crop.circle",
                                title: String(localized: "3 Daily Question check-in"),
                                detail: String(localized: "Based on your daily check-ins response")
                            ),
                            .init(
                                icon: "chart.line.uptrend.xyaxis",
                                title: String(localized: "Pattern Analysis"),
                                detail: String(localized: "Calculate Daily Average (Q1 + Q2 + Q3) ÷ 3")
                            ),
                            .init(
                                icon: "exclamationmark.triangle",
                                title: String(localized: "Risk Detection"),
                                detail: String(localized: """
We Lable The daily Result As:
*Low : 1-2
*Medium : 2.5-3
*High : 3.5-5
""")
                            )
                        ]
                    )
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 25)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
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
    }
}

// MARK: - UI Parts
private extension StatusView {
    var background: some View {
        LinearGradient(
            colors: [
                Color(red: 0.18, green: 0.12, blue: 0.22),
                Color(red: 0.14, green: 0.10, blue: 0.18)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Shared Card Style
private extension View {
    func statusCardBackground() -> some View {
        self
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.12),
                                Color.white.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
    }
}

// MARK: - Card 1: Levels (Fixed)
private struct StatusLevelsCard: View {
    struct Item: Identifiable {
        let id = UUID()
        let color: Color
        let title: String
        let subtitle: String
    }
    
    let title: String
    let note: String
    let items: [Item]
    
    private let leadingIconWidth: CGFloat = 26
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 20) {
                ForEach(items) { item in
                    LevelRow(
                        dotColor: item.color,
                        title: item.title,
                        subtitle: item.subtitle,
                        leadingIconWidth: leadingIconWidth
                    )
                }
            }
            
            Text(note)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.45))
                .padding(.top, 4)
        }
        .statusCardBackground()
    }
}

private struct LevelRow: View {
    let dotColor: Color
    let title: String
    let subtitle: String
    let leadingIconWidth: CGFloat
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Circle()
                .fill(dotColor)
                .frame(width: 14, height: 14)
                .frame(width: leadingIconWidth, alignment: .leading)
                .offset(y: 2) // ✅ نفس مستوى عنوان Low/Medium/High
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.55))
            }
            
            Spacer()
        }
    }
}

// MARK: - Card 2: Calculation Steps (Fixed)
private struct CalculationStepsCard: View {
    struct Step: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let detail: String
    }
    
    let title: String
    let subtitle: String
    let footer: String
    let steps: [Step]
    
    private let leadingIconWidth: CGFloat = 26
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.45))
            }
            
            VStack(spacing: 12) {
                ForEach(Array(steps.enumerated()), id: \.element.id) { idx, step in
                    StepRow(
                        icon: step.icon,
                        title: step.title,
                        detail: step.detail,
                        leadingIconWidth: leadingIconWidth
                    )
                    
                    if idx != steps.count - 1 {
                        DividerLine()
                    }
                }
            }
            
            Text(footer)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.50))
                .padding(.top, 2)
        }
        .statusCardBackground()
    }
}

private struct StepRow: View {
    let icon: String
    let title: String
    let detail: String
    let leadingIconWidth: CGFloat
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.white.opacity(0.55))
                .frame(width: leadingIconWidth, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(detail)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.55))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

private struct DividerLine: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.10))
            .frame(height: 1)
            .padding(.leading, 38)
    }
}

#Preview {
    NavigationStack {
        StatusView()
    }
}
