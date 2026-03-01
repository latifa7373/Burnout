// =========================
//  QuestionsFlowView.swift (UNIFIED)
//  ✅ زر رجوع واحد (Toolbar) + Swipe Back شغال
//  ✅ QuestionView ما فيه زر رجوع
// =========================

import SwiftUI
import SwiftData
import UserNotifications

struct QuestionsFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var dailyRiskScores: [DailyRiskScore]

    @State private var currentQuestionIndex = 0
    @State private var questionIndex = 0
    @State private var todaysQuestions: [(dimension: Dimension, question: String)] = []
    @State private var isComplete = false
    @State private var todayAnswers: [QuestionResponse] = []
    @State private var questionIndices: [Int] = []
    @State private var hasAlreadyAnswered = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(red: 0.18, green: 0.12, blue: 0.22)
                .ignoresSafeArea()

            if hasAlreadyAnswered || isComplete {
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
            // ✅ موحد + أحدث placement
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
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
        let savedIndex = UserDefaults.standard.integer(forKey: "currentQuestionIndex")
        questionIndex = savedIndex

        todaysQuestions = DimensionsData.getTodaysQuestions(questionIndex: questionIndex)

        questionIndices = todaysQuestions.map { item in
            let dimension = item.dimension
            let questionText = item.question
            return dimension.questions.firstIndex(of: questionText) ?? 0
        }

        questionIndex = (questionIndex + 1) % 20
        UserDefaults.standard.set(questionIndex, forKey: "currentQuestionIndex")
    }

    private func saveAnswer(response: Int) {
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

    private func calculateAndSaveTodayRiskScore() {
        guard todayAnswers.count == 3 else {
            print("⚠️ Expected 3 answers, got \(todayAnswers.count)")
            return
        }

        var exhaustionSum = 0.0
        var cynicismSum = 0.0
        var efficiencySum = 0.0
        var exhaustionCount = 0
        var cynicismCount = 0
        var efficiencyCount = 0

        for answer in todayAnswers {
            switch answer.dimensionType {
            case "Efficiency": // Exhaustion
                exhaustionSum += Double(answer.response)
                exhaustionCount += 1
            case "Boredom": // Cynicism
                cynicismSum += Double(answer.response)
                cynicismCount += 1
            case "Exhaustion": // Efficiency (inverted)
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

        let riskEfficacy = efficiencyAvg - 5.0
        let dailyRiskScore = (exhaustionAvg + cynicismAvg + riskEfficacy) / 3.0
        let isRiskDay = dailyRiskScore >= 3.5

        let dailyRisk = DailyRiskScore(
            date: Date(),
            riskScore: dailyRiskScore,
            isRiskDay: isRiskDay
        )

        modelContext.insert(dailyRisk)
        try? modelContext.save()
    }

    private func requestNotificationsIfNeeded(completion: @escaping () -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral, .denied:
                DispatchQueue.main.async { completion() }
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
                    DispatchQueue.main.async { completion() }
                }
            @unknown default:
                DispatchQueue.main.async { completion() }
            }
        }
    }

    private func scheduleMissedCheckInNotification(days: Int = 3) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["missedCheckIn"])

        guard let (hour, minute) = workEndTimeComponents() else { return }

        var date = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
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
        dates.insert(today)

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

        guard let data = defaults.data(forKey: "workDays"),
              let decoded = try? JSONDecoder().decode(Set<Weekday>.self, from: data) else { return }

        let workdays = Set(decoded.map { $0.calendarValue })
        if workdays.isEmpty { return }

        guard let (endHour, endMinute) = workEndTimeComponents() else { return }

        let calendar = Calendar.current
        var date = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()

        while true {
            let weekday = calendar.component(.weekday, from: date)
            if workdays.contains(weekday) { break }
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }

        var target = calendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: date) ?? date
        target = calendar.date(byAdding: .hour, value: 1, to: target) ?? target

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

    private func workEndTimeComponents() -> (Int, Int)? {
        let defaults = UserDefaults.standard

        if let timeString = defaults.string(forKey: "workEndTime") {
            let parts = timeString.split(separator: ":").map { Int($0) ?? 0 }
            if parts.count == 2 { return (parts[0], parts[1]) }
        }

        if let date = defaults.object(forKey: "workEndTime") as? Date {
            let components = Calendar.current.dateComponents([.hour, .minute], from: date)
            guard let hour = components.hour, let minute = components.minute else { return nil }
            return (hour, minute)
        }

        return nil
    }
}

#Preview {
    NavigationStack {
        QuestionsFlowView()
    }
}
