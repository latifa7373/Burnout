import SwiftUI

struct WelcomeView: View {
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
                
                Spacer()
            }
        }
    }
}

#Preview {
    WelcomeView()
}
