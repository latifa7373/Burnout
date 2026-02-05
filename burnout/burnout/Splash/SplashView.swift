import SwiftUI
import AVKit

struct SplashView: View {
    @StateObject private var viewModel = SplashViewModel()

    var body: some View {
        ZStack {
            // الفيديو كخلفية
            VideoBackgroundView(viewModel: viewModel)
                .scaleEffect(viewModel.model.videoScale)
                .offset(x: viewModel.model.videoOffsetX, y: viewModel.model.videoOffsetY)
                .ignoresSafeArea(.all)
            
            // الصورة والنص فوق الفيديو
            VStack(spacing: 20) {
                // الصورة
                Image(viewModel.model.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: viewModel.model.imageWidth, height: viewModel.model.imageHeight)
                
                // النص
                VStack(spacing: 4) {
                    Text(viewModel.model.titleText)
                        .font(.system(size: viewModel.model.titleFontSize, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(viewModel.model.subtitleText)
                        .font(.system(size: viewModel.model.subtitleFontSize, weight: .regular))
                        .italic()
                        .foregroundColor(.white)
                        .offset(y: viewModel.model.subtitleOffsetY)
                }
            }
            .offset(x: viewModel.model.contentOffsetX, y: viewModel.model.contentOffsetY)
        }
    }
}

// View لعرض الفيديو كخلفية
struct VideoBackgroundView: UIViewControllerRepresentable {
    let viewModel: SplashViewModel
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        
        if let player = viewModel.createVideoPlayer() {
            controller.player = player
        }
        
        viewModel.configurePlayerController(controller)
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // لا نحتاج تحديث
    }
}

#Preview {
    SplashView()
}


