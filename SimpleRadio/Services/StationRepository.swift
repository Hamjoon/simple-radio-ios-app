import Foundation
import Observation

@Observable
final class StationRepository {
    static let shared = StationRepository()

    private(set) var stations: [RadioStation] = []
    private(set) var isLoading = false
    private(set) var error: String?

    private let cacheFileName = "stations_cache.json"
    private let cacheExpirySeconds: TimeInterval = 24 * 60 * 60 // 24 hours

    private var cacheFileURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent(cacheFileName)
    }

    private var cacheMetaURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("stations_cache_meta.json")
    }

    private init() {
        loadFromCache()
    }

    func loadStations() async {
        await MainActor.run {
            isLoading = true
            error = nil
        }

        // Check if cache is valid
        if isCacheValid() && !stations.isEmpty {
            await MainActor.run {
                isLoading = false
            }
            return
        }

        await refreshStations()
    }

    func refreshStations() async {
        await MainActor.run {
            isLoading = true
            error = nil
        }

        do {
            let browserStations = try await RadioBrowserAPI.shared.fetchKoreanStations()
            let radioStations = browserStations.map { RadioStation(from: $0) }

            await MainActor.run {
                self.stations = radioStations
                self.isLoading = false
                self.error = nil
            }

            saveToCache(radioStations)
        } catch {
            await MainActor.run {
                // Keep existing stations if we have them
                if self.stations.isEmpty {
                    self.error = error.localizedDescription
                }
                self.isLoading = false
            }
        }
    }

    func stations(for category: RadioStation.StationCategory) -> [RadioStation] {
        stations.filter { $0.category == category }
    }

    func station(byUUID uuid: String) -> RadioStation? {
        stations.first { $0.stationuuid == uuid }
    }

    func clearError() {
        error = nil
    }

    // MARK: - Cache Management

    private func loadFromCache() {
        guard FileManager.default.fileExists(atPath: cacheFileURL.path) else {
            return
        }

        do {
            let data = try Data(contentsOf: cacheFileURL)
            let cachedStations = try JSONDecoder().decode([RadioStation].self, from: data)
            stations = cachedStations
        } catch {
            print("Failed to load stations from cache: \(error)")
        }
    }

    private func saveToCache(_ stations: [RadioStation]) {
        do {
            let data = try JSONEncoder().encode(stations)
            try data.write(to: cacheFileURL)

            // Save cache timestamp
            let meta = CacheMeta(timestamp: Date())
            let metaData = try JSONEncoder().encode(meta)
            try metaData.write(to: cacheMetaURL)
        } catch {
            print("Failed to save stations to cache: \(error)")
        }
    }

    private func isCacheValid() -> Bool {
        guard FileManager.default.fileExists(atPath: cacheMetaURL.path) else {
            return false
        }

        do {
            let data = try Data(contentsOf: cacheMetaURL)
            let meta = try JSONDecoder().decode(CacheMeta.self, from: data)
            let elapsed = Date().timeIntervalSince(meta.timestamp)
            return elapsed < cacheExpirySeconds
        } catch {
            return false
        }
    }

    private struct CacheMeta: Codable {
        let timestamp: Date
    }
}
