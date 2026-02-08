//
//  AlreadyCompletedView.swift
//  burnout
//
//  Created by Noura Alsbuayt on 20/08/1447 AH.
//

import SwiftUI

struct AlreadyCompletedView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 0.3, green: 0.4, blue: 0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Image(systemName: "calendar.badge.checkmark")
                    .font(.system(size: 80))
                    .foregroundStyle(.white)
                
                Text("All Done for Today!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text("You've already completed today's questions")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                
                Text("Come back tomorrow for new questions")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.7))
                
                Button {
                    dismiss()
                } label: {
                    Text("Got it")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(.white.opacity(0.15))
                        )
                }
                .padding(.horizontal, 40)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}
