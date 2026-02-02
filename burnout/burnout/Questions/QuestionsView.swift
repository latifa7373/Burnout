import SwiftUI

struct QuestionsView: View {
    @StateObject private var viewModel = QuestionsViewModel()

    var body: some View {
        TabView(selection: $viewModel.currentPage) {
            if let daily = viewModel.todaysQuestions {
                QuestionPageView(text: daily.emotionalQuestion.text, title: "Emotional Exhaustion")
                    .tag(0)

                QuestionPageView(text: daily.depersonalizationQuestion.text, title: "Depersonalization / Detachment")
                    .tag(1)

                QuestionPageView(text: daily.accomplishmentQuestion.text, title: "Personal Accomplishment")
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

    var body: some View {
        VStack(spacing: 24) {
            Text(title)
                .font(.headline)

            Text(text)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }
}

#Preview {
    QuestionsView()
}


