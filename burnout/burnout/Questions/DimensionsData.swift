//
//  DimensionsData.swift
//  burnout
//
//  Created by Noura Alsbuayt on 20/08/1447 AH.
//

import SwiftUI
import Foundation

struct Dimension {
    let type: DimensionType
    let questions: [String]
    let imageName: String
    
    enum DimensionType: String, CaseIterable {
        case Efficiency = "Efficiency"
        case Boredom = "Boredom"
        case Exhaustion = "Exhaustion"
    }
}

struct DimensionsData {
    static let dimensions: [Dimension] = [
        // 🔥 Efficiency (الإرهاق العاطفي)
        Dimension(
            type: .Efficiency,
            questions: [
                "By the end of the workday, I feel emotionally exhausted.",
                "My job drains my mental and emotional energy.",
                "I started my workday already feeling tired.",
                "Today's work stress feels more than I can handle.",
                "I feel like I really need a long break from work today.",
                "Even after resting, the feeling of fatigue comes back quickly.",
                "My job is emotionally consuming me.",
                "I feel emotionally drained from my work",
                "I feel used up at the end of the workday",
                "I feel tired when I get up in the morning",
                "Working all day is really a strain for me",
                "I feel burned out from my work",
                "I feel frustrated by my job",
                "I feel I'm working too hard on my job",
                "Working with people directly puts too much stress on me",
                "I feel like I'm at the end of my rope",
                "I struggle to complete tasks efficiently",
                "I feel disconnected from my work purpose",
                "The thought of going to work drains me",
                "I feel overwhelmed by my workload"
            ],
            imageName: "Oval_5"
        ),
        
        // 💙 Boredom (الملل/الانفصال العاطفي)
        Dimension(
            type: .Boredom,
            questions: [
                "My enthusiasm for work today is lower than it used to be.",
                "I've started dealing with my job in a cold, detached way.",
                "I do my tasks without much feeling or care.",
                "I don't care as much about what happens at work anymore.",
                "I feel emotionally detached from my job.",
                "I work on autopilot just to get things done.",
                "Work doesn't mean as much to me as it used to.",
                "I have become less interested in my work",
                "I have become less enthusiastic about my work",
                "I have become more cynical about my work",
                "I doubt the significance of my work",
                "I feel less capable at work",
                "I feel less confident about my abilities",
                "I question my professional effectiveness",
                "I feel inadequate in my job role",
                "I just go through the motions at work",
                "My work feels meaningless",
                "I've lost passion for what I do",
                "I feel disconnected from my colleagues",
                "Nothing at work excites me anymore"
            ],
            imageName: "Oval_6"
        ),
        
        // 💚 Exhaustion (الإنجاز الشخصي - معكوس)
        Dimension(
            type: .Exhaustion,
            questions: [
                "I feel that I achieve important things in my job.",
                "I feel competent in the work I do.",
                "My job makes me feel proud of myself.",
                "My effort at work has real value.",
                "I feel that I make a real contribution where I work.",
                "I am satisfied with my performance at work.",
                "I can handle work challenges in a good and effective way.",
                "I am enthusiastic about my job",
                "My job inspires me",
                "I am eager to go to work in the morning",
                "I feel happy when I am working intensely",
                "I am proud of the work that I do",
                "I am immersed in my work",
                "I get carried away when I am working",
                "Time flies when I am working",
                "I feel strong and vigorous at work",
                "I can continue working for very long periods",
                "At my work, I feel bursting with energy",
                "I find my work full of meaning and purpose",
                "I am passionate about my work"
            ],
            imageName: "Oval_7"
        )
    ]
    
    static func getTodaysQuestions(questionIndex: Int) -> [(dimension: Dimension, question: String)] {
        var todaysQuestions: [(Dimension, String)] = []
        
        for dimension in dimensions {
            let index = questionIndex % dimension.questions.count
            todaysQuestions.append((dimension, dimension.questions[index]))
        }
        
        return todaysQuestions
    }
}
