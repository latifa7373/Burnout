import Foundation
import Combine
import AVKit
import AVFoundation

final class SplashViewModel: ObservableObject {
    @Published var isFinished: Bool = false
    let model = SplashModel()
    
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


