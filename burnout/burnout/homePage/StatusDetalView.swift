import SwiftUI

struct StatusDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

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
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    Text("Status")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.top, 4)

                    ExpandableInfoCard(
                        title: "How is this calculated?",
                        actionCollapsed: "Read more",
                        actionExpanded: "Show less",
                        bodyText: """
We ask 3 questions (one per dimension). Each answer is scored from 1 to 5.
We calculate the daily score using the arithmetic mean:

Risk Score = (Q1 + Q2 + Q3) / 3

Then we convert it to a 0–100 scale to match the chart.
If the score goes above 50, the risk starts increasing.
""",
                        linkTitle: "Learn more — WHO (ICD-11)",
                        linkURL: URL(string: "https://www.who.int/standards/classifications/frequently-asked-questions/burn-out-an-occupational-phenomenon")!,
                        openURL: { url in openURL(url) }
                    )

                    ExpandableInfoCard(
                        title: "What does “Low / Medium / High” mean?",
                        actionCollapsed: "Read more",
                        actionExpanded: "Show less",
                        bodyText: """
Low: Your signals are stable.
Medium: Early warning signs—try recovery habits.
High: Strong warning—consider reducing workload and seeking support.
""",
                        linkTitle: "Tips for recovery",
                        linkURL: URL(string: "https://www.who.int/news-room/fact-sheets/detail/mental-health-strengthening-our-response")!,
                        openURL: { url in openURL(url) }
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
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
        }
    }
}


// MARK: - Reusable Expandable Card (نفس ستايل كروت Home)
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


// ✅ Preview الصحيح للصفحة نفسها (بدون ما يعلق على homeView)
#Preview {
    NavigationStack {
        StatusDetailView()
    }
}
