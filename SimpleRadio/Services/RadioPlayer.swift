import AVFoundation
import MediaPlayer
import Observation

@Observable
final class RadioPlayer {
    static let shared = RadioPlayer()

    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var statusObserver: NSKeyValueObservation?

    private(set) var currentStation: RadioStation?
    private(set) var isPlaying = false
    private(set) var isLoading = false
    private(set) var error: String?

    private var wasPlayingBeforeInterruption = false

    private init() {
        setupAudioSession()
        setupRemoteCommands()
        setupInterruptionHandling()
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
            self.error = "오디오 세션 설정 실패"
        }
    }

    private func setupInterruptionHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    @objc private func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            wasPlayingBeforeInterruption = isPlaying
            pause()
        case .ended:
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else {
                return
            }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) && wasPlayingBeforeInterruption {
                play()
            }
        @unknown default:
            break
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
        info[MPMediaItemPropertyTitle] = currentStation?.name ?? "가리봉 라디오"
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
        error = nil

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
                error = "잘못된 스트림 주소입니다"
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
                    error = "스트림 정보를 찾을 수 없습니다"
                }
            }
        } catch {
            print("Failed to load PLS: \(error)")
            await MainActor.run {
                self.isLoading = false
                self.error = "서버에 연결할 수 없습니다"
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
            error = "잘못된 스트림 주소입니다"
            return
        }

        // Clean up previous observer
        statusObserver?.invalidate()
        statusObserver = nil

        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

        // Monitor AVPlayerItem status
        statusObserver = playerItem?.observe(\.status, options: [.new]) { [weak self] item, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch item.status {
                case .readyToPlay:
                    self.error = nil
                    self.isLoading = false
                case .failed:
                    self.error = item.error?.localizedDescription ?? "재생에 실패했습니다"
                    self.isLoading = false
                    self.isPlaying = false
                case .unknown:
                    break
                @unknown default:
                    break
                }
            }
        }

        player?.play()
        isPlaying = true
        updateNowPlayingInfo()
    }

    func play() {
        error = nil
        player?.play()
        isPlaying = true
        updateNowPlayingInfo()
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func stop() {
        statusObserver?.invalidate()
        statusObserver = nil
        player?.pause()
        player = nil
        playerItem = nil
        currentStation = nil
        isPlaying = false
        isLoading = false
        error = nil
    }

    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    func clearError() {
        error = nil
    }
}
