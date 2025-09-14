import SwiftUI

struct ChangePasswordScreen: View {
    @EnvironmentObject private var container: AppContainer
    @State private var current = ""
    @State private var new = ""
    @State private var confirm = ""
    @State private var isLoading = false
    @State private var errorText: String?
    var onDone: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            TopBar(title: "Change Password", onBack: nil)

            NotesTextField(title: "Current Password", text: $current, isSecure: true).padding(.horizontal, 24)
            NotesTextField(title: "New Password", text: $new, isSecure: true).padding(.horizontal, 24)
            NotesTextField(title: "Retype New Password", text: $confirm, isSecure: true).padding(.horizontal, 24)

            if let e = errorText {
                Text(e).foregroundColor(.notesError).font(.footnote).padding(.horizontal, 24)
            }

            PrimaryButton(title: isLoading ? "Submitting..." : "Submit New Password") {
                Task { await submit() }
            }
            .padding(.horizontal, 24)
            .disabled(isLoading || new.isEmpty || new != confirm)

            Spacer()
        }
        .background(Color.notesBackground.ignoresSafeArea())
    }

    private func submit() async {
        guard !current.isEmpty, !new.isEmpty, new == confirm else { return }
        isLoading = true; defer { isLoading = false }
        do {
            try await container.authRepository.changePassword(current: current, new: new)
            onDone()
        } catch let HTTPError.badStatus(code, body) {
            errorText = "Change failed (\(code)): \(body)"
        } catch {
            errorText = error.localizedDescription
        }
    }
}
