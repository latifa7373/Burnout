//
//  burnoutApp.swift
//  burnout
//
//  Created by Noura Alsbuayt on 14/08/1447 AH.
//

import SwiftUI
import SwiftData

@main
struct burnoutApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
        .modelContainer(for: [QuestionResponse.self, DailyRiskScore.self])
    }
}
