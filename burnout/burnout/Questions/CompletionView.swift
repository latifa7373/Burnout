import SwiftUI

struct CompletionView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // ✅ نفس الخلفية الثابتة (مثل Insight/Question)
            Color(red: 44/255, green: 30/255, blue: 47/255)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header بدون back button (سيتم استخدام toolbar)
                CheckHeader(title: String(localized: "Today's Check"), showBack: false) {
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
                        Text(String(localized: "All done !"))
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)

                        Text(String(localized: "come back"))
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)

                        Text(String(localized: "tomorrow"))
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
                    Text(String(localized: "Done"))
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
        .preferredColorScheme(.dark) // ✅ ثابت دايمًا
    }
}

#Preview {
    NavigationStack {
        CompletionView()
    }
}
