import SwiftUI
import SwiftData

struct QuestionsFlowView: View {
    @State private var currentQuestionIndex = 0
    @State private var questionIndex = 0 // مؤشر السؤال الحالي
    @State private var todaysQuestions: [(dimension: Dimension, question: String)] = []
    @State private var isComplete = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.18, green: 0.12, blue: 0.22)
                .ignoresSafeArea()
            
            if isComplete {
                CompletionView()
            } else if currentQuestionIndex < todaysQuestions.count {
                QuestionView(
                    dimension: todaysQuestions[currentQuestionIndex].dimension,
                    question: todaysQuestions[currentQuestionIndex].question,
                    onContinue: { response in
                        // حفظ الإجابة هنا لاحقاً
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
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            if todaysQuestions.isEmpty {
                setupDailyQuestions()
            }
        }
    }
    
    private func setupDailyQuestions() {
        // نستخدم UserDefaults لحفظ questionIndex
        let savedIndex = UserDefaults.standard.integer(forKey: "currentQuestionIndex")
        questionIndex = savedIndex
        
        todaysQuestions = DimensionsData.getTodaysQuestions(questionIndex: questionIndex)
        
        // نزيد المؤشر للاستخدام القادم
        questionIndex = (questionIndex + 1) % 20
        UserDefaults.standard.set(questionIndex, forKey: "currentQuestionIndex")
    }
    
    private func moveToNextQuestion() {
        if currentQuestionIndex < todaysQuestions.count - 1 {
            withAnimation {
                currentQuestionIndex += 1
            }
        } else {
            // خلصت كل الأسئلة
            withAnimation {
                isComplete = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        QuestionsFlowView()
    }
}
