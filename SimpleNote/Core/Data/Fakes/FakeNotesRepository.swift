import Foundation

final class FakeNotesRepository: NotesRepository {
    private var notes: [Note] = [
        .init(id: 1, title: "New Product Ideas", description: "Draft some ideas...", createdAt: "2025-01-01T00:00:00Z", updatedAt: "2025-01-01T00:00:00Z", creatorName: "You", creatorUsername: "you"),
        .init(id: 2, title: "Research", description: "Bayes factor, etc.", createdAt: "2025-01-02T00:00:00Z", updatedAt: "2025-01-02T00:00:00Z", creatorName: "You", creatorUsername: "you")
    ]

    func list(page: Int?, pageSize: Int?) async throws -> (items: [Note], count: Int, next: String?, previous: String?) {
        (notes, notes.count, nil, nil)
    }
    func filter(title: String?, description: String?, page: Int?, pageSize: Int?, updatedGte: String?, updatedLte: String?) async throws -> (items: [Note], count: Int, next: String?, previous: String?) {
        (notes, notes.count, nil, nil)
    }
    func detail(id: Int) async throws -> Note { notes.first(where: { $0.id == id }) ?? notes[0] }
    func create(title: String, description: String) async throws -> Note {
        let n = Note(id: (notes.last?.id ?? 0)+1, title: title, description: description, createdAt: "", updatedAt: "", creatorName: "You", creatorUsername: "you")
        notes.append(n); return n
    }
    func update(id: Int, title: String, description: String) async throws -> Note {
        if let i = notes.firstIndex(where: { $0.id == id }) {
            notes[i].title = title; notes[i].description = description; return notes[i]
        }
        return try await create(title: title, description: description)
    }
    func patch(id: Int, title: String?, description: String?) async throws -> Note {
        if let i = notes.firstIndex(where: { $0.id == id }) {
            if let t = title { notes[i].title = t }
            if let d = description { notes[i].description = d }
            return notes[i]
        }
        return try await create(title: title ?? "", description: description ?? "")
    }
    func delete(id: Int) async throws { notes.removeAll { $0.id == id } }
    func bulk(_ notes: [CreateNoteDTO]) async throws -> [Note] {
        for n in notes { _ = n } // no-op
        return self.notes
    }
}
