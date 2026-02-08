//import Foundation
//import Combine
//
//final class QuestionsViewModel: ObservableObject {
//    @Published var currentPage: Int = 0
//    @Published private(set) var todaysQuestions: DailyQuestions?
//    /// answers[dimension] = value from 1...5
//    @Published private(set) var answers: [QuestionDimension: Int] = [:]
//
//    // مؤشرات لكل بُعد علشان ندور على بنك الأسئلة ونعيد من البداية لما يخلص
//    private var emotionalIndex: Int = 0
//    private var depersonalizationIndex: Int = 0
//    private var accomplishmentIndex: Int = 0
//
//    // بنك الأسئلة: ٣ أبعاد، كل واحد له اسئلته (بالإنجليزي)
//    private lazy var emotionalQuestions: [Question] = [
//        Question(
//            text: String(localized: "By the end of the workday, I feel emotionally exhausted.", comment: "Emotional exhaustion question 1"),
//            dimension: .emotionalExhaustion
//        ),
//        Question(
//            text: String(localized: "My job drains my mental and emotional energy.", comment: "Emotional exhaustion question 2"),
//            dimension: .emotionalExhaustion
//        ),
//        Question(
//            text: String(localized: "I started my workday already feeling tired.", comment: "Emotional exhaustion question 3"),
//            dimension: .emotionalExhaustion
//        ),
//        Question(
//            text: String(localized: "Today's work stress feels more than I can handle.", comment: "Emotional exhaustion question 4"),
//            dimension: .emotionalExhaustion
//        ),
//        Question(
//            text: String(localized: "I feel like I really need a long break from work today.", comment: "Emotional exhaustion question 5"),
//            dimension: .emotionalExhaustion
//        ),
//        Question(
//            text: String(localized: "Even after resting, the feeling of fatigue comes back quickly.", comment: "Emotional exhaustion question 6"),
//            dimension: .emotionalExhaustion
//        ),
//        Question(
//            text: String(localized: "My job is emotionally consuming me.", comment: "Emotional exhaustion question 7"),
//            dimension: .emotionalExhaustion
//        )
//    ]
//
//    private lazy var depersonalizationQuestions: [Question] = [
//        Question(
//            text: String(localized: "My enthusiasm for work today is lower than it used to be.", comment: "Depersonalization question 1"),
//            dimension: .depersonalization
//        ),
//        Question(
//            text: String(localized: "I've started dealing with my job in a cold, detached way.", comment: "Depersonalization question 2"),
//            dimension: .depersonalization
//        ),
//        Question(
//            text: String(localized: "I do my tasks without much feeling or care.", comment: "Depersonalization question 3"),
//            dimension: .depersonalization
//        ),
//        Question(
//            text: String(localized: "I don't care as much about what happens at work anymore.", comment: "Depersonalization question 4"),
//            dimension: .depersonalization
//        ),
//        Question(
//            text: String(localized: "I feel emotionally detached from my job.", comment: "Depersonalization question 5"),
//            dimension: .depersonalization
//        ),
//        Question(
//            text: String(localized: "I work on autopilot just to get things done.", comment: "Depersonalization question 6"),
//            dimension: .depersonalization
//        ),
//        Question(
//            text: String(localized: "Work doesn't mean as much to me as it used to.", comment: "Depersonalization question 7"),
//            dimension: .depersonalization
//        )
//    ]
//
//    private lazy var accomplishmentQuestions: [Question] = [
//        Question(
//            text: String(localized: "I feel that I achieve important things in my job.", comment: "Personal accomplishment question 1"),
//            dimension: .personalAccomplishment
//        ),
//        Question(
//            text: String(localized: "I feel competent in the work I do.", comment: "Personal accomplishment question 2"),
//            dimension: .personalAccomplishment
//        ),
//        Question(
//            text: String(localized: "My job makes me feel proud of myself.", comment: "Personal accomplishment question 3"),
//            dimension: .personalAccomplishment
//        ),
//        Question(
//            text: String(localized: "My effort at work has real value.", comment: "Personal accomplishment question 4"),
//            dimension: .personalAccomplishment
//        ),
//        Question(
//            text: String(localized: "I feel that I make a real contribution where I work.", comment: "Personal accomplishment question 5"),
//            dimension: .personalAccomplishment
//        ),
//        Question(
//            text: String(localized: "I am satisfied with my performance at work.", comment: "Personal accomplishment question 6"),
//            dimension: .personalAccomplishment
//        ),
//        Question(
//            text: String(localized: "I can handle work challenges in a good and effective way.", comment: "Personal accomplishment question 7"),
//            dimension: .personalAccomplishment
//        )
//    ]
//
//    init() {
//        generateDailyQuestionsIfNeeded()
//    }
//
//    /// يولد أسئلة اليوم (سؤال واحد من كل بُعد) ويدوّر على بنك الأسئلة إذا خلص
//    func generateDailyQuestionsIfNeeded(for date: Date = Date()) {
//        // في النسخة البسيطة: نولد كل مرة تُستدعى بدون تخزين دائم للتاريخ
//        let emotional = nextQuestion(from: &emotionalQuestions, index: &emotionalIndex)
//        let depersonalization = nextQuestion(from: &depersonalizationQuestions, index: &depersonalizationIndex)
//        let accomplishment = nextQuestion(from: &accomplishmentQuestions, index: &accomplishmentIndex)
//
//        todaysQuestions = DailyQuestions(
//            date: date,
//            emotionalQuestion: emotional,
//            depersonalizationQuestion: depersonalization,
//            accomplishmentQuestion: accomplishment
//        )
//
//        // نرجع نفضّي إجابات اليوم (تبدأ فاضية)
//        answers = [:]
//        currentPage = 0
//    }
//
//    /// تخزين إجابة المستخدم لبعد معيّن (من 1 إلى 5)
//    func setAnswer(for dimension: QuestionDimension, value: Int) {
//        let clampedValue = max(1, min(5, value))
//        answers[dimension] = clampedValue
//    }
//
//    /// جلب الإجابة الحالية لبعد معيّن (إن وجدت)
//    func answer(for dimension: QuestionDimension) -> Int? {
//        answers[dimension]
//    }
//
//    /// يرجع السؤال التالي من قائمة بُعد معيّن، ويعيد من البداية لما يخلص البنك
//    private func nextQuestion(from bank: inout [Question], index: inout Int) -> Question {
//        if bank.isEmpty {
//            fatalError("Questions bank should not be empty")
//        }
//
//        if index >= bank.count {
//            // خلصنا كل الأسئلة: نعيد المؤشر ونخلط القائمة لعشوائية جديدة
//            index = 0
//            bank.shuffle()
//        }
//
//        let question = bank[index]
//        index += 1
//        return question
//    }
//}
