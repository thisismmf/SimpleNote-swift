import Foundation

final class FakeNotesRepository: NotesRepository {
    private var notes: [Note] = [
        .init(id: "1", title: "New Product Ideas", body: "Draft some ideas..."),
        .init(id: "2", title: "Research", body: "Bayes factor, etc.")
    ]
    func list() async throws -> [Note] { notes }
    func detail(id: String) async throws -> Note {
        notes.first(where: { $0.id == id }) ?? .init(id: id, title: "Note \(id)", body: "Empty")
    }
    func create(title: String, body: String) async throws -> Note {
        let new = Note(id: UUID().uuidString, title: title, body: body)
        notes.append(new)
        return new
    }
    func update(id: String, title: String, body: String) async throws -> Note {
        if let idx = notes.firstIndex(where: { $0.id == id }) {
            notes[idx].title = title
            notes[idx].body = body
            return notes[idx]
        }
        return .init(id: id, title: title, body: body)
    }
    func delete(id: String) async throws {
        notes.removeAll { $0.id == id }
    }
}
