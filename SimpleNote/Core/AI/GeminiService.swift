import Foundation

// MARK: - Config
enum GeminiConfig {
    static var apiKey: String {
        if let k = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String, !k.isEmpty { return k }
        if let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
           let dict = NSDictionary(contentsOf: url),
           let k = dict["GEMINI_API_KEY"] as? String, !k.isEmpty { return k }
        return ""
    }
}

// MARK: - Wire format (minimal)
struct GeminiGenerateResponse: Decodable {
    struct Part: Decodable { let text: String? }
    struct Content: Decodable { let parts: [Part]? }
    struct Candidate: Decodable { let content: Content? }
    let candidates: [Candidate]?

    var joinedText: String {
        let all = candidates?.flatMap { $0.content?.parts ?? [] }.compactMap { $0.text } ?? []
        return all.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Service
final class GeminiService {
    private let apiKey: String
    init(apiKey: String) throws {
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NSError(domain: "Gemini", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing Gemini API key"])
        }
        self.apiKey = apiKey
    }

    func generateBody(forTitle title: String) async throws -> String {
        var comps = URLComponents(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent")!
        comps.queryItems = [URLQueryItem(name: "key", value: apiKey)]

        var req = URLRequest(url: comps.url!)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let prompt =
        """
        You are helping write the body for a notes app. Based on the note title: "\(title)".
        Write a concise, friendly note body under ~180 words. Prefer 2–4 short paragraphs or bullet points.
        Return plain text only (no markdown).
        """

        let body: [String: Any] = [
            "contents": [
                ["role": "user", "parts": [["text": prompt]]]
            ]
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        if let http = resp as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            let msg = String(data: data, encoding: .utf8) ?? "Bad response"
            throw NSError(domain: "Gemini", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])
        }

        let decoded = try JSONDecoder().decode(GeminiGenerateResponse.self, from: data)
        let text = decoded.joinedText
        guard !text.isEmpty else {
            throw NSError(domain: "Gemini", code: -2, userInfo: [NSLocalizedDescriptionKey: "Empty AI response"])
        }
        return text
    }
}
