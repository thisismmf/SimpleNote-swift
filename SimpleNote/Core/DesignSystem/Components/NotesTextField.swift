import SwiftUI

struct NotesTextField: View {
    var title: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        Group {
            if isSecure {
                SecureField(title, text: $text)
            } else {
                TextField(title, text: $text)
            }
        }
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)
        .padding(.horizontal, 16)
        .frame(height: 54)
        .background(Color.notesSurface)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.notesGreyBase, lineWidth: 1))
    }
}

#Preview {
    StatefulPreviewWrapper("") { NotesTextField(title: "Email", text: $0) }
        .padding()
}
