import Foundation

enum RadioBrowserError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case noServersAvailable

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "잘못된 URL입니다"
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        case .decodingError(let error):
            return "데이터 파싱 오류: \(error.localizedDescription)"
        case .noServersAvailable:
            return "사용 가능한 서버가 없습니다"
        }
    }
}

struct RadioBrowserStation: Codable, Identifiable, Hashable {
    let stationuuid: String
    let name: String
    let url: String
    let urlResolved: String
    let homepage: String?
    let favicon: String?
    let tags: String?
    let country: String?
    let countrycode: String?
    let language: String?
    let codec: String?
    let bitrate: Int?
    let votes: Int?
    let clickcount: Int?

    var id: String { stationuuid }

    enum CodingKeys: String, CodingKey {
        case stationuuid
        case name
        case url
        case urlResolved = "url_resolved"
        case homepage
        case favicon
        case tags
        case country
        case countrycode
        case language
        case codec
        case bitrate
        case votes
        case clickcount
    }
}

actor RadioBrowserAPI {
    static let shared = RadioBrowserAPI()

    private let baseServers = [
        "de2.api.radio-browser.info",
        "fi1.api.radio-browser.info"
    ]

    private var cachedServer: String?
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }

    private func getServer() async throws -> String {
        if let cached = cachedServer {
            return cached
        }

        // Try each server in order until one works
        for server in baseServers {
            let url = URL(string: "https://\(server)/json/stats")!
            do {
                let (_, response) = try await session.data(from: url)
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200 {
                    cachedServer = server
                    return server
                }
            } catch {
                continue
            }
        }

        // Fallback to first server
        cachedServer = baseServers[0]
        return baseServers[0]
    }

    func fetchKoreanStations() async throws -> [RadioBrowserStation] {
        let server = try await getServer()

        guard var components = URLComponents(string: "https://\(server)/json/stations/search") else {
            throw RadioBrowserError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "countrycode", value: "KR"),
            URLQueryItem(name: "limit", value: "200"),
            URLQueryItem(name: "hidebroken", value: "true"),
            URLQueryItem(name: "order", value: "clickcount"),
            URLQueryItem(name: "reverse", value: "true")
        ]

        guard let url = components.url else {
            throw RadioBrowserError.invalidURL
        }

        do {
            let (data, _) = try await session.data(from: url)
            let decoder = JSONDecoder()
            let stations = try decoder.decode([RadioBrowserStation].self, from: data)
            return stations
        } catch let error as DecodingError {
            throw RadioBrowserError.decodingError(error)
        } catch {
            throw RadioBrowserError.networkError(error)
        }
    }

    func searchStations(query: String, countryCode: String = "KR") async throws -> [RadioBrowserStation] {
        let server = try await getServer()

        guard var components = URLComponents(string: "https://\(server)/json/stations/search") else {
            throw RadioBrowserError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "name", value: query),
            URLQueryItem(name: "countrycode", value: countryCode),
            URLQueryItem(name: "limit", value: "100"),
            URLQueryItem(name: "hidebroken", value: "true"),
            URLQueryItem(name: "order", value: "clickcount"),
            URLQueryItem(name: "reverse", value: "true")
        ]

        guard let url = components.url else {
            throw RadioBrowserError.invalidURL
        }

        do {
            let (data, _) = try await session.data(from: url)
            let decoder = JSONDecoder()
            let stations = try decoder.decode([RadioBrowserStation].self, from: data)
            return stations
        } catch let error as DecodingError {
            throw RadioBrowserError.decodingError(error)
        } catch {
            throw RadioBrowserError.networkError(error)
        }
    }

    func recordClick(stationuuid: String) async {
        guard let server = try? await getServer() else { return }
        guard let url = URL(string: "https://\(server)/json/url/\(stationuuid)") else { return }

        // Fire and forget - don't wait for response
        _ = try? await session.data(from: url)
    }

    func getStationByUUID(_ uuid: String) async throws -> RadioBrowserStation? {
        let server = try await getServer()

        guard let url = URL(string: "https://\(server)/json/stations/byuuid/\(uuid)") else {
            throw RadioBrowserError.invalidURL
        }

        do {
            let (data, _) = try await session.data(from: url)
            let decoder = JSONDecoder()
            let stations = try decoder.decode([RadioBrowserStation].self, from: data)
            return stations.first
        } catch let error as DecodingError {
            throw RadioBrowserError.decodingError(error)
        } catch {
            throw RadioBrowserError.networkError(error)
        }
    }
}
