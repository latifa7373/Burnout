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
    var dimensionType: String
    var questionIndex: Int
    var response: Int
    var date: Date
    
    var session: DailySession?
    
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
