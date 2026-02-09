import SwiftUI

struct QuestionView: View {
    @Environment(\.dismiss) private var dismiss
    
    let dimension: Dimension
    let question: String
//    let onContinue: (Int) -> Void
    
    @State private var sliderValue: Double =  3.0
    
    private var sliderText: String {
        switch Int(sliderValue) {
        case 1: return "Never"
        case 2: return "A Little"
        case 3: return "Somewhat"
        case 4: return "A Lot"
        case 5: return "Extremely"
        default: return "Somewhat"
        }
    }
    
    var body: some View {
        ZStack {
            Color(.primary)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text("Today's Check")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                .padding(.top, 10)
                
                Spacer()
                
                VStack {
                    Text("How much does this describe you?")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    ZStack {
                        Image(dimension.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 370, height: 370)
                        
                        Text(question)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(40)
                    }
                    .padding(.vertical, 30)
                    
                    Text(sliderText)
                        .font(.title)
                        .fontWeight(.regular)
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                VStack(spacing: 20) {
                    // Slider
                    Slider(value: $sliderValue, in: 1...5, step: 1)
                        .accentColor(.white)
                        .padding(.horizontal, 40)
                    
                    // Continue Button
                    Button {
//                        onContinue(Int(sliderValue))
                        (Int(sliderValue))
                    } label: {
                        Text("Continue")
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
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                        .imageScale(.large)
                }
            }
        }
    }
}



#Preview {
    NavigationStack {
        QuestionView(
            dimension: DimensionsData.dimensions[0],
            question: DimensionsData.dimensions[0].questions[0],
//            onContinue: { response in
//                print("Response: \(response)")
            
        )
    }
}
