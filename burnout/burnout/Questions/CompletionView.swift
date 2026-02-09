// =========================
//  CompletionView.swift
// =========================
import SwiftUI

struct CompletionView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(.primary).ignoresSafeArea()

            VStack(spacing: 40) {
                CheckHeader(title: "Today's Check", showBack: true) {
                    dismiss()
                }

                Spacer()

                ZStack {
                    Image("Oval_8")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 370, height: 370)

                    VStack(spacing: 8) {
                        Text("All done !")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundStyle(.white)

                        Text("come back")
                            .font(.system(size: 28, weight: .regular))
                            .foregroundStyle(.white)

                        Text("tomorrow")
                            .font(.system(size: 28, weight: .regular))
                            .foregroundStyle(.white)
                    }
                }

                Spacer()

                Button { dismiss() } label: {
                    Text("Done")
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
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        CompletionView()
    }
}
