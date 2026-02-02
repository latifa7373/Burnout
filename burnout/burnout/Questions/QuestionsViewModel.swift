import Foundation
import Combine

final class QuestionsViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @Published private(set) var todaysQuestions: DailyQuestions?
    /// answers[dimension] = value from 1...5
    @Published private(set) var answers: [QuestionDimension: Int] = [:]

    // مؤشرات لكل بُعد علشان ندور على بنك الأسئلة ونعيد من البداية لما يخلص
    private var emotionalIndex: Int = 0
    private var depersonalizationIndex: Int = 0
    private var accomplishmentIndex: Int = 0

    // بنك الأسئلة: ٣ أبعاد، كل واحد له اسئلته (بالإنجليزي)
    private lazy var emotionalQuestions: [Question] = [
        Question(text: "By the end of the workday, I feel emotionally exhausted.", dimension: .emotionalExhaustion),
        Question(text: "My job drains my mental and emotional energy.", dimension: .emotionalExhaustion),
        Question(text: "I started my workday already feeling tired.", dimension: .emotionalExhaustion),
        Question(text: "Today’s work stress feels more than I can handle.", dimension: .emotionalExhaustion),
        Question(text: "I feel like I really need a long break from work today.", dimension: .emotionalExhaustion),
        Question(text: "Even after resting, the feeling of fatigue comes back quickly.", dimension: .emotionalExhaustion),
        Question(text: "My job is emotionally consuming me.", dimension: .emotionalExhaustion)
    ]

    private lazy var depersonalizationQuestions: [Question] = [
        Question(text: "My enthusiasm for work today is lower than it used to be.", dimension: .depersonalization),
        Question(text: "I’ve started dealing with my job in a cold, detached way.", dimension: .depersonalization),
        Question(text: "I do my tasks without much feeling or care.", dimension: .depersonalization),
        Question(text: "I don’t care as much about what happens at work anymore.", dimension: .depersonalization),
        Question(text: "I feel emotionally detached from my job.", dimension: .depersonalization),
        Question(text: "I work on autopilot just to get things done.", dimension: .depersonalization),
        Question(text: "Work doesn’t mean as much to me as it used to.", dimension: .depersonalization)
    ]

    private lazy var accomplishmentQuestions: [Question] = [
        Question(text: "I feel that I achieve important things in my job.", dimension: .personalAccomplishment),
        Question(text: "I feel competent in the work I do.", dimension: .personalAccomplishment),
        Question(text: "My job makes me feel proud of myself.", dimension: .personalAccomplishment),
        Question(text: "My effort at work has real value.", dimension: .personalAccomplishment),
        Question(text: "I feel that I make a real contribution where I work.", dimension: .personalAccomplishment),
        Question(text: "I am satisfied with my performance at work.", dimension: .personalAccomplishment),
        Question(text: "I can handle work challenges in a good and effective way.", dimension: .personalAccomplishment)
    ]

    init() {
        generateDailyQuestionsIfNeeded()
    }

    /// يولد أسئلة اليوم (سؤال واحد من كل بُعد) ويدوّر على بنك الأسئلة إذا خلص
    func generateDailyQuestionsIfNeeded(for date: Date = Date()) {
        // في النسخة البسيطة: نولد كل مرة تُستدعى بدون تخزين دائم للتاريخ
        let emotional = nextQuestion(from: &emotionalQuestions, index: &emotionalIndex)
        let depersonalization = nextQuestion(from: &depersonalizationQuestions, index: &depersonalizationIndex)
        let accomplishment = nextQuestion(from: &accomplishmentQuestions, index: &accomplishmentIndex)

        todaysQuestions = DailyQuestions(
            date: date,
            emotionalQuestion: emotional,
            depersonalizationQuestion: depersonalization,
            accomplishmentQuestion: accomplishment
        )

        // نرجع نفضّي إجابات اليوم (تبدأ فاضية)
        answers = [:]
        currentPage = 0
    }

    /// تخزين إجابة المستخدم لبعد معيّن (من 1 إلى 5)
    func setAnswer(for dimension: QuestionDimension, value: Int) {
        let clampedValue = max(1, min(5, value))
        answers[dimension] = clampedValue
    }

    /// جلب الإجابة الحالية لبعد معيّن (إن وجدت)
    func answer(for dimension: QuestionDimension) -> Int? {
        answers[dimension]
    }

    /// يرجع السؤال التالي من قائمة بُعد معيّن، ويعيد من البداية لما يخلص البنك
    private func nextQuestion(from bank: inout [Question], index: inout Int) -> Question {
        if bank.isEmpty {
            fatalError("Questions bank should not be empty")
        }

        if index >= bank.count {
            // خلصنا كل الأسئلة: نعيد المؤشر ونخلط القائمة لعشوائية جديدة
            index = 0
            bank.shuffle()
        }

        let question = bank[index]
        index += 1
        return question
    }
}

