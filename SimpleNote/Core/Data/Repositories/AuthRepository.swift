// SimpleNote/Core/Data/Repositories/AuthRepository.swift
import Foundation

// MARK: - DTOs (keep close to the repo for now; you can move to a DTO file later)
struct LoginRequestDTO: Encodable {
    let username: String
    let password: String
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
struct EmptyDTO: Decodable {}   // use if server returns an empty body
struct UserInfoDTO: Decodable {
    let username: String
    let email: String
    let first_name: String?
    let last_name: String?
}

// MARK: - Protocol
protocol AuthRepository {
    func login(username: String, password: String) async throws
    func register(username: String, email: String, pass: String, firstName: String, lastName: String) async throws
    func changePassword(current: String, new: String) async throws
    func userInfo() async throws -> UserInfoDTO
}

// MARK: - Real implementation (using typed HTTPClient)
final class RealAuthRepository: AuthRepository {
    private let httpClient: HTTPClient
    private let preferences: Preferences

    init(httpClient: HTTPClient, preferences: Preferences) {
        self.httpClient = httpClient
        self.preferences = preferences
    }

    func login(username: String, password: String) async throws {
        let req = LoginRequestDTO(username: username, password: password)
        let resp: LoginResponseDTO = try await httpClient.post(.login, body: req)
        preferences.token = resp.access
        preferences.refreshToken = resp.refresh
    }

    func register(username: String, email: String, pass: String, firstName: String, lastName: String) async throws {
        let req = RegisterRequestDTO(
            username: username,
            password: pass,
            email: email,
            first_name: firstName,
            last_name: lastName
        )
        _ = try await httpClient.post(.register, body: req) as EmptyDTO
    }

    func changePassword(current: String, new: String) async throws {
        // TODO: call .changePassword when ready
    }

    func userInfo() async throws -> UserInfoDTO {
        try await httpClient.get(.userInfo)
    }
}
