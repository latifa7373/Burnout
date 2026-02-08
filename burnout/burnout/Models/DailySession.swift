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
    var exhaustionScore:Int
    var cynicismScore : Int
    var efficacyScore : Int
    var RiskScore : Double
//    var questionIndex : Int
//    var dimension : String
    
    
    var User: User?
    
    @Relationship(deleteRule: .cascade, inverse: \QuestionResponse.session)
    
    var responses: [QuestionResponse]
    
    init (date : Date = Date(),
          exhaustionScore: Int = 0,
          cynicismScore: Int = 0,
          efficacyScore: Int = 0,
          RiskScore: Double = 0 ,
          /*dimension: String = ""*/){
        
        
        self.id = UUID()
        self.date = date
        self.exhaustionScore = exhaustionScore
        self.cynicismScore = cynicismScore
        self.efficacyScore = efficacyScore
//        self.dimension = dimension
        self.RiskScore = RiskScore
        self.IsCompleted = false
        self.responses = []
        
        
        
    }

}
