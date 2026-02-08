import SwiftUI

struct WelcomeView: View {
    @State private var name: String = ""
    
    // MARK: - Colors (عدل الألوان من هنا)
    private let textFieldBackgroundColor = Color.white.opacity(0.05)  // لون خلفية حقل الإدخال
    private let buttonBackgroundColor = Color.white.opacity(0.5)     // لون خلفية زر Continue
    private let buttonBorderColor = Color.white.opacity(0.9)          // لون حواف زر Continue
    
    var body: some View {
        ZStack {
            // Background Color
            Color("PrimaryColor")
                .ignoresSafeArea()
            
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
                    print("Continue tapped")
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
    }
}

#Preview {
    WelcomeView()
}
