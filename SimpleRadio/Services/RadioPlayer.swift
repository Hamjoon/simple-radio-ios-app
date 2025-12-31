import AVFoundation
import MediaPlayer
import Observation

@Observable
final class RadioPlayer {
    static let shared = RadioPlayer()

    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?

    private(set) var currentStation: RadioStation?
    private(set) var isPlaying = false
    private(set) var isLoading = false

    private init() {
        setupAudioSession()
        setupRemoteCommands()
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    private func setupRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }

        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }
    }

    private func updateNowPlayingInfo() {
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = currentStation?.name ?? "Simple Radio"
        info[MPMediaItemPropertyArtist] = currentStation?.category.rawValue ?? ""
        info[MPNowPlayingInfoPropertyIsLiveStream] = true
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    func play(station: RadioStation) {
        if currentStation?.id == station.id && isPlaying {
            return
        }

        stop()
        currentStation = station
        isLoading = true

        let urlString = station.streamURL

        // Handle PLS playlist files
        if urlString.hasSuffix(".pls") {
            Task {
                await loadPLSAndPlay(urlString: urlString)
            }
        } else {
            playStream(urlString: urlString)
        }
    }

    private func loadPLSAndPlay(urlString: String) async {
        guard let url = URL(string: urlString) else {
            await MainActor.run {
                isLoading = false
            }
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let content = String(data: data, encoding: .utf8),
               let streamURL = parsePLS(content: content) {
                await MainActor.run {
                    playStream(urlString: streamURL)
                }
            } else {
                await MainActor.run {
                    isLoading = false
                }
            }
        } catch {
            print("Failed to load PLS: \(error)")
            await MainActor.run {
                isLoading = false
            }
        }
    }

    private func parsePLS(content: String) -> String? {
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.lowercased().hasPrefix("file1=") {
                return String(trimmed.dropFirst(6))
            }
        }
        return nil
    }

    private func playStream(urlString: String) {
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }

        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

        player?.play()
        isPlaying = true
        isLoading = false
        updateNowPlayingInfo()
    }

    func play() {
        player?.play()
        isPlaying = true
        updateNowPlayingInfo()
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func stop() {
        player?.pause()
        player = nil
        playerItem = nil
        currentStation = nil
        isPlaying = false
        isLoading = false
    }

    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
}
