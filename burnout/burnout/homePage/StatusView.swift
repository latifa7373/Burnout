import SwiftUI

struct StatusView: View {
    @Environment(\.dismiss) private var dismiss

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

                    // Header مطابق لصفحة Profile (حجم 22، .bold، متمركز داخل HStack مع نفس الـ paddings)
                    HStack {
                        Spacer()
                        Text(String(localized: "Status"))
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 30)

                    // ✅ Card 1 (NOW ON TOP): What does Low/Medium/High mean?
                    ExpandableInfoCard(
                        title: String(localized: "What does “Low / Medium / High” mean?"),
                        actionCollapsed: String(localized: "Read more"),
                        actionExpanded: String(localized: "Show less"),
                        bodyText: String(localized: """

Low: Your recent responses indicate stable patterns.

Medium : Your recent responses suggest increased strain. Consider healthy recovery habits.

High :Your recent responses indicate elevated strain levels. Consider prioritizing rest and seeking support if needed.

Note : Burn-Out provides general insights and is not a medical diagnosis
""")
                    )

                    // ✅ Card 2 (NOW BELOW): How is this calculated?
                    ExpandableInfoCard(
                        title: String(localized: "How is this calculated?"),
                        actionCollapsed: String(localized: "Read more"),
                        actionExpanded: String(localized: "Show less"),
                        bodyText: String(localized: """
Your answers use a 1–5 scale from Never (1) to Extremely (5)

Each day, you answer 3 questions then we calculate the daily average: 

(Q1 + Q2 + Q3) ÷ 3 

and we label the daily result as:

  * Low: 1–2
  * Medium: 2.5–3
  * High: 3.5–5

Your status changes only after the same level repeats for 3 days in a row. 

""")
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


// MARK: - Reusable Expandable Card (بدون روابط)
private struct ExpandableInfoCard: View {
    let title: String
    let actionCollapsed: String
    let actionExpanded: String
    let bodyText: String

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
    NavigationStack {
        StatusView()
    }
}
