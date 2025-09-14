import SwiftUI

struct LoginScreen: View {
    @EnvironmentObject private var container: AppContainer
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorText: String?

    var onLoginSuccess: () -> Void
    var onRegister: () -> Void
    var onForgot: () -> Void

    private var isValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty
    }

    var body: some View {
        VStack(spacing: 16) {
            TopBar(title: "Let's Login", onBack: nil)
            VStack(spacing: 12) {
                NotesTextField(title: "Email Address", text: $email)
                NotesTextField(title: "Password", text: $password, isSecure: true)
            }.padding(.horizontal, 24)

            if let e = errorText {
                Text(e).foregroundColor(.notesError).font(.footnote)
                    .padding(.horizontal, 24)
            }

            PrimaryButton(title: isLoading ? "Logging in..." : "Login") {
                Task { await doLogin() }
            }
            .padding(.horizontal, 24)
            .disabled(!isValid || isLoading)

            Button("Don't have any account? Register here", action: onRegister)
                .padding(.top, 8)
            Button("Forgot password?", action: onForgot)
                .foregroundColor(Color.notesGreyDark)
            Spacer()
        }
        .background(Color.notesBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    private func doLogin() async {
        errorText = nil
        isLoading = true
        defer { isLoading = false }

        do {
            // Backend expects "username" — many backends accept email in that field
            try await container.authRepository.login(username: email.trimmingCharacters(in: .whitespacesAndNewlines),
                                                     password: password)
            _ = try? await container.authRepository.userInfo() // optional warm-up
            onLoginSuccess()
        } catch let HTTPError.badStatus(code, body) {
            errorText = "Login failed (\(code)): \(body)"
        } catch {
            errorText = "Login failed: \(error.localizedDescription)"
        }
    }
}
