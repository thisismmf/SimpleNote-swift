import SwiftUI

struct NoteEditScreen: View {
    var noteID: String?
    @State private var title = ""
    @State private var content = ""   // ← renamed (was `body`)
    var onDone: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            TopBar(title: noteID == nil ? "New Note" : "Edit Note", onBack: nil)

            NotesTextField(title: "Title", text: $title)
                .padding(.horizontal, 24)

            TextEditor(text: $content) // ← updated binding
                .frame(minHeight: 200)
                .padding(12)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.notesGreyBase, lineWidth: 1))
                .padding(.horizontal, 24)

            PrimaryButton(title: "Save", action: onDone)
                .padding(.horizontal, 24)
            Spacer()
        }
        .background(Color.notesBackground.ignoresSafeArea())
    }
}
