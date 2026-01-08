import Foundation

struct RadioStation: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let streamURL: String
    let category: StationCategory

    enum StationCategory: String, CaseIterable {
        case focus = "집중/공부"
        case relaxation = "휴식/수면"
        case classical = "클래식"
        case cafe = "카페/라운지"

        var icon: String {
            switch self {
            case .focus: return "brain"
            case .relaxation: return "moon"
            case .classical: return "music.note"
            case .cafe: return "cup.and.saucer"
            }
        }

        var color: String {
            switch self {
            case .focus: return "blue"
            case .relaxation: return "purple"
            case .classical: return "orange"
            case .cafe: return "brown"
            }
        }
    }
}

extension RadioStation {
    static let allStations: [RadioStation] = [
        // Focus - 집중/공부
        RadioStation(name: "RadioNOS Ambient", streamURL: "https://nos.radio.br:443/stream/14/", category: .focus),
        RadioStation(name: "RadioNOS Electronica", streamURL: "https://nos.radio.br:443/stream/7/", category: .focus),
        RadioStation(name: "RadioNOS Chiptune", streamURL: "https://nos.radio.br:443/stream/15/", category: .focus),

        // Relaxation - 휴식/수면
        RadioStation(name: "RadioNOS Relaxing", streamURL: "https://nos.radio.br:443/stream/10/", category: .relaxation),
        RadioStation(name: "RadioNOS New Age", streamURL: "https://nos.radio.br:443/stream/2/", category: .relaxation),

        // Classical - 클래식
        RadioStation(name: "Public Domain Classical", streamURL: "http://relay.publicdomainradio.org/classical.mp3", category: .classical),
        RadioStation(name: "RadioNOS Modern Classical", streamURL: "https://nos.radio.br:443/stream/6/", category: .classical),

        // Cafe - 카페/라운지
        RadioStation(name: "Public Domain Jazz", streamURL: "http://relay.publicdomainradio.org/jazz_swing.mp3", category: .cafe),
        RadioStation(name: "RadioNOS Jazz", streamURL: "https://nos.radio.br:443/stream/3/", category: .cafe),
        RadioStation(name: "RadioNOS Lounge", streamURL: "https://nos.radio.br:443/stream/13/", category: .cafe),
    ]

    static func stations(for category: StationCategory) -> [RadioStation] {
        allStations.filter { $0.category == category }
    }
}
