// =========================
//  CompletionView.swift
// =========================
import SwiftUI

struct CompletionView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(.primary)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                CheckHeader(title: "Today's Check", showBack: true) {
                    dismiss()
                }

                Spacer()

                ZStack {
                    Image("Oval_8")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 320, height: 320)
                        .frame(maxWidth: .infinity, alignment: .center)

                    VStack(spacing: 6) {
                        Text("All done !")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)

                        Text("come back")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)

                        Text("tomorrow")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                    .frame(width: 220) // ✅ يثبت النص داخل الدائرة
                }
                .frame(height: 320) // ✅ يمنع أي حركة
                .padding(.vertical, 24)

                Spacer()

                // Button
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
