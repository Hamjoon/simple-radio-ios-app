import Foundation

struct RadioStation: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let streamURL: String
    let category: StationCategory

    enum StationCategory: String, CaseIterable {
        case kbs = "KBS"
        case mbc = "MBC"
        case sbs = "SBS"
        case ebs = "EBS"
        case cbs = "CBS"
        case tbs = "TBS"
        case other = "기타"

        var icon: String {
            switch self {
            case .kbs: return "k.circle.fill"
            case .mbc: return "m.circle.fill"
            case .sbs: return "s.circle.fill"
            case .ebs: return "e.circle.fill"
            case .cbs: return "c.circle.fill"
            case .tbs: return "t.circle.fill"
            case .other: return "radio.fill"
            }
        }

        var color: String {
            switch self {
            case .kbs: return "blue"
            case .mbc: return "purple"
            case .sbs: return "orange"
            case .ebs: return "green"
            case .cbs: return "red"
            case .tbs: return "teal"
            case .other: return "gray"
            }
        }
    }
}

extension RadioStation {
    static let allStations: [RadioStation] = [
        // KBS - radio.bsod.kr proxy (Cloudflare Workers)
        RadioStation(name: "KBS 1Radio", streamURL: "https://radio.bsod.kr/stream/?stn=kbs&ch=1radio", category: .kbs),
        RadioStation(name: "KBS HappyFM", streamURL: "https://radio.bsod.kr/stream/?stn=kbs&ch=2radio", category: .kbs),
        RadioStation(name: "KBS ClassicFM", streamURL: "https://radio.bsod.kr/stream/?stn=kbs&ch=1fm", category: .kbs),
        RadioStation(name: "KBS CoolFM", streamURL: "https://radio.bsod.kr/stream/?stn=kbs&ch=2fm", category: .kbs),

        // MBC - radio.bsod.kr proxy (Cloudflare Workers)
        RadioStation(name: "MBC 표준FM", streamURL: "https://radio.bsod.kr/stream/?stn=mbc&ch=sfm", category: .mbc),
        RadioStation(name: "MBC FM4U", streamURL: "https://radio.bsod.kr/stream/?stn=mbc&ch=fm4u", category: .mbc),

        // SBS - radio.bsod.kr proxy (Cloudflare Workers)
        RadioStation(name: "SBS 파워FM", streamURL: "https://radio.bsod.kr/stream/?stn=sbs&ch=powerfm", category: .sbs),
        RadioStation(name: "SBS 러브FM", streamURL: "https://radio.bsod.kr/stream/?stn=sbs&ch=lovefm", category: .sbs),
        RadioStation(name: "SBS 고릴라디오M", streamURL: "https://radio.bsod.kr/stream/?stn=sbs&ch=dmb", category: .sbs),

        // EBS - radio.bsod.kr proxy (Cloudflare Workers)
        RadioStation(name: "EBS FM", streamURL: "https://radio.bsod.kr/stream/?stn=ebs", category: .ebs),

        // CBS - radio.bsod.kr proxy (Cloudflare Workers)
        RadioStation(name: "CBS 표준FM", streamURL: "https://radio.bsod.kr/stream/?stn=cbs&ch=sfm", category: .cbs),
        RadioStation(name: "CBS 음악FM", streamURL: "https://radio.bsod.kr/stream/?stn=cbs&ch=mfm", category: .cbs),
        RadioStation(name: "CBS JOY4U", streamURL: "https://radio.bsod.kr/stream/?stn=cbs&ch=joy4u", category: .cbs),

        // TBS - radio.bsod.kr proxy (Cloudflare Workers)
        RadioStation(name: "TBS FM", streamURL: "https://radio.bsod.kr/stream/?stn=tbs&ch=fm", category: .tbs),
        RadioStation(name: "TBS eFM", streamURL: "https://radio.bsod.kr/stream/?stn=tbs&ch=efm", category: .tbs),
    ]

    static func stations(for category: StationCategory) -> [RadioStation] {
        allStations.filter { $0.category == category }
    }
}
