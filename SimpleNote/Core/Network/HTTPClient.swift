import Foundation

enum HTTPError: Error { case badStatus(Int, String) }

struct HTTPClient {
    var baseURL: URL = URL(string: "https://example.com")!   // set real base in App init
    var session: URLSession = .shared
    var tokenProvider: () -> String? = { nil }

    private func url(for route: APIRoute) -> URL {
        var comps = URLComponents(url: baseURL.appendingPathComponent(route.path),
                                  resolvingAgainstBaseURL: false)!
        comps.queryItems = route.queryItems
        return comps.url!
    }

    private func makeRequest(_ route: APIRoute, method: String, body: Data? = nil) -> URLRequest {
        var req = URLRequest(url: url(for: route))
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

    // MARK: Raw (Data) helpers
    func getData(_ route: APIRoute) async throws -> Data {
        let req = makeRequest(route, method: "GET")
        let (data, resp) = try await session.data(for: req)
        try Self.throwIfBad(resp, data: data)
        return data
    }
    func postData<B: Encodable>(_ route: APIRoute, body: B) async throws -> Data {
        let enc = JSONEncoder()
        let req = makeRequest(route, method: "POST", body: try enc.encode(body))
        let (data, resp) = try await session.data(for: req)
        try Self.throwIfBad(resp, data: data)
        return data
    }
    func putData<B: Encodable>(_ route: APIRoute, body: B) async throws -> Data {
        let enc = JSONEncoder()
        let req = makeRequest(route, method: "PUT", body: try enc.encode(body))
        let (data, resp) = try await session.data(for: req)
        try Self.throwIfBad(resp, data: data)
        return data
    }
    func patchData<B: Encodable>(_ route: APIRoute, body: B) async throws -> Data {
        let enc = JSONEncoder()
        let req = makeRequest(route, method: "PATCH", body: try enc.encode(body))
        let (data, resp) = try await session.data(for: req)
        try Self.throwIfBad(resp, data: data)
        return data
    }
    func delete(_ route: APIRoute) async throws {
        let req = makeRequest(route, method: "DELETE")
        let (_, resp) = try await session.data(for: req)
        try Self.throwIfBad(resp, data: Data())
    }

    // MARK: Typed (still available)
    func get<T: Decodable>(_ route: APIRoute) async throws -> T {
        let data = try await getData(route)
        return try decode(T.self, from: data)
    }
    func post<T: Decodable, B: Encodable>(_ route: APIRoute, body: B) async throws -> T {
        let data = try await postData(route, body: body)
        return try decode(T.self, from: data)
    }
    func put<T: Decodable, B: Encodable>(_ route: APIRoute, body: B) async throws -> T {
        let data = try await putData(route, body: body)
        return try decode(T.self, from: data)
    }
    func patch<T: Decodable, B: Encodable>(_ route: APIRoute, body: B) async throws -> T {
        let data = try await patchData(route, body: body)
        return try decode(T.self, from: data)
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        guard !data.isEmpty else {
            // empty body → let callers decide (we handle it in repositories)
            throw DecodingError.dataCorrupted(.init(codingPath: [],
                                                    debugDescription: "Empty body"))
        }
        let dec = JSONDecoder()
        dec.keyDecodingStrategy = .convertFromSnakeCase
        return try dec.decode(T.self, from: data)
    }
}
