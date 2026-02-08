import SwiftUI

struct CompletionView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // الخلفية
            Color(.primary)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                            .imageScale(.large)
                    }
                    
                    Spacer()
                    
                    Text("Today's Check")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    // مسافة فاضية عشان العنوان يكون في النص
                    Color.clear
                        .frame(width: 44)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
                
                // الدائرة + النص
                ZStack {
                    // الصورة
                    Image("Oval_8")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 370, height: 370)
                    
                    // النص
                    VStack(spacing: 8) {
                        Text("All done !")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundStyle(.white)
                        
                        Text("come back")
                            .font(.system(size: 28, weight: .regular))
                            .foregroundStyle(.white)
                        
                        Text("tomorrow")
                            .font(.system(size: 28, weight: .regular))
                            .foregroundStyle(.white)
                    }
                }
                
                Spacer()
                
                // زر Done
                Button {
                    dismiss()
                } label: {
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
    CompletionView()
}
