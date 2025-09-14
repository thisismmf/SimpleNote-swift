import SwiftUI

struct ChangePasswordScreen: View {
    @State private var current = ""
    @State private var new = ""
    @State private var confirm = ""
    var onDone: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            TopBar(title: "Change Password", onBack: nil)
            NotesTextField(title: "Current Password", text: $current, isSecure: true).padding(.horizontal, 24)
            NotesTextField(title: "New Password", text: $new, isSecure: true).padding(.horizontal, 24)
            NotesTextField(title: "Retype New Password", text: $confirm, isSecure: true).padding(.horizontal, 24)
            PrimaryButton(title: "Submit New Password", action: onDone).padding(.horizontal, 24)
            Spacer()
        }
        .background(Color.notesBackground.ignoresSafeArea())
    }
}

#Preview { ChangePasswordScreen(onDone: {}) }
