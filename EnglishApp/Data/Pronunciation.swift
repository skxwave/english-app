import AVFoundation

@MainActor
final class Pronunciation {
    static let shared = Pronunciation()

    private var player: AVPlayer?

    func play(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        player = AVPlayer(url: url)
        player?.play()
    }
}
