import SwiftUI

struct RegisterScreen: View {
    @EnvironmentObject private var container: AppContainer
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var repeatPassword = ""
    @State private var isLoading = false
    @State private var errorText: String?

    var onRegistered: () -> Void

    private var isValid: Bool {
        let ok = !firstName.isEmpty && !lastName.isEmpty &&
                 !username.isEmpty && !email.isEmpty &&
                 !password.isEmpty && password == repeatPassword
        return ok
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                TopBar(title: "Register", onBack: nil)
                Group {
                    NotesTextField(title: "First Name", text: $firstName)
                    NotesTextField(title: "Last Name", text: $lastName)
                    NotesTextField(title: "Username", text: $username)
                    NotesTextField(title: "Email Address", text: $email)
                    NotesTextField(title: "Password", text: $password, isSecure: true)
                    NotesTextField(title: "Retype Password", text: $repeatPassword, isSecure: true)
                }.padding(.horizontal, 24)

                if let e = errorText {
                    Text(e).foregroundColor(.notesError).font(.footnote)
                        .padding(.horizontal, 24)
                }

                PrimaryButton(title: isLoading ? "Registering..." : "Register") {
                    Task { await doRegister() }
                }
                .padding(.horizontal, 24)
                .disabled(!isValid || isLoading)

                Spacer(minLength: 40)
            }
        }
        .background(Color.notesBackground.ignoresSafeArea())
    }

    private func doRegister() async {
        errorText = nil
        isLoading = true
        defer { isLoading = false }

        do {
            try await container.authRepository.register(
                username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                pass: password,
                firstName: firstName,
                lastName: lastName
            )
            onRegistered() // back to Login
        } catch let HTTPError.badStatus(code, body) {
            errorText = "Register failed (\(code)): \(body)"
        } catch {
            errorText = "Register failed: \(error.localizedDescription)"
        }
    }
}
