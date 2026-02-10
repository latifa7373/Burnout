//
//  burnoutApp.swift
//  burnout
//
//  Created by Noura Alsbuayt on 14/08/1447 AH.
//

import SwiftUI

@main
struct burnoutApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if hasCompletedOnboarding {
                    NavigationStack {
                        homeView()
                    }
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                } else {
                    SplashView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.6), value: hasCompletedOnboarding)
        }
    }
}
