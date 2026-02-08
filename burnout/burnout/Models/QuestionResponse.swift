//
//  QuestionResponse.swift
//  burnout
//
//  Created by Noura Alsbuayt on 20/08/1447 AH.
//

import SwiftData
import Foundation

@Model
class QuestionResponse {
    var id: UUID
    var questionId: String // مثل "Burnout_5"
    var dimensionType: String // "Burnout", "Engagement", "Wellbeing"
    var questionIndex: Int // رقم السؤال (0-19)
    var response: Int // الإجابة (1-5)
    var date: Date
    
    var session: DailySession? // 👈 العلاقة العكسية مع DailySession
    
    init(questionId: String,
         dimensionType: String,
         questionIndex: Int,
         response: Int,
         date: Date = Date()) {
        
        self.id = UUID()
        self.questionId = questionId
        self.dimensionType = dimensionType
        self.questionIndex = questionIndex
        self.response = response
        self.date = date
    }
}
