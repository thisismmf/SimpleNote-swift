import Foundation

// MARK: DTOs (match your Swagger)
struct LoginRequestDTO: Encodable {
    let username: String        // backend expects "username" even if you pass email
    let password: String
}
struct ChangePasswordRequestDTO: Encodable {
    let old_password: String
    let new_password: String
}
struct LoginResponseDTO: Decodable {
    let access: String
    let refresh: String
}
struct RegisterRequestDTO: Encodable {
    let username: String
    let password: String
    let email: String
    let first_name: String
    let last_name: String
}
struct RefreshRequestDTO: Encodable { let refresh: String }
struct RefreshResponseDTO: Decodable { let access: String }
struct UserInfoDTO: Decodable {
    let id: Int
    let username: String
    let email: String
    let first_name: String?
    let last_name: String?
}
struct EmptyDTO: Decodable {} // for endpoints with empty JSON

// MARK: Protocol
protocol AuthRepository {
    func login(username: String, password: String) async throws
    func register(username: String, email: String, pass: String, firstName: String, lastName: String) async throws
    func refresh() async throws
    func changePassword(current: String, new: String) async throws   // ← ADD THIS
    func userInfo() async throws -> UserInfoDTO
}

// MARK: Real implementation
final class RealAuthRepository: AuthRepository {
    private let http: HTTPClient
    private let preferences: Preferences

    init(httpClient: HTTPClient, preferences: Preferences) {
        self.http = httpClient
        self.preferences = preferences
    }

    func login(username: String, password: String) async throws {
        let req = LoginRequestDTO(username: username, password: password)
        let resp: LoginResponseDTO = try await http.post(.login, body: req)
        preferences.token = resp.access
        preferences.refreshToken = resp.refresh
    }

    func register(username: String, email: String, pass: String, firstName: String, lastName: String) async throws {
        let req = RegisterRequestDTO(username: username, password: pass, email: email, first_name: firstName, last_name: lastName)
        _ = try await http.post(.register, body: req) as EmptyDTO // adjust if server returns something
    }

    func refresh() async throws {
        guard let r = preferences.refreshToken else { return }
        let resp: RefreshResponseDTO = try await http.post(.refresh, body: RefreshRequestDTO(refresh: r))
        preferences.token = resp.access
    }

    func userInfo() async throws -> UserInfoDTO {
        try await http.get(.userInfo)
    }
    
    func changePassword(current: String, new: String) async throws {
            _ = try await http.post(
                .changePassword,
                body: ChangePasswordRequestDTO(old_password: current, new_password: new)
            ) as EmptyDTO
        }
}
