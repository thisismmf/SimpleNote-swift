import SwiftUI

struct NoteDetailScreen: View {
    @EnvironmentObject private var container: AppContainer
    var noteID: Int
    var onEdit: (Int) -> Void

    @State private var note: Note?
    @State private var isLoading = false
    @State private var showDelete = false
    @State private var errorText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TopBar(title: "Note Detail", onBack: nil)

            if let n = note {
                Text(n.title).font(.title2).bold().padding(.horizontal, 24)
                Text(n.description).padding(.horizontal, 24).foregroundColor(.notesGreyDark)
                Spacer()

                HStack {
                    PrimaryButton(title: "Edit", action: { onEdit(n.id) })
                }.padding(.horizontal, 24)
            } else if isLoading {
                ProgressView().padding(.top, 24)
            } else if let e = errorText {
                Text(e).foregroundColor(.notesError).padding(.horizontal, 24)
                Spacer()
            } else {
                Text("Note not found").padding(.horizontal, 24)
                Spacer()
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                showDelete = true
            } label: {
                Image(systemName: "trash").font(.title3).padding()
                    .background(Circle().fill(Color.notesPrimary))
                    .foregroundColor(.white).shadow(radius: 3)
            }.padding(24)
        }
        .confirmationDialog("Want to Delete this Note?", isPresented: $showDelete, titleVisibility: .visible) {
            Button("Delete Note", role: .destructive) {
                Task { await deleteNote() }
            }
        }
        .background(Color.notesBackground.ignoresSafeArea())
        .task { await load() }
    }

    private func load() async {
        isLoading = true; defer { isLoading = false }
        do { note = try await container.notesRepository.detail(id: noteID) }
        catch { errorText = error.localizedDescription }
    }

    private func deleteNote() async {
        do {
            try await container.notesRepository.delete(id: noteID)
            // best-effort: pop back by posting a notification; router resets to home on save elsewhere.
        } catch { errorText = error.localizedDescription }
    }
}
