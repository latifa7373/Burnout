//
//  QuestionsFlowView.swift
//  burnout
//
//  Created by Noura Alsbuayt on 20/08/1447 AH.
//

import SwiftUI
import SwiftData

struct QuestionsFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    
    @State private var currentSlideIndex = 0
    @State private var todaysQuestions: [(dimension: Dimension, question: String)] = []
    @State private var isComplete = false
    @State private var hasCompletedToday = false
    @State private var currentSession: DailySession?
    
    var body: some View {
        Group {
            if hasCompletedToday {
                AlreadyCompletedView()
            } else if isComplete {
                CompletionView()
            } else if currentSlideIndex < todaysQuestions.count {
                QuestionView(
                    dimension: todaysQuestions[currentSlideIndex].dimension,
                    question: todaysQuestions[currentSlideIndex].question,
                    questionNumber: currentSlideIndex + 1,
                    totalQuestions: todaysQuestions.count,
                    onContinue: { response in
                        saveResponse(response)
                        moveToNextQuestion()
                    }
                )
            } else {
                Text("Loading...")
                    .onAppear {
                        setupDailyQuestions()
                    }
            }
        }
        .onAppear {
            setupDailyQuestions()
        }
    }
    
    // MARK: - Setup Daily Questions
    private func setupDailyQuestions() {
        guard let user = users.first else {
            print("❌ No user found")
            return
        }
        
        if Calendar.current.isDateInToday(user.lastCompletedDate) {
            hasCompletedToday = true
            print("✅ Already completed today")
            return
        }
        
        todaysQuestions = DimensionsData.getTodaysQuestions(questionIndex: user.currentQuestionIndex)
        
        let today = Calendar.current.startOfDay(for: Date())
        currentSession = DailySession(date: today)
        currentSession?.User = user
        modelContext.insert(currentSession!)
        
        print("📝 Loaded \(todaysQuestions.count) questions for today")
        print("📊 Current question index: \(user.currentQuestionIndex)")
    }
    
    // MARK: - Save Response
    private func saveResponse(_ response: Int) {
        guard let user = users.first,
              let session = currentSession else {
            print("❌ No user or session")
            return
        }
        
        let currentQ = todaysQuestions[currentSlideIndex]
        
        let questionResponse = QuestionResponse(
            questionId: "\(currentQ.dimension.type.rawValue)_\(user.currentQuestionIndex)",
            dimensionType: currentQ.dimension.type.rawValue,
            questionIndex: user.currentQuestionIndex,
            response: response,
            date: Date()
        )
        
        questionResponse.session = session
        session.responses.append(questionResponse)
        modelContext.insert(questionResponse)
        
        try? modelContext.save()
        
        print("✅ Saved: \(currentQ.dimension.type.rawValue) - Response: \(response)")
    }
    
    // MARK: - Move to Next Question
    private func moveToNextQuestion() {
        if currentSlideIndex < todaysQuestions.count - 1 {
            print("➡️ Moving to question \(currentSlideIndex + 2)")
            withAnimation {
                currentSlideIndex += 1
            }
        } else {
            print("🎉 All questions completed!")
            completeDaily()
        }
    }
    
    // MARK: - Complete Daily
    private func completeDaily() {
        guard let user = users.first,
              let session = currentSession else {
            print("❌ No user or session")
            return
        }
        
        user.currentQuestionIndex = (user.currentQuestionIndex + 1) % 20
        user.lastCompletedDate = Date()
        
        session.IsCompleted = true
        
        calculateScores(for: session)
        
        try? modelContext.save()
        
        print("✅ Daily completed! Next question index: \(user.currentQuestionIndex)")
        
        withAnimation {
            isComplete = true
        }
    }
    
    // MARK: - Calculate Scores
    private func calculateScores(for session: DailySession) {
        let efficiencyResponses = session.responses.filter { $0.dimensionType == "Efficiency" }
        session.exhaustionScore = efficiencyResponses.reduce(0) { $0 + $1.response }
        
        let boredomResponses = session.responses.filter { $0.dimensionType == "Boredom" }
        session.cynicismScore = boredomResponses.reduce(0) { $0 + $1.response }
        
        let exhaustionResponses = session.responses.filter { $0.dimensionType == "Exhaustion" }
        session.efficacyScore = exhaustionResponses.reduce(0) { $0 + $1.response }
        
        let totalScore = session.exhaustionScore + session.cynicismScore + session.efficacyScore
        session.RiskScore = Double(totalScore) / 3.0
        
        print("📊 Scores - Exhaustion: \(session.exhaustionScore), Cynicism: \(session.cynicismScore), Efficacy: \(session.efficacyScore), Risk: \(session.RiskScore)")
    }
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: User.self, DailySession.self, QuestionResponse.self,
        configurations: config
    )
    
    let mockUser = User(
        Name: "نورا",
        WorkDays: "الأحد-الخميس",
        WorkEndTime: Date()
    )
    mockUser.currentQuestionIndex = 0
    mockUser.lastCompletedDate = Date.distantPast
    
    container.mainContext.insert(mockUser)
    try? container.mainContext.save()
    
    return NavigationStack {
        QuestionsFlowView()
            .modelContainer(container)
    }
}



