import SwiftUI

struct NoteCard: View {
    var title: String
    var bodyText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            Text(bodyText).font(.subheadline).foregroundColor(.notesGreyDark)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.yellow.opacity(0.2)))
    }
}

#Preview {
    NoteCard(title: "New Product Ideas", bodyText: "A short description...")
        .padding()
}
