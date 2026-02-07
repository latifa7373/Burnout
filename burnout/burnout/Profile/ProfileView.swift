import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // خلفية ثابتة باللون المطلوب
            Color(hex: viewModel.model.backgroundColorHex)
                .ignoresSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Text("Profile")
                            .font(.system(size: viewModel.model.headerFontSize, weight: .bold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.toggleEditing()
                            }
                        }) {
                            Image(systemName: viewModel.isEditing ? "checkmark" : "pencil")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(viewModel.isEditing ? .green : .white)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(viewModel.isEditing ? Color.green.opacity(0.2) : Color.white.opacity(0.15))
                                        .background(
                                            Circle()
                                                .fill(.ultraThinMaterial)
                                        )
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                    
                    // صورة البروفايل
                    VStack(spacing: 20) {
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
                                .frame(width: viewModel.model.profileRingSize, height: viewModel.model.profileRingSize)
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
                                .frame(width: viewModel.model.profileImageSize, height: viewModel.model.profileImageSize)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: viewModel.model.profileIconSize))
                                .foregroundColor(.white)
                        }
                        
                        // Name
                        if viewModel.isEditing {
                            TextField("Your name", text: $viewModel.tempUserName)
                                .font(.system(size: viewModel.model.titleFontSize, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 250)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.2))
                                        .background(
                                            Capsule()
                                                .fill(.ultraThinMaterial)
                                        )
                                )
                        } else {
                            Text(viewModel.model.userName)
                                .font(.system(size: viewModel.model.titleFontSize, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.2), radius: 5)
                        }
                    }
                    .padding(.bottom, 40)
                    
                    // بطاقات المعلومات
                    VStack(spacing: 20) {
                        // بطاقة الوقت
                        HStack(spacing: 15) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.25),
                                                Color.white.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: viewModel.model.cardIconSize, height: viewModel.model.cardIconSize)
                                
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("End of Work Time")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                if viewModel.isEditing {
                                    HStack(spacing: 8) {
                                        DatePicker("", selection: $viewModel.tempWorkEndTime, displayedComponents: .hourAndMinute)
                                            .datePickerStyle(.compact)
                                            .labelsHidden()
                                            .colorScheme(.dark)
                                            .accentColor(.blue)
                                        
                                        Image(systemName: "pencil.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white)
                                    }
                                } else {
                                    Text(viewModel.formattedTime(for: viewModel.workEndTime))
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: viewModel.model.cardCornerRadius)
                                .fill(Color.white.opacity(0.12))
                                .background(
                                    RoundedRectangle(cornerRadius: viewModel.model.cardCornerRadius)
                                        .fill(.ultraThinMaterial)
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: viewModel.model.cardCornerRadius)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadUserData()
        }
    }
}

// Extension for Hex color support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ProfileView()
}



