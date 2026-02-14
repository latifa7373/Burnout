import Foundation
import Combine
import AVKit
import AVFoundation

final class SplashViewModel: ObservableObject {
    @Published var isFinished: Bool = false
    let model = SplashModel()

    private(set) var player: AVPlayer?
    private var timer: Timer?
    private var hasStarted = false
    private var playbackObserver: NSObjectProtocol?

    init() {
        // Start immediately so the player exists before the AVPlayerViewController is rendered.
        startIfNeeded()
    }
    
    func startIfNeeded() {
        guard !hasStarted else { return }
        hasStarted = true
        preparePlayerIfNeeded()
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
        if let observer = playbackObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    /// ينشئ AVPlayer مرة واحدة فقط مع إعدادات التشغيل
    private func preparePlayerIfNeeded() {
        guard player == nil else { return }
        guard let path = Bundle.main.path(forResource: model.videoName, ofType: "mp4") else {
            print("⚠️ ما لقيت ملف الفيديو: \(model.videoName).mp4")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        let createdPlayer = AVPlayer(url: url)
        
        // نخلي الفيديو يعيد نفسه (loop)
        playbackObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: createdPlayer.currentItem,
            queue: .main
        ) { [weak createdPlayer] _ in
            createdPlayer?.seek(to: .zero)
            createdPlayer?.play()
        }
        
        createdPlayer.rate = model.videoRate
        createdPlayer.play()
        player = createdPlayer
    }
    
    /// يعدل إعدادات AVPlayerViewController
    func configurePlayerController(_ controller: AVPlayerViewController) {
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
    }
}


