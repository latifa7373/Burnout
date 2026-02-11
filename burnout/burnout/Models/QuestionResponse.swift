//
//  QuestionResponse.swift
//  burnout
//
//  Created by Noura Alsbuayt on 20/08/1447 AH.
//

import Foundation
import SwiftData

@Model
final class QuestionResponse {
    var id: UUID
    var dimensionType: String
    var questionIndex: Int
    var response: Int
    var date: Date
    
    init(
         dimensionType: String,
         questionIndex: Int,
         response: Int,
         date: Date = Date()) {
        
        self.id = UUID()
        self.dimensionType = dimensionType
        self.questionIndex = questionIndex
        self.response = response
        self.date = date
    }
}

// Model لحفظ Risk Score اليومي
@Model
final class DailyRiskScore {
    var id: UUID
    var date: Date
    var riskScore: Double  // معدل اليوم المحسوب من المعادلة
    var isRiskDay: Bool    // إذا كان >= 3.5
    
    init(date: Date = Date(), riskScore: Double, isRiskDay: Bool) {
        self.id = UUID()
        self.date = date
        self.riskScore = riskScore
        self.isRiskDay = isRiskDay
    }
}
