import Foundation

struct NetworkClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func get(_ url: URL) async throws -> Data {
        do {
            let (data, response) = try await session.data(from: url)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                throw URLError(.badServerResponse)
            }
            return data
        } catch let error as URLError where error.code.isTransient {
            let (data, response) = try await session.data(from: url)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                throw URLError(.badServerResponse)
            }
            return data
        }
    }
}

private extension URLError.Code {
    var isTransient: Bool {
        switch self {
        case .timedOut,
             .cannotFindHost,
             .cannotConnectToHost,
             .networkConnectionLost,
             .dnsLookupFailed,
             .notConnectedToInternet,
             .internationalRoamingOff,
             .callIsActive,
             .dataNotAllowed,
             .requestBodyStreamExhausted,
             .backgroundSessionRequiresSharedContainer,
             .backgroundSessionInUseByAnotherProcess,
             .backgroundSessionWasDisconnected:
            return true
        default:
            return false
        }
    }
}
