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
            case .mbc: return "green"
            case .sbs: return "orange"
            case .ebs: return "purple"
            case .cbs: return "red"
            case .tbs: return "teal"
            case .other: return "gray"
            }
        }
    }
}

extension RadioStation {
    static let allStations: [RadioStation] = [
        // KBS
        RadioStation(name: "KBS 1Radio", streamURL: "http://serpent0.duckdns.org:8088/kbs1radio.pls", category: .kbs),
        RadioStation(name: "KBS HappyFM", streamURL: "http://serpent0.duckdns.org:8088/kbs2radio.pls", category: .kbs),
        RadioStation(name: "KBS ClassicFM", streamURL: "http://serpent0.duckdns.org:8088/kbsfm.pls", category: .kbs),
        RadioStation(name: "KBS CoolFM", streamURL: "http://serpent0.duckdns.org:8088/kbs2fm.pls", category: .kbs),

        // MBC
        RadioStation(name: "MBC 표준FM 95.9", streamURL: "http://serpent0.duckdns.org:8088/mbcsfm.pls", category: .mbc),
        RadioStation(name: "MBC FM4U 91.9", streamURL: "http://serpent0.duckdns.org:8088/mbcfm.pls", category: .mbc),

        // SBS
        RadioStation(name: "SBS 파워FM", streamURL: "http://serpent0.duckdns.org:8088/sbsfm.pls", category: .sbs),
        RadioStation(name: "SBS 러브FM", streamURL: "http://serpent0.duckdns.org:8088/sbs2fm.pls", category: .sbs),
        RadioStation(name: "SBS 고릴라M", streamURL: "https://radio.bsod.kr/stream/?stn=sbs&ch=dmb", category: .sbs),

        // EBS
        RadioStation(name: "EBS FM", streamURL: "http://ebsonairiosaod.ebs.co.kr/fmradiobandiaod/bandiappaac/playlist.m3u8", category: .ebs),

        // CBS
        RadioStation(name: "CBS 표준FM", streamURL: "https://m-aac.cbs.co.kr/mweb_cbs981/_definst_/cbs981.stream/chunklist.m3u8", category: .cbs),
        RadioStation(name: "CBS 음악FM", streamURL: "https://m-aac.cbs.co.kr/mweb_cbs939/_definst_/cbs939.stream/chunklist.m3u8", category: .cbs),
        RadioStation(name: "CBS JOY4U", streamURL: "https://m-aac.cbs.co.kr/mweb_cbscmc/_definst_/cbscmc.stream/chunklist.m3u8", category: .cbs),

        // TBS
        RadioStation(name: "TBS FM", streamURL: "https://radio.bsod.kr/stream/?stn=tbs&ch=fm", category: .tbs),
        RadioStation(name: "TBS eFM", streamURL: "https://radio.bsod.kr/stream/?stn=tbs&ch=efm", category: .tbs),
    ]

    static func stations(for category: StationCategory) -> [RadioStation] {
        allStations.filter { $0.category == category }
    }
}
