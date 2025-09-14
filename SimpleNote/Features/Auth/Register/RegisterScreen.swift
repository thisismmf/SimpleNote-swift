import SwiftUI

struct RegisterScreen: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var repeatPassword = ""
    var onRegistered: () -> Void

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
                PrimaryButton(title: "Register", action: onRegistered)
                    .padding(.horizontal, 24)
                Spacer()
            }
        }
        .background(Color.notesBackground.ignoresSafeArea())
    }
}

#Preview {
    RegisterScreen(onRegistered: {})
}
