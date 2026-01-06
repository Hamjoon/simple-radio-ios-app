import Foundation

struct HourlySchedule: Codable {
    var hourlyStations: [Int: String]  // Hour (0-23) -> Station UUID

    init() {
        hourlyStations = [:]
    }

    func station(for hour: Int) -> RadioStation? {
        guard let stationUUID = hourlyStations[hour] else {
            return nil
        }
        return StationRepository.shared.station(byUUID: stationUUID)
    }

    func stationWithFallback(for hour: Int) -> RadioStation? {
        // Try current hour first
        if let station = station(for: hour) {
            return station
        }

        // Fallback: find the most recent previous hour with a station
        for offset in 1..<24 {
            let previousHour = (hour - offset + 24) % 24
            if let station = station(for: previousHour) {
                return station
            }
        }

        return nil
    }

    mutating func setStation(_ station: RadioStation?, for hour: Int) {
        if let station = station {
            hourlyStations[hour] = station.stationuuid
        } else {
            hourlyStations.removeValue(forKey: hour)
        }
    }

    var hasAnySchedule: Bool {
        !hourlyStations.isEmpty
    }
}

// MARK: - Persistence
extension HourlySchedule {
    private static var fileURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("hourly_schedule_v2.json")
    }

    private static var legacyFileURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("hourly_schedule.json")
    }

    static func load() -> HourlySchedule {
        // Try loading new format first
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                return try JSONDecoder().decode(HourlySchedule.self, from: data)
            } catch {
                print("Failed to load schedule: \(error)")
            }
        }

        // Clean up legacy file if exists (data is incompatible due to name -> UUID change)
        if FileManager.default.fileExists(atPath: legacyFileURL.path) {
            try? FileManager.default.removeItem(at: legacyFileURL)
        }

        return HourlySchedule()
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(self)
            try data.write(to: Self.fileURL)
        } catch {
            print("Failed to save schedule: \(error)")
        }
    }
}
