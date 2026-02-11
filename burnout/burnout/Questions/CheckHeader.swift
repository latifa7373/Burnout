//
//  CheckHeader.swift
//  burnout
//
//  Created by Noura Alsbuayt on 21/08/1447 AH.
//

// =========================
//  CheckHeader.swift
// =========================
import SwiftUI

struct CheckHeader: View {
    let title: String
    let showBack: Bool
    let onBack: () -> Void

    var body: some View {
        HStack {
            if showBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                        .imageScale(.large)
                        .frame(width: 44, height: 44, alignment: .leading)
                }
            } else {
                Color.clear.frame(width: 44, height: 44)
            }

            Spacer()

            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.white)

            Spacer()

            // keep title centered
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}
