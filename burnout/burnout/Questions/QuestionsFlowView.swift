import SwiftUI
import SwiftData

struct QuestionsFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var dailyRiskScores: [DailyRiskScore]
    
    @State private var currentQuestionIndex = 0
    @State private var questionIndex = 0 // مؤشر السؤال الحالي
    @State private var todaysQuestions: [(dimension: Dimension, question: String)] = []
    @State private var isComplete = false
    @State private var todayAnswers: [QuestionResponse] = [] // حفظ إجابات اليوم
    @State private var questionIndices: [Int] = [] // حفظ مؤشرات الأسئلة
    @State private var hasAlreadyAnswered = false // إذا كان المستخدم قد أجاب اليوم
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.18, green: 0.12, blue: 0.22)
                .ignoresSafeArea()
            
            if hasAlreadyAnswered || isComplete {
                // إذا كان المستخدم قد أجاب اليوم أو أكمل الأسئلة، اعرض CompletionView
                CompletionView()
            } else if currentQuestionIndex < todaysQuestions.count {
                QuestionView(
                    dimension: todaysQuestions[currentQuestionIndex].dimension,
                    question: todaysQuestions[currentQuestionIndex].question,
                    onContinue: { response in
                        saveAnswer(response: response)
                        moveToNextQuestion()
                    }
                )
            } else {
                ProgressView()
                    .tint(.white)
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
        .onAppear {
            checkIfAlreadyAnswered()
            if todaysQuestions.isEmpty && !hasAlreadyAnswered {
                setupDailyQuestions()
            }
        }
    }
    
    private func checkIfAlreadyAnswered() {
        let today = Calendar.current.startOfDay(for: Date())
        hasAlreadyAnswered = dailyRiskScores.contains { Calendar.current.startOfDay(for: $0.date) == today }
    }
    
    private func setupDailyQuestions() {
        // نستخدم UserDefaults لحفظ questionIndex
        let savedIndex = UserDefaults.standard.integer(forKey: "currentQuestionIndex")
        questionIndex = savedIndex
        
        todaysQuestions = DimensionsData.getTodaysQuestions(questionIndex: questionIndex)
        
        // حفظ مؤشرات الأسئلة
        questionIndices = todaysQuestions.map { question in
            let dimension = question.dimension
            let questionText = question.question
            if let index = dimension.questions.firstIndex(of: questionText) {
                return index
            }
            return 0
        }
        
        // نزيد المؤشر للاستخدام القادم
        questionIndex = (questionIndex + 1) % 20
        UserDefaults.standard.set(questionIndex, forKey: "currentQuestionIndex")
    }
    
    private func saveAnswer(response: Int) {
        // حفظ الإجابة في SwiftData
        let currentQuestion = todaysQuestions[currentQuestionIndex]
        let questionIdx = questionIndices[currentQuestionIndex]
        
        let questionResponse = QuestionResponse(
            dimensionType: currentQuestion.dimension.type.rawValue,
            questionIndex: questionIdx,
            response: response,
            date: Date()
        )
        
        modelContext.insert(questionResponse)
        todayAnswers.append(questionResponse)
    }
    
    private func moveToNextQuestion() {
        if currentQuestionIndex < todaysQuestions.count - 1 {
            withAnimation {
                currentQuestionIndex += 1
            }
        } else {
            // خلصت كل الأسئلة - نحسب ونحفظ Risk Score
            calculateAndSaveTodayRiskScore()
            
            withAnimation {
                isComplete = true
            }
        }
    }
    
    // حساب وحفظ Risk Score اليومي
    private func calculateAndSaveTodayRiskScore() {
        guard todayAnswers.count == 3 else {
            print("⚠️ Expected 3 answers, got \(todayAnswers.count)")
            return
        }
        
        // حساب المتوسط لكل بعد
        var exhaustionSum = 0.0
        var cynicismSum = 0.0
        var efficiencySum = 0.0
        var exhaustionCount = 0
        var cynicismCount = 0
        var efficiencyCount = 0
        
        for answer in todayAnswers {
            switch answer.dimensionType {
            case "Efficiency": // الانهاك (Exhaustion)
                exhaustionSum += Double(answer.response)
                exhaustionCount += 1
            case "Boredom": // التبلد (Cynicism)
                cynicismSum += Double(answer.response)
                cynicismCount += 1
            case "Exhaustion": // الكفاءة (Efficiency - معكوس)
                // Efficiency Score = 6 - response
                let efficiencyValue = 6.0 - Double(answer.response)
                efficiencySum += efficiencyValue
                efficiencyCount += 1
            default:
                break
            }
        }
        
        let exhaustionAvg = exhaustionCount > 0 ? exhaustionSum / Double(exhaustionCount) : 0.0
        let cynicismAvg = cynicismCount > 0 ? cynicismSum / Double(cynicismCount) : 0.0
        let efficiencyAvg = efficiencyCount > 0 ? efficiencySum / Double(efficiencyCount) : 0.0
        
        // حساب RiskEfficacy = Efficiency - 5
        let riskEfficacy = efficiencyAvg - 5.0
        
        // حساب معدل اليوم = (Exhaustion + Cynicism + RiskEfficacy) / 3
        let dailyRiskScore = (exhaustionAvg + cynicismAvg + riskEfficacy) / 3.0
        
        // تحديد إذا كان يوم خطر (>= 3.5)
        let isRiskDay = dailyRiskScore >= 3.5
        
        // حفظ Daily Risk Score في SwiftData
        let dailyRisk = DailyRiskScore(
            date: Date(),
            riskScore: dailyRiskScore,
            isRiskDay: isRiskDay
        )
        
        modelContext.insert(dailyRisk)
        
        // حفظ التغييرات
        try? modelContext.save()
    }
}

#Preview {
    NavigationStack {
        QuestionsFlowView()
    }
}
