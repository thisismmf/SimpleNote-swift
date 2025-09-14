import SwiftUI

struct NoteEditScreen: View {
    @EnvironmentObject private var container: AppContainer
    var noteID: Int?
    @State private var title = ""
    @State private var content = ""
    @State private var isLoading = false
    @State private var isGenerating = false          // ← NEW
    @State private var errorText: String?
    var onDone: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            TopBar(title: noteID == nil ? "New Note" : "Edit Note", onBack: nil)

            NotesTextField(title: "Title", text: $title).padding(.horizontal, 24)

            TextEditor(text: $content)
                .frame(minHeight: 220).padding(12)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.notesGreyBase, lineWidth: 1))
                .padding(.horizontal, 24)

            // AI button
            OutlinedButton(
                title: isGenerating ? "Generating..." : "✨ Write with AI",
                action: { Task { await generateWithAI() } }
            )
            .padding(.horizontal, 24)
            .disabled(isGenerating || title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            if let e = errorText {
                Text(e).foregroundColor(.notesError).font(.footnote).padding(.horizontal, 24)
            }

            PrimaryButton(title: isLoading ? "Saving..." : "Save", action: {
                Task { await save() }
            })
            .padding(.horizontal, 24)
            .disabled(isLoading)

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
    private func generateWithAI() async {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { errorText = "Enter a title first."; return }

        let key = GeminiConfig.apiKey
        guard !key.isEmpty else {
            errorText = "Missing Gemini API key. Add GEMINI_API_KEY to Info.plist or Resources/Secrets.plist."
            return
        }

        isGenerating = true; defer { isGenerating = false }
        do {
            let gemini = try GeminiService(apiKey: key)
            let idea = try await gemini.generateBody(forTitle: t)
            if content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                content = idea
            } else {
                content += "\n\n" + idea
            }
        } catch {
            errorText = error.localizedDescription
        }
    }
}
