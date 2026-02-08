import SwiftUI

struct WelcomeView: View {
    @State private var name: String = ""
    @State private var currentPage: Int = 1 // 1 = first page, 2 = second page
    @State private var selectedDays: Set<String> = [] // Selected work days
    
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
                
                // Profile Icon
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                
                // Enter your name text - close to icon
                Text("Enter your name")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // Text Field with liquid glass effect
                ZStack {
                    // Background with glass effect
                    RoundedRectangle(cornerRadius: 20)
                        .fill(textFieldBackgroundColor)
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
            
            Spacer()
        }
    }
}

#Preview {
    WelcomeView()
}
