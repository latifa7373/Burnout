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
    var questionIndex : Int
    var dimension : String
    
    
    var User: User?
    
    
    init (date : Date = Date(),
        exhaustionScore: Int = 0,
        cynicismScore: Int = 0,
        efficacyScore: Int = 0,
        RiskScore: Double = 0 ,
        questionIndex: Int = 0 ,
        dimension: String = ""){
        
        
        self.id = UUID()
        self.date = date
        self.exhaustionScore = exhaustionScore
        self.cynicismScore = cynicismScore
        self.efficacyScore = efficacyScore
        self.questionIndex = questionIndex
        self.dimension = dimension
        self.RiskScore = RiskScore
        self.IsCompleted = false
        
    }
    

}
