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
    let imageName: String // 👈 اسم الصورة
    
    enum DimensionType: String, CaseIterable {
        case Efficiency = "Efficiency"
        case Boredom = "Boredom"
        case Exhaustion = "Exhaustion"
    }
}

// MARK: - Dimensions Data
struct DimensionsData {
    static let dimensions: [Dimension] = [
        // 🔥 Burnout Dimension
        Dimension(
            type: .Efficiency,
            questions: [
                "I'm just running on autopilot just to get it done",
                "I feel emotionally drained from my work",
                "I feel used up at the end of the workday",
                "I feel tired when I get up in the morning",
                "Working all day is really a strain for me",
                "I feel burned out from my work",
                "I feel frustrated by my job",
                "I feel I'm working too hard on my job",
                "Working with people directly puts too much stress on me",
                "I feel like I'm at the end of my rope",
                "I have become less interested in my work",
                "I have become less enthusiastic about my work",
                "I have become more cynical about my work",
                "I doubt the significance of my work",
                "I feel less capable at work",
                "I feel less confident about my abilities",
                "I question my professional effectiveness",
                "I feel inadequate in my job role",
                "I struggle to complete tasks efficiently",
                "I feel disconnected from my work purpose"
            ],
            imageName: "Oval_5" // 👈 صورة Burnout
        ),
        
        // 💚 Engagement Dimension
        Dimension(
            type: .Boredom,
            questions: [
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
                "I am passionate about my work",
                "My work challenges me in a positive way",
                "I feel absorbed in my daily tasks",
                "I look forward to each workday",
                "My work energizes me",
                "I feel motivated to exceed expectations",
                "I am fully focused when working",
                "I experience a sense of flow in my work"
            ],
            imageName: "Oval_6" // 👈 صورة Engagement (غيّرها لو تبين)
        ),
        
        // 💜 Wellbeing Dimension
        Dimension(
            type: .Exhaustion,
            questions: [
                "I feel satisfied with my life",
                "I experience positive emotions daily",
                "I have energy throughout the day",
                "I sleep well at night",
                "I feel physically healthy",
                "I maintain good relationships with others",
                "I feel connected to my community",
                "I have a sense of purpose",
                "I manage stress effectively",
                "I take time for self-care",
                "I feel balanced in life",
                "I enjoy leisure activities",
                "I feel optimistic about the future",
                "I have supportive relationships",
                "I feel mentally clear and focused",
                "I maintain healthy boundaries",
                "I feel grateful for what I have",
                "I engage in activities I enjoy",
                "I feel emotionally stable",
                "I have a positive outlook on life"
            ],
            imageName: "Oval_7" // 👈 صورة Wellbeing (غيّرها لو تبين)
        )
    ]
    
    // 👇 دالة تجيب 3 أسئلة اليوم (واحد من كل dimension)
    static func getTodaysQuestions(questionIndex: Int) -> [(dimension: Dimension, question: String)] {
        var todaysQuestions: [(Dimension, String)] = []
        
        for dimension in dimensions {
            // نستخدم modulo عشان نرجع من البداية بعد السؤال 19
            let index = questionIndex % dimension.questions.count
            todaysQuestions.append((dimension, dimension.questions[index]))
        }
        
        return todaysQuestions
    }
}
