import SwiftUI

struct NoteDetailScreen: View {
    var noteID: String
    var onEdit: (String) -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TopBar(title: "Note Detail", onBack: nil)
            Text("New Product Ideas").font(.title2).bold().padding(.horizontal, 24)
            Text("A placeholder body...").padding(.horizontal, 24)
            Spacer()
            PrimaryButton(title: "Edit", action: { onEdit(noteID) })
                .padding(.horizontal, 24)
        }
        .background(Color.notesBackground.ignoresSafeArea())
    }
}

#Preview { NoteDetailScreen(noteID: "1", onEdit: { _ in }) }
