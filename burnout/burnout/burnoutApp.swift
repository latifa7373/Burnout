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
        
        print("🔵 بدأت الفنكشن")
        
        // ✅ امسحي كل البيانات القديمة أولاً
        let scoreDescriptor = FetchDescriptor<DailyRiskScore>()
        if let scores = try? context.fetch(scoreDescriptor) {
            print("🗑️ مسح \(scores.count) DailyRiskScore")
            scores.forEach { context.delete($0) }
        }
        
        let responseDescriptor = FetchDescriptor<QuestionResponse>()
        if let responses = try? context.fetch(responseDescriptor) {
            print("🗑️ مسح \(responses.count) QuestionResponse")
            responses.forEach { context.delete($0) }
        }
        
        try? context.save()
        
        // ✅ ضيفي بيانات جديدة
        let calendar = Calendar.current
        let today = Date()
        let dimensions = ["Exhaustion", "Cynicism", "ProfessionalEfficacy"]
        
        print("🟢 بداية إضافة 60 يوم")
        
        for i in 0..<60 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let dayStart = calendar.startOfDay(for: date)
            
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
        
        do {
            try context.save()
            print("✅ تم حفظ 60 يوم بنجاح")
        } catch {
            print("❌ فشل الحفظ: \(error)")
        }
    }
}
