//
//  DailySession.swift
//  burnout
//
//  Created by Noura Alsbuayt on 17/08/1447 AH.
//

import SwiftData
import Foundation

@Model
class DailySession {
    
    var id : UUID
    var date : Date
    var IsCompleted: Bool
    var RiskScore : Double

    
    
    var User: User?
    
    var responses: [QuestionResponse]

    init (date : Date = Date(),
          RiskScore: Double = 0 ,
        ){
        self.id = UUID()
        self.date = date
        self.RiskScore = RiskScore
        self.IsCompleted = false
        self.responses = []
        
        
        
    }

}
