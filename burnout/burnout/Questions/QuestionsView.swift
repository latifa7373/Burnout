//import SwiftUI
//
//struct QuestionsView: View {
//    @StateObject private var viewModel = QuestionsViewModel()
//
//    var body: some View {
//        TabView(selection: $viewModel.currentPage) {
//            if let daily = viewModel.todaysQuestions {
//                QuestionPageView(
//                    text: daily.emotionalQuestion.text,
//                    title: "Emotional Exhaustion",
//                    dimension: .emotionalExhaustion,
//                    selectedValue: viewModel.answer(for: .emotionalExhaustion),
//                    onSelectValue: { value in
//                        viewModel.setAnswer(for: .emotionalExhaustion, value: value)
//                    }
//                )
//                .tag(0)
//
//                QuestionPageView(
//                    text: daily.depersonalizationQuestion.text,
//                    title: "Depersonalization / Detachment",
//                    dimension: .depersonalization,
//                    selectedValue: viewModel.answer(for: .depersonalization),
//                    onSelectValue: { value in
//                        viewModel.setAnswer(for: .depersonalization, value: value)
//                    }
//                )
//                .tag(1)
//
//                QuestionPageView(
//                    text: daily.accomplishmentQuestion.text,
//                    title: "Personal Accomplishment",
//                    dimension: .personalAccomplishment,
//                    selectedValue: viewModel.answer(for: .personalAccomplishment),
//                    onSelectValue: { value in
//                        viewModel.setAnswer(for: .personalAccomplishment, value: value)
//                    }
//                )
//                .tag(2)
//            } else {
//                Text("No questions for today")
//                    .tag(0)
//            }
//        }
//        .tabViewStyle(.page(indexDisplayMode: .never))
//    }
//}
//
//private struct QuestionPageView: View {
//    let text: String
//    let title: String
//    let dimension: QuestionDimension
//    let selectedValue: Int?
//    let onSelectValue: (Int) -> Void
//    
//    @State private var sliderValue: Double = 0.5
//    
//    // حساب التوهج بناءً على قرب السلايدر من المنتصف
//    private var glowIntensity: Double {
//        let distanceFromCenter = abs(sliderValue - 0.5)
//        let intensity = 1.0 - (distanceFromCenter * 2)
//        return max(0, intensity)
//    }
//    
//    // تحويل قيمة السلايدر (0-1) إلى قيمة الإجابة (1-5)
//    private var currentValue: Int {
//        Int((sliderValue * 4) + 1)
//    }
//
//    var body: some View {
//        ZStack {
//            // الخلفية
//            Color(hex: "#2D1B3D")
//                .ignoresSafeArea()
//            
//            VStack(spacing: 0) {
//                // Header
//                HStack {
//                    Button(action: {
//                        // العودة للخلف
//                    }) {
//                        Image(systemName: "chevron.left")
//                            .font(.title2)
//                            .foregroundColor(.white)
//                    }
//                    
//                    Spacer()
//                    
//                    Text("Today's Check")
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.white)
//                    
//                    Spacer()
//                    
//                    Color.clear
//                        .frame(width: 30)
//                }
//                .padding(.horizontal, 20)
//                .padding(.top, 10)
//                
//                Spacer()
//                
//                // الدائرة المتوهجة مع النص داخلها
//                ZStack {
//                    // التوهج الخارجي الأول (الأقوى)
//                    Circle()
//                        .fill(
//                            RadialGradient(
//                                colors: [
//                                    getGlowColor(for: dimension).opacity(0.4 * glowIntensity),
//                                    getGlowColor(for: dimension).opacity(0.25 * glowIntensity),
//                                    getGlowColor(for: dimension).opacity(0.1 * glowIntensity),
//                                    Color.clear
//                                ],
//                                center: .center,
//                                startRadius: 80,
//                                endRadius: 200
//                            )
//                        )
//                        .frame(width: 400, height: 400)
//                        .blur(radius: 20)
//                    
//                    // التوهج الخارجي الثاني (أكثر نعومة)
//                    Circle()
//                        .fill(
//                            RadialGradient(
//                                colors: [
//                                    getGlowColor(for: dimension).opacity(0.3 * glowIntensity),
//                                    getGlowColor(for: dimension).opacity(0.15 * glowIntensity),
//                                    Color.clear
//                                ],
//                                center: .center,
//                                startRadius: 60,
//                                endRadius: 160
//                            )
//                        )
//                        .frame(width: 320, height: 320)
//                        .blur(radius: 30)
//                    
//                    // الدائرة الرئيسية
//                    ZStack {
//                        // الدائرة الداخلية
//                        Circle()
//                            .fill(
//                                RadialGradient(
//                                    colors: [
//                                        Color(hex: "#3D2D4D"),
//                                        Color(hex: "#2D1D3D")
//                                    ],
//                                    center: .center,
//                                    startRadius: 0,
//                                    endRadius: 120
//                                )
//                            )
//                            .frame(width: 240, height: 240)
//                        
//                        // حلقة التوهج على حافة الدائرة
//                        Circle()
//                            .stroke(
//                                getGlowColor(for: dimension).opacity(0.6),
//                                lineWidth: 2
//                            )
//                            .frame(width: 240, height: 240)
//                            .blur(radius: 8)
//                        
//                        // نص السؤال داخل الدائرة
//                        Text(text)
//                            .font(.system(size: 20, weight: .regular))
//                            .foregroundColor(.white)
//                            .multilineTextAlignment(.center)
//                            .lineSpacing(2)
//                            .padding(.horizontal, 45)
//                    }
//                    .shadow(
//                        color: getGlowColor(for: dimension).opacity(0.8 * glowIntensity),
//                        radius: 30
//                    )
//                    .shadow(
//                        color: getGlowColor(for: dimension).opacity(0.5 * glowIntensity),
//                        radius: 50
//                    )
//                }
//                
//                Spacer()
//                    .frame(height: 60)
//                
//                // النص أسفل الدائرة (يتغير حسب موقع السلايدر)
//                Text(getSliderLabel())
//                    .font(.system(size: 32, weight: .semibold))
//                    .foregroundColor(.white)
//                    .padding(.bottom, 40)
//                
//                // السلايدر
//                CustomSlider(value: $sliderValue)
//                    .frame(height: 60)
//                    .padding(.horizontal, 40)
//                    .onChange(of: sliderValue) { _, newValue in
//                        // تحديث القيمة عند تحريك السلايدر
//                        let value = Int((newValue * 4) + 1)
//                        onSelectValue(value)
//                    }
//                
//                Spacer()
//                    .frame(height: 60)
//                
//                // زر Next/Done
//                Button(action: {
//                    // الانتقال للسؤال التالي
//                    if let value = selectedValue {
//                        onSelectValue(value)
//                    }
//                }) {
//                    Text(dimension == .personalAccomplishment ? "Done" : "Next")
//                        .font(.system(size: 22, weight: .medium))
//                        .foregroundColor(Color(hex: "#2D1B3D"))
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 60)
//                        .background(
//                            Capsule()
//                                .fill(Color.white.opacity(0.85))
//                        )
//                }
//                .padding(.horizontal, 40)
//                
//                Spacer()
//                    .frame(height: 40)
//            }
//        }
//        .animation(.easeInOut(duration: 0.3), value: glowIntensity)
//        .onAppear {
//            // تعيين قيمة السلايدر الابتدائية إذا كانت هناك إجابة محفوظة
//            if let value = selectedValue {
//                sliderValue = Double(value - 1) / 4.0
//            }
//        }
//    }
//    
//    // دالة للحصول على لون التوهج حسب البعد
//    private func getGlowColor(for dimension: QuestionDimension) -> Color {
//        switch dimension {
//        case .emotionalExhaustion:
//            return Color(hex: "#D4A574") // برتقالي/بيج
//        case .depersonalization:
//            return Color(hex: "#7B8FDB") // أزرق بنفسجي
//        case .personalAccomplishment:
//            return Color(hex: "#6BBAAE") // أخضر فيروزي
//        }
//    }
//    
//    // دالة للحصول على نص السلايدر حسب القيمة
//    private func getSliderLabel() -> String {
//        let value = currentValue
//        switch value {
//        case 1:
//            return "A Little"
//        case 2:
//            return "Somewhat"
//        case 3:
//            return "Moderately"
//        case 4:
//            return "Quite a Bit"
//        case 5:
//            return "A Lot"
//        default:
//            return "A Lot"
//        }
//    }
//}
//
//// سلايدر مخصص
//struct CustomSlider: View {
//    @Binding var value: Double
//    @State private var isDragging = false
//    
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack(alignment: .leading) {
//                // خلفية السلايدر
//                Capsule()
//                    .fill(Color.white.opacity(0.3))
//                
//                // الدائرة (Thumb)
//                Circle()
//                    .fill(Color.white)
//                    .frame(width: 50, height: 50)
//                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
//                    .offset(x: CGFloat(value) * (geometry.size.width - 50))
//                    .gesture(
//                        DragGesture(minimumDistance: 0)
//                            .onChanged { gesture in
//                                isDragging = true
//                                let newValue = min(max(0, gesture.location.x - 25), geometry.size.width - 50)
//                                value = Double(newValue / (geometry.size.width - 50))
//                            }
//                            .onEnded { _ in
//                                isDragging = false
//                            }
//                    )
//            }
//        }
//    }
//}
//
//// Extension لدعم Hex Colors
//extension Color {
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 3:
//            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//        case 6:
//            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8:
//            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default:
//            (a, r, g, b) = (255, 0, 0, 0)
//        }
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue: Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//}
//
//#Preview {
//    QuestionsView()
//}
