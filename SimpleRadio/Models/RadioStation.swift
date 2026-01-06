import Foundation

struct RadioStation: Identifiable, Hashable, Codable {
    let stationuuid: String
    let name: String
    let streamURL: String
    let urlResolved: String
    let codec: String?
    let bitrate: Int?
    let favicon: String?
    let tags: String?

    var id: String { stationuuid }

    var category: StationCategory {
        let upperName = name.uppercased()
        let tagsUpper = (tags ?? "").uppercased()

        if upperName.hasPrefix("KBS") || tagsUpper.contains("KBS") {
            return .kbs
        } else if upperName.hasPrefix("MBC") || upperName.contains("MBC") || tagsUpper.contains("MBC") {
            return .mbc
        } else if upperName.hasPrefix("SBS") || tagsUpper.contains("SBS") {
            return .sbs
        } else if upperName.hasPrefix("EBS") || upperName.contains("EBS") || tagsUpper.contains("EBS") {
            return .ebs
        } else if upperName.hasPrefix("CBS") || upperName.contains("CBS") || tagsUpper.contains("CBS") {
            return .cbs
        } else if upperName.hasPrefix("TBS") || upperName.contains("TBS") || tagsUpper.contains("TBS") {
            return .tbs
        } else {
            return .other
        }
    }

    enum StationCategory: String, CaseIterable, Codable {
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

    init(stationuuid: String, name: String, streamURL: String, urlResolved: String, codec: String?, bitrate: Int?, favicon: String?, tags: String?) {
        self.stationuuid = stationuuid
        self.name = name
        self.streamURL = streamURL
        self.urlResolved = urlResolved
        self.codec = codec
        self.bitrate = bitrate
        self.favicon = favicon
        self.tags = tags
    }

    init(from browserStation: RadioBrowserStation) {
        self.stationuuid = browserStation.stationuuid
        self.name = browserStation.name
        self.streamURL = browserStation.url
        self.urlResolved = browserStation.urlResolved
        self.codec = browserStation.codec
        self.bitrate = browserStation.bitrate
        self.favicon = browserStation.favicon
        self.tags = browserStation.tags
    }
}

extension RadioStation {
    var effectiveStreamURL: String {
        // Prefer resolved URL if available
        if !urlResolved.isEmpty {
            return urlResolved
        }
        return streamURL
    }
}
