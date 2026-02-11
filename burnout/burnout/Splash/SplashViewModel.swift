import Foundation
import Combine
import AVKit
import AVFoundation

final class SplashViewModel: ObservableObject {
    @Published var isFinished: Bool = false
    let model = SplashModel()
    private var timer: Timer?
    
    init() {
        startTimer()
    }
    
    /// يبدأ Timer لمدة 3 ثواني ثم ينهي شاشة Splash
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.isFinished = true
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    /// ينشئ AVPlayer للفيديو مع إعدادات التشغيل
    func createVideoPlayer() -> AVPlayer? {
        guard let path = Bundle.main.path(forResource: model.videoName, ofType: "mp4") else {
            print("⚠️ ما لقيت ملف الفيديو: \(model.videoName).mp4")
            return nil
        }
        
        let url = URL(fileURLWithPath: path)
        let player = AVPlayer(url: url)
        
        // نخلي الفيديو يعيد نفسه (loop)
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak player] _ in
            player?.seek(to: .zero)
            player?.play()
        }
        
        player.rate = model.videoRate
        player.play()
        
        return player
    }
    
    /// يعدل إعدادات AVPlayerViewController
    func configurePlayerController(_ controller: AVPlayerViewController) {
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
    }
}


