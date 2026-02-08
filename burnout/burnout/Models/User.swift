//
//  User.swift
//  burnout
//
//  Created by Noura Alsbuayt on 17/08/1447 AH.
//


import SwiftData
import Foundation

@Model
class User {
    
    var Name: String
    var WorkDays: String
    var WorkEndTime: Date
    
    @Relationship(deleteRule: .cascade, inverse: \DailySession.User)
    var sessions: [DailySession]
    
    var currentQuestionIndex: Int
    
    init(Name: String, WorkDays: String, WorkEndTime: Date) {
        self.Name = Name
        self.WorkDays = WorkDays
        self.WorkEndTime = WorkEndTime
        self.currentQuestionIndex = 0
        self.sessions = []
    }
}
