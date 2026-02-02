import SwiftUI

struct QuestionsView: View {
    @StateObject private var viewModel = QuestionsViewModel()

    var body: some View {
        TabView(selection: $viewModel.currentPage) {
            if let daily = viewModel.todaysQuestions {
                QuestionPageView(
                    text: daily.emotionalQuestion.text,
                    title: "Emotional Exhaustion",
                    dimension: .emotionalExhaustion,
                    selectedValue: viewModel.answer(for: .emotionalExhaustion),
                    onSelectValue: { value in
                        viewModel.setAnswer(for: .emotionalExhaustion, value: value)
                    }
                )
                    .tag(0)

                QuestionPageView(
                    text: daily.depersonalizationQuestion.text,
                    title: "Depersonalization / Detachment",
                    dimension: .depersonalization,
                    selectedValue: viewModel.answer(for: .depersonalization),
                    onSelectValue: { value in
                        viewModel.setAnswer(for: .depersonalization, value: value)
                    }
                )
                    .tag(1)

                QuestionPageView(
                    text: daily.accomplishmentQuestion.text,
                    title: "Personal Accomplishment",
                    dimension: .personalAccomplishment,
                    selectedValue: viewModel.answer(for: .personalAccomplishment),
                    onSelectValue: { value in
                        viewModel.setAnswer(for: .personalAccomplishment, value: value)
                    }
                )
                    .tag(2)
            } else {
                Text("No questions for today")
                    .tag(0)
            }
        }
        .tabViewStyle(.page)
    }
}

private struct QuestionPageView: View {
    let text: String
    let title: String
    let dimension: QuestionDimension
    let selectedValue: Int?
    let onSelectValue: (Int) -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text(title)
                .font(.headline)

            Text(text)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()

            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { value in
                    Button {
                        onSelectValue(value)
                    } label: {
                        Text("\(value)")
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(selectedValue == value ? Color.accentColor : Color.gray.opacity(0.2))
                            )
                            .foregroundColor(selectedValue == value ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
    }
}

#Preview {
    QuestionsView()
}


