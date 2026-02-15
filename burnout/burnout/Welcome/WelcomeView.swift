import SwiftUI

struct WelcomeView: View {
    let onComplete: () -> Void

    @State private var name: String = ""
    @State private var currentPage: Int = 1
    @State private var selectedDays: Set<String> = []
    @State private var workEndTime = Date()

    private var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Colors (مثل ثيم QuestionView)
    private let textFieldBackgroundColor = Color.white.opacity(0.05)
    private let buttonBackgroundColor = Color.white.opacity(0.5)
    private let buttonBorderColor = Color.white.opacity(0.9)

    var body: some View {
        ZStack {
            // ✅ نفس خلفية QuestionView بالضبط
            Color(red: 44/255, green: 30/255, blue: 47/255)
                .ignoresSafeArea()

            if currentPage == 1 {
                firstPageContent
            } else {
                secondPageContent
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    // MARK: - Page 1 Content
    private var firstPageContent: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                Text(String(localized: "Let's get to know\nyou"))
                    .font(.system(size: 35, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 24)
                    .padding(.top, 120)

                Spacer().frame(height: 55)

                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.8),
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: .white.opacity(0.3), radius: 10)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 90, height: 90)

                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }

                Text(String(localized: "Enter your name"))
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(.white)
                    .padding(.top, 20)

                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(textFieldBackgroundColor)
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .glassEffect()
                        }
                        .frame(width: 288, height: 47)

                    TextField(
                        "",
                        text: $name,
                        prompt: Text(String(localized: "Type your name"))
                            .foregroundColor(.white.opacity(0.5))
                            .font(.system(size: 17))
                    )
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .tint(.white)
                    .multilineTextAlignment(.center)
                    .frame(width: 288, height: 47)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                }
                .padding(.top, 30)

                Spacer()
            }

            Button(action: {
                withAnimation { currentPage = 2 }
            }) {
                HStack(spacing: 0) {
                    Spacer().frame(width: 20)

                    Text(String(localized: "Continue"))
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)

                    Rectangle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 1.5)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 40)
                }
                .frame(width: 181, height: 44)
            }
            .disabled(!isNameValid)
            .buttonStyle(.plain)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(!isNameValid ? buttonBackgroundColor.opacity(0.3) : buttonBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(!isNameValid ? buttonBorderColor.opacity(0.3) : buttonBorderColor, lineWidth: 1)
                    )
            }
            .opacity(!isNameValid ? 0.5 : 1.0)
            .padding(.bottom, 48)
        }
    }

    // MARK: - Page 2 Content
    private var secondPageContent: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    withAnimation { currentPage = 1 }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.leading, 25)
                .padding(.top, 10)

                Spacer()
            }

            Text(String(localized: "Select work days"))
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .padding(.top, 25)

            HStack(spacing: 40) {
                ForEach(["Sun", "Mon", "Tue", "Wed"], id: \.self) { day in
                    Circle()
                        .stroke(
                            selectedDays.contains(day) ? Color("LightPurple") : Color("LightPurple").opacity(0.3),
                            lineWidth: 3
                        )
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(WorkDay.localizedName(for: day))
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(selectedDays.contains(day) ? .white : .white.opacity(0.3))
                        )
                        .onTapGesture {
                            if selectedDays.contains(day) { selectedDays.remove(day) }
                            else { selectedDays.insert(day) }
                        }
                }
            }
            .padding(.top, 30)

            HStack(spacing: 40) {
                ForEach(["Thu", "Fri", "Sat"], id: \.self) { day in
                    Circle()
                        .stroke(
                            selectedDays.contains(day) ? Color("LightPurple") : Color("LightPurple").opacity(0.3),
                            lineWidth: 3
                        )
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(WorkDay.localizedName(for: day))
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(selectedDays.contains(day) ? .white : .white.opacity(0.3))
                        )
                        .onTapGesture {
                            if selectedDays.contains(day) { selectedDays.remove(day) }
                            else { selectedDays.insert(day) }
                        }
                }
            }
            .padding(.top, 20)

            Text(String(localized: "Select work end time"))
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .padding(.top, 60)

            DatePicker("", selection: $workEndTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .colorScheme(.dark) // ✅ نخليه غامق عشان يركب مع الثيم
                .frame(width: 304, height: 215)
                .padding(.top, 20)

            Spacer(minLength: 0)

            Button(action: {
                completeOnboarding()
                onComplete()
            }) {
                HStack(spacing: 0) {
                    Text(String(localized: "Let's start"))
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.leading, 20)

                    Rectangle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 1.5)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 40)
                }
                .frame(width: 181, height: 44)
            }
            .disabled(selectedDays.isEmpty)
            .buttonStyle(.plain)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(selectedDays.isEmpty ? buttonBackgroundColor.opacity(0.3) : buttonBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(selectedDays.isEmpty ? buttonBorderColor.opacity(0.3) : buttonBorderColor, lineWidth: 1)
                    )
            }
            .opacity(selectedDays.isEmpty ? 0.5 : 1.0)
            .padding(.bottom, 48)
        }
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(name, forKey: "userName")
        UserDefaults.standard.set(Array(selectedDays), forKey: "workDays")
        UserDefaults.standard.set(workEndTime, forKey: "workEndTime")
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}

#Preview {
    WelcomeView(onComplete: {})
}
