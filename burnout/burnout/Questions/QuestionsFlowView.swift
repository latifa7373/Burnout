import SwiftUI
import SwiftData

struct QuestionsFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \QuestionResponse.date, order: .reverse)
    private var allResponses: [QuestionResponse]

    @State private var isComplete = false
    @State private var hasCompletedToday = false
    @State private var todayQuestionIndex: Int = 0

    @State private var currentQuestion: (dimension: Dimension, question: String)?

    var body: some View {
        Group {
            if hasCompletedToday {
                CompletionView()
            
            } else if let currentQuestion {
                QuestionView(
                    dimension: currentQuestion.dimension,
                    question: currentQuestion.question,
                    onContinue: { response in
                        saveResponse(response, for: currentQuestion.dimension)
                        refreshStateAfterAnswer()
                    }
                )
            } else {
                Text("Loading...")
                    .onAppear { setupFromStoredResponses() }
            }
        }
        .onAppear { setupFromStoredResponses() }
    }

    private func setupFromStoredResponses() {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())

        let todayResponsesAnyIndex = allResponses.filter {
            calendar.isDate($0.date, inSameDayAs: todayStart)
        }

        if let firstToday = todayResponsesAnyIndex.first {
            todayQuestionIndex = firstToday.questionIndex
        } else {
            todayQuestionIndex = nextQuestionIndexFromHistory()
        }

        let todayResponses = todayResponsesAnyIndex.filter { $0.questionIndex == todayQuestionIndex }

        let answered = Set(todayResponses.map { $0.dimensionType })

        if answered.contains("Efficiency"),
           answered.contains("Boredom"),
           answered.contains("Exhaustion") {
            hasCompletedToday = true
            return
        }

        if let nextDim = nextUnansweredDimension(answered: answered) {
            let q = questionFor(dimension: nextDim, questionIndex: todayQuestionIndex)
            currentQuestion = (nextDim, q)
        } else {
            hasCompletedToday = true
        }
    }

    private func nextUnansweredDimension(answered: Set<String>) -> Dimension? {
        for dim in DimensionsData.dimensions {
            if !answered.contains(dim.type.rawValue) {
                return dim
            }
        }
        return nil
    }

    private func questionFor(dimension: Dimension, questionIndex: Int) -> String {
        let idx = questionIndex % dimension.questions.count
        return dimension.questions[idx]
    }

    private func nextQuestionIndexFromHistory() -> Int {
        let calendar = Calendar.current

        let grouped = Dictionary(grouping: allResponses) { r in
            calendar.startOfDay(for: r.date)
        }

        let completedDays: [(day: Date, responses: [QuestionResponse])] = grouped
            .filter { _, responses in
                let dims = Set(responses.map { $0.dimensionType })
                return dims.contains("Efficiency") && dims.contains("Boredom") && dims.contains("Exhaustion")
            }
            .map { ($0.key, $0.value) }
            .sorted { $0.day > $1.day }

        guard let lastCompleted = completedDays.first else { return 0 }

        let lastIndex = lastCompleted.responses.first?.questionIndex ?? 0
        return (lastIndex + 1) % 20
    }

    private func saveResponse(_ response: Int, for dimension: Dimension) {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())

        let alreadyAnswered = allResponses.contains { r in
            calendar.isDate(r.date, inSameDayAs: todayStart)
            && r.questionIndex == todayQuestionIndex
            && r.dimensionType == dimension.type.rawValue
        }
        if alreadyAnswered { return }

        let calculatedRiskScore = calculateRiskScore(
            dimensionType: dimension.type.rawValue,
            response: response
        )

        let questionResponse = QuestionResponse(
            dimensionType: dimension.type.rawValue,
            questionIndex: todayQuestionIndex,
            response: response,
            date: Date(),
            riskscore: calculatedRiskScore
        )

        modelContext.insert(questionResponse)
        try? modelContext.save()
    }

    private func calculateRiskScore(dimensionType: String, response: Int) -> Double {
        switch dimensionType {
        case "Efficiency", "Boredom":
            return Double(response)
        case "Exhaustion":
            return Double(6 - response)
        default:
            return 0.0
        }
    }

    private func refreshStateAfterAnswer() {
        // بعد الحفظ، أعد حساب من البيانات بدل currentSlideIndex
        setupFromStoredResponses()

        // لو اكتمل اليوم الآن، اعرض CompletionView
        if hasCompletedToday {
            withAnimation { isComplete = true }
        }
    }
}
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: QuestionResponse.self,
        configurations: config
    )

    // ✅ بيانات تجريبية (اختياري) عشان يبين أنه ينتقل بين الأبعاد
    // إذا تبين يبدأ من Efficiency بدون أي إجابات: احذفي الإدخالات تحت.
    let calendar = Calendar.current
    let todayStart = calendar.startOfDay(for: Date())
    let ctx = container.mainContext

    // مثال: المستخدم جاوب Efficiency اليوم → المفروض يعرض Boredom الآن
    ctx.insert(
        QuestionResponse(
            dimensionType: "",
            questionIndex: 0,
            response: 3,
            date: todayStart,
            riskscore: 3
        )
    )

    try? ctx.save()

    return NavigationStack {
        QuestionsFlowView()
            .modelContainer(container)
    }
}
