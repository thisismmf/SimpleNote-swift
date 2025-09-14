final class FakeAuthRepository: AuthRepository {
    func login(username: String, password: String) async throws {}
    func register(username: String, email: String, pass: String, firstName: String, lastName: String) async throws {}
    func refresh() async throws {}
    func userInfo() async throws -> UserInfoDTO {
        .init(id: 1, username: "john", email: "john@doe.com", first_name: "John", last_name: "Doe")
    }
}
