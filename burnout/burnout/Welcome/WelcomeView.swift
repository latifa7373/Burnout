import SwiftUI

struct WelcomeView: View {
    let onComplete: () -> Void
    
    @State private var name: String = ""
    @State private var currentPage: Int = 1 // 1 = first page, 2 = second page
    @State private var selectedDays: Set<String> = [] // Selected work days
    @State private var workEndTime = Date() // Work end time
    
    // MARK: - Colors (عدل الألوان من هنا)
    private let textFieldBackgroundColor = Color.white.opacity(0.05)  // لون خلفية حقل الإدخال
    private let buttonBackgroundColor = Color.white.opacity(0.5)     // لون خلفية زر Continue
    private let buttonBorderColor = Color.white.opacity(0.9)          // لون حواف زر Continue
    
    var body: some View {
        ZStack {
            // Background Color
            Color("PrimaryColor")
                .ignoresSafeArea()
            
            if currentPage == 1 {
                // Page 1: Name Input
                firstPageContent
            } else {
                // Page 2: Work Days Selection
                secondPageContent
            }
        }
    }
    
    // MARK: - Page 1 Content
    private var firstPageContent: some View {
            
            VStack(spacing: 0) {
                // Title - positioned in upper third
                Text("Let's get to know\nyou")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 120)
                
                // Spacing between title and profile icon
                Spacer()
                    .frame(height: 55)
                
                // صورة البروفايل
                ZStack {
                    // حلقة خارجية متوهجة
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
                    
                    // صورة البروفايل
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
                
                // Enter your name text - close to icon
                Text("Enter your name")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // Text Field with liquid glass effect
                ZStack {
                    // Background with glass effect
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color("LightPurple").opacity(0.2))
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .glassEffect()
                        }
                        .frame(width: 288, height: 47)
                    
                    // Text Field on top
                    ZStack {
                        if name.isEmpty {
                            Text("Type your name")
                                .foregroundColor(.white.opacity(0.5))
                                .font(.system(size: 17))
                        }
                        
                        TextField("", text: $name)
                            .font(.system(size: 17))
                            .foregroundColor(.white)
                            .tint(.white)
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: 288, height: 47)
                }
                .padding(.top, 30)
                
                Spacer()
                    .frame(height: 230)
                
                // Continue Button
                Button(action: {
                    withAnimation {
                        currentPage = 2
                    }
                }) {
                    HStack(spacing: 0) {
                        Text("Continue")
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
                .buttonStyle(.plain)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(buttonBackgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(buttonBorderColor, lineWidth: 1)
                        )
                }
                
                Spacer()
            }
    }
    
    // MARK: - Page 2 Content
    private var secondPageContent: some View {
        VStack(spacing: 0) {
            // Back Button
            HStack {
                Button(action: {
                    withAnimation {
                        currentPage = 1
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }
                .padding(.leading, 25)
                .padding(.top, 10)
                
                Spacer()
            }
            
            // Select work days title
            Text("Select work days")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .padding(.top, 25)
            
            // First row of day buttons (4 circles)
            HStack(spacing: 40) {
                ForEach(["Sun", "Mon", "Tue", "Wed"], id: \.self) { day in
                    Circle()
                        .stroke(
                            selectedDays.contains(day)
                            ? Color("LightPurple")
                            : Color("LightPurple").opacity(0.3),
                            lineWidth: 3
                        )
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(day)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(
                                    selectedDays.contains(day)
                                    ? .white
                                    : .white.opacity(0.3)
                                )
                        )
                        .onTapGesture {
                            if selectedDays.contains(day) {
                                selectedDays.remove(day)
                            } else {
                                selectedDays.insert(day)
                            }
                        }
                }
            }
            .padding(.top, 30)
            
            // Second row of day buttons (3 circles)
            HStack(spacing: 40) {
                ForEach(["Thu", "Fri", "Sat"], id: \.self) { day in
                    Circle()
                        .stroke(
                            selectedDays.contains(day)
                            ? Color("LightPurple")
                            : Color("LightPurple").opacity(0.3),
                            lineWidth: 3
                        )
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(day)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(
                                    selectedDays.contains(day)
                                    ? .white
                                    : .white.opacity(0.3)
                                )
                        )
                        .onTapGesture {
                            if selectedDays.contains(day) {
                                selectedDays.remove(day)
                            } else {
                                selectedDays.insert(day)
                            }
                        }
                }
            }
            .padding(.top, 20)
            
            // Select work end time title
            Text("Select work end time")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .padding(.top, 60)
            
            // Time Picker
            DatePicker("", selection: $workEndTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .colorScheme(.dark)
                .frame(width: 304, height: 215)
                .padding(.top, 20)
            
            Spacer()
                .frame(height: 100)
            
            // Let's start Button
            Button(action: {
                onComplete()
            }) {
                HStack(spacing: 0) {
                    Text("Let's start")
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
            
            Spacer()
        }
    }
}

#Preview {
    WelcomeView(onComplete: {})
}
