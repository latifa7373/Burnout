// =========================
//  QuestionView.swift
// =========================
import SwiftUI

struct QuestionView: View {
    @Environment(\.dismiss) private var dismiss

    let dimension: Dimension
    let question: String
    let onContinue: (Int) -> Void

    @State private var sliderValue: Double = 3.0

    private var sliderText: String {
        switch Int(sliderValue) {
        case 1: return "Never"
        case 2: return "A Little"
        case 3: return "Somewhat"
        case 4: return "A Lot"
        case 5: return "Extremely"
        default: return "Somewhat"
        }
    }

    var body: some View {
        ZStack {
            Color(.primary).ignoresSafeArea()

            VStack(spacing: 0) {
                CheckHeader(title: "Today's Check", showBack: true) {
                    dismiss()
                }

                Spacer()

                VStack {
                    Text("How much does this describe you?")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    ZStack {
                        Image(dimension.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 370, height: 370)

                        Text(question)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(40)
                    }
                    .padding(.vertical, 30)

                    Text(sliderText)
                        .font(.title)
                        .fontWeight(.regular)
                        .foregroundStyle(.white)
                }

                Spacer()

                VStack(spacing: 20) {
                    CapsuleSlider(
                        value: $sliderValue,
                        range: 1...5,
                        step: 1,
                        trackHeight: 30,
                        thumbSize: 30,
                        trackColor: .white.opacity(0.25),
                        fillColor: .white.opacity(0.0),
                        thumbColor: .white
                    )
                    .padding(.horizontal, 40)

                    Spacer().frame(height: 0) // غيريها 16/24 لتنزيل الزر

                    Button {
                        onContinue(Int(sliderValue))
                    } label: {
                        Text("Continue")
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
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        QuestionView(
            dimension: DimensionsData.dimensions[0],
            question: DimensionsData.dimensions[0].questions[0],
            onContinue: { print("Response:", $0) }
        )
    }
}
