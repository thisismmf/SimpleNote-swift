import SwiftUI

struct LoginScreen: View {
    @State private var email = ""
    @State private var password = ""
    var onLoginSuccess: () -> Void
    var onRegister: () -> Void
    var onForgot: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            TopBar(title: "Let's Login", onBack: nil)
            VStack(spacing: 12) {
                NotesTextField(title: "Email Address", text: $email)
                NotesTextField(title: "Password", text: $password, isSecure: true)
            }.padding(.horizontal, 24)
            PrimaryButton(title: "Login", action: onLoginSuccess)
                .padding(.horizontal, 24)
            Button("Don't have any account? Register here", action: onRegister)
                .padding(.top, 8)
            Button("Forgot password?", action: onForgot)
                .foregroundColor(.notesGreyDark)
            Spacer()
        }
        .background(Color.notesBackground.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    LoginScreen(onLoginSuccess: {}, onRegister: {}, onForgot: {})
}
