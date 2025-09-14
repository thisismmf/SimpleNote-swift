import SwiftUI

struct ForgotScreen: View {
    @State private var newPassword = ""
    @State private var retypePassword = ""
    var onDone: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            TopBar(title: "Create a New Password", onBack: nil)
            NotesTextField(title: "New Password", text: $newPassword, isSecure: true)
                .padding(.horizontal, 24)
            NotesTextField(title: "Retype New Password", text: $retypePassword, isSecure: true)
                .padding(.horizontal, 24)
            PrimaryButton(title: "Create Password", action: onDone)
                .padding(.horizontal, 24)
            Spacer()
        }
        .background(Color.notesBackground.ignoresSafeArea())
    }
}

#Preview {
    ForgotScreen(onDone: {})
}
