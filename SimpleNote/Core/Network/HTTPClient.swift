import Foundation

enum HTTPError: Error { case badStatus(Int, String) }

struct HTTPClient {
    var baseURL: URL = URL(string: "https://example.com")!   // TODO: set real base in App init
    var session: URLSession = .shared
    var tokenProvider: () -> String? = { nil }

    private func makeRequest(_ route: APIRoute, method: String, body: Data? = nil) -> URLRequest {
        var req = URLRequest(url: baseURL.appendingPathComponent(route.path))
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        if body != nil { req.setValue("application/json", forHTTPHeaderField: "Content-Type") }
        if let token = tokenProvider() { req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        req.httpBody = body
        return req
    }

    private static func throwIfBad(_ response: URLResponse, data: Data) throws {
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw HTTPError.badStatus(http.statusCode, String(data: data, encoding: .utf8) ?? "")
        }
    }

    func get<T: Decodable>(_ route: APIRoute) async throws -> T {
        let req = makeRequest(route, method: "GET")
        let (data, resp) = try await session.data(for: req)
        try Self.throwIfBad(resp, data: data)
        let dec = JSONDecoder(); dec.keyDecodingStrategy = .convertFromSnakeCase
        return try dec.decode(T.self, from: data)
    }

    func post<T: Decodable, B: Encodable>(_ route: APIRoute, body: B) async throws -> T {
        let enc = JSONEncoder()
        let req = makeRequest(route, method: "POST", body: try enc.encode(body))
        let (data, resp) = try await session.data(for: req)
        try Self.throwIfBad(resp, data: data)
        let dec = JSONDecoder(); dec.keyDecodingStrategy = .convertFromSnakeCase
        return try dec.decode(T.self, from: data)
    }
}
