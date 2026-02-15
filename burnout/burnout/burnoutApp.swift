//import SwiftUI
//import SwiftData
//
//@main
//struct burnoutApp: App {
//    @StateObject private var splashViewModel = SplashViewModel()
//
//    init() {
//        UIView.appearance().semanticContentAttribute = .unspecified
//    }
//
//    var body: some Scene {
//        WindowGroup {
//            SplashView(viewModel: splashViewModel)
//        }
//        .modelContainer(for: [QuestionResponse.self, DailyRiskScore.self])    }
//}



import SwiftUI
import SwiftData

@main
struct burnoutApp: App {
    @StateObject private var splashViewModel = SplashViewModel()
    
    init() {
        UIView.appearance().semanticContentAttribute = .unspecified
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView(viewModel: splashViewModel)
                .onAppear {
                    addDummyDataIfNeeded()
                }
        }
        .modelContainer(for: [QuestionResponse.self, DailyRiskScore.self])
    }
    func addDummyDataIfNeeded() {
        let container = try! ModelContainer(for: QuestionResponse.self, DailyRiskScore.self)
        let context = container.mainContext
        
        // ✅ امسحي البيانات القديمة
        let scoreDescriptor = FetchDescriptor<DailyRiskScore>()
        if let scores = try? context.fetch(scoreDescriptor) {
            scores.forEach { context.delete($0) }
        }
        
        let responseDescriptor = FetchDescriptor<QuestionResponse>()
        if let responses = try? context.fetch(responseDescriptor) {
            responses.forEach { context.delete($0) }
        }
        
        try? context.save()
        
        // ✅ ضيفي بيانات جديدة
        var weekCalendar = Calendar.current
        weekCalendar.firstWeekday = 1  // الأحد
        
        let today = Date()
        let weekStart = weekCalendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let dimensions = ["Exhaustion", "Cynicism", "ProfessionalEfficacy"]
        
        // ✅ أضيفي بيانات لكل أيام الأسبوع الحالي
        for dayOffset in 0..<7 {
            guard let date = weekCalendar.date(byAdding: .day, value: dayOffset, to: weekStart) else { continue }
            let dayStart = weekCalendar.startOfDay(for: date)
            
            let riskScore = Double.random(in: 2.0...4.5)
            
            let dailyScore = DailyRiskScore(
                date: dayStart,
                riskScore: riskScore,
                isRiskDay: riskScore >= 3.5
            )
            context.insert(dailyScore)
            
            for dimension in dimensions {
                let response = QuestionResponse(
                    dimensionType: dimension,
                    questionIndex: 0,
                    response: Int.random(in: 1...5),
                    date: dayStart
                )
                context.insert(response)
            }
        }
        
        // ✅ أضيفي بيانات لآخر 30 يوم كمان
        for i in 0..<30 {
            guard let date = weekCalendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let dayStart = weekCalendar.startOfDay(for: date)
            
            // ✅ تأكدي إنه مو مكرر من أيام الأسبوع
            let alreadyExists = (0..<7).contains { offset in
                let weekDay = weekCalendar.date(byAdding: .day, value: offset, to: weekStart)
                return weekCalendar.isDate(dayStart, inSameDayAs: weekDay ?? Date())
            }
            
            if !alreadyExists {
                let riskScore = Double.random(in: 2.0...4.5)
                
                let dailyScore = DailyRiskScore(
                    date: dayStart,
                    riskScore: riskScore,
                    isRiskDay: riskScore >= 3.5
                )
                context.insert(dailyScore)
                
                for dimension in dimensions {
                    let response = QuestionResponse(
                        dimensionType: dimension,
                        questionIndex: 0,
                        response: Int.random(in: 1...5),
                        date: dayStart
                    )
                    context.insert(response)
                }
            }
        }
        
        try? context.save()
    }}
