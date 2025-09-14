import SwiftUI

struct NoteEditScreen: View {
    @EnvironmentObject private var container: AppContainer
    var noteID: Int?          // nil = new
    @State private var title = ""
    @State private var content = ""
    @State private var isLoading = false
    @State private var errorText: String?
    var onDone: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            TopBar(title: noteID == nil ? "New Note" : "Edit Note", onBack: nil)

            NotesTextField(title: "Title", text: $title).padding(.horizontal, 24)
            TextEditor(text: $content)
                .frame(minHeight: 200).padding(12)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.notesGreyBase, lineWidth: 1))
                .padding(.horizontal, 24)

            if let e = errorText {
                Text(e).foregroundColor(.notesError).font(.footnote).padding(.horizontal, 24)
            }

            PrimaryButton(title: isLoading ? "Saving..." : "Save", action: {
                Task { await save() }
            }).padding(.horizontal, 24).disabled(isLoading)

            Spacer()
        }
        .background(Color.notesBackground.ignoresSafeArea())
        .task { await preloadIfNeeded() }
    }

    private func preloadIfNeeded() async {
        guard let id = noteID else { return }
        do {
            let n = try await container.notesRepository.detail(id: id)
            title = n.title; content = n.description
        } catch { /* best-effort */ }
    }

    private func save() async {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorText = "Title is required"; return
        }
        isLoading = true; defer { isLoading = false }
        do {
            if let id = noteID {
                _ = try await container.notesRepository.update(id: id, title: title, description: content)
            } else {
                _ = try await container.notesRepository.create(title: title, description: content)
            }
            onDone()
        } catch let HTTPError.badStatus(code, body) {
            errorText = "Save failed (\(code)): \(body)"
        } catch {
            errorText = error.localizedDescription
        }
    }
}
