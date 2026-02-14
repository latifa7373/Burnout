import SwiftUI
import SwiftData
import UserNotifications


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
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
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
            calculateAndSaveTodayRiskScore()
            requestNotificationsIfNeeded {
                scheduleMissedCheckInNotification(days: 3)

                if consecutiveCheckInStreakIncludingToday() >= 7 {
                    scheduleSevenDayStreakNotification()
                }

                withAnimation {
                    isComplete = true
                }
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
                // Efficiency Score = 5 - response
                let efficiencyValue = 5.0 - Double(answer.response)
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
    
    private func requestNotificationsIfNeeded(completion: @escaping () -> Void) {
        let key = "hasAskedNotifications"
        if UserDefaults.standard.bool(forKey: key) {
            completion()
            return
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            UserDefaults.standard.set(true, forKey: key)
            if granted {
                scheduleWorkEndNotifications()
            }
            DispatchQueue.main.async {
                completion()
            }
        }

    }
    private func scheduleWorkEndNotifications() {
        let defaults = UserDefaults.standard
        
        guard let timeString = defaults.string(forKey: "workEndTime") else { return }
        let parts = timeString.split(separator: ":").map { Int($0) ?? 0 }
        if parts.count != 2 { return }
        let hour = parts[0]
        let minute = parts[1]
        
        var weekdays: [Int] = []
        if let data = defaults.data(forKey: "workDays"),
           let decoded = try? JSONDecoder().decode(Set<Weekday>.self, from: data) {
            weekdays = decoded.map { $0.calendarValue }
        }
        
        if weekdays.isEmpty { return }
        
        for weekday in weekdays {
            var date = DateComponents()
            date.weekday = weekday
            date.hour = hour
            date.minute = minute
            
            let content = UNMutableNotificationContent()
            content.title = "Work day finished"
            content.body = "Take a minute to check in."
            content.sound = .default
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
            let id = "workEndReminder-\(weekday)"
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
    private func scheduleMissedCheckInNotification(days: Int = 3) {
        let center = UNUserNotificationCenter.current()
        
        // امسح أي إشعار قديم لنفس السبب
        center.removePendingNotificationRequests(withIdentifiers: ["missedCheckIn"])
        
        // وقت الإشعار = بعد 3 أيام على وقت نهاية العمل
        guard let timeString = UserDefaults.standard.string(forKey: "workEndTime") else { return }
        let parts = timeString.split(separator: ":").map { Int($0) ?? 0 }
        if parts.count != 2 { return }
        
        var date = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        let hour = parts[0]
        let minute = parts[1]
        date = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: date) ?? date
        
        let content = UNMutableNotificationContent()
        content.title = "Your patterns matter 👌🏻"
        content.body = "Take a quick moment today to stay ahead of burnout later 🪫"
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: "missedCheckIn", content: content, trigger: trigger)
        center.add(request)
    }
    private func consecutiveCheckInStreakIncludingToday() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var dates = Set(dailyRiskScores.map { calendar.startOfDay(for: $0.date) })
        dates.insert(today) // تأكد أن اليوم محسوب بعد ما حفظنا

        var streak = 0
        var day = today

        while dates.contains(day) {
            streak += 1
            day = calendar.date(byAdding: .day, value: -1, to: day)!
        }

        return streak
    }

    private func scheduleSevenDayStreakNotification() {
        let defaults = UserDefaults.standard

        // أيام الدوام من Welcome
        guard let data = defaults.data(forKey: "workDays"),
              let decoded = try? JSONDecoder().decode(Set<Weekday>.self, from: data) else { return }

        let workdays = Set(decoded.map { $0.calendarValue })
        if workdays.isEmpty { return }

        // وقت نهاية الدوام
        guard let timeString = defaults.string(forKey: "workEndTime") else { return }
        let parts = timeString.split(separator: ":").map { Int($0) ?? 0 }
        if parts.count != 2 { return }
        let endHour = parts[0]
        let endMinute = parts[1]

        let calendar = Calendar.current
        var date = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()

        // نبحث عن "اليوم التالي" اللي يكون يوم دوام
        while true {
            let weekday = calendar.component(.weekday, from: date)
            if workdays.contains(weekday) { break }
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }

        // ضبط الوقت = نهاية الدوام + ساعة
        var target = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: date) ?? date
        target = calendar.date(byAdding: .hour, value: 1, to: target) ?? target

        // لو صار الوقت في يوم غير دوام بسبب +1 ساعة، ننقله لليوم الدوام اللي بعده
        let targetWeekday = calendar.component(.weekday, from: target)
        if !workdays.contains(targetWeekday) {
            var nextDate = calendar.date(byAdding: .day, value: 1, to: target) ?? target
            while true {
                let weekday = calendar.component(.weekday, from: nextDate)
                if workdays.contains(weekday) { break }
                nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate)!
            }
            target = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: nextDate) ?? nextDate
            target = calendar.date(byAdding: .hour, value: 1, to: target) ?? target
        }

        let content = UNMutableNotificationContent()
        content.title = "Showing up for yourself 👏🏻"
        content.body = "A full week of check-ins. Small steps like this protect your energy long-term 🌟"
        content.sound = .default

        let triggerDate = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: target)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: "sevenDayStreak", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    
    
    
}

#Preview {
    NavigationStack {
        QuestionsFlowView()
    }
}
