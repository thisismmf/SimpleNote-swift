import Foundation

// MARK: DTOs (OPTIONALS so null/missing fields don’t crash)
struct NoteDTO: Codable, Identifiable, Hashable {
    let id: Int
    let title: String?
    let description: String?
    let created_at: String?
    let updated_at: String?
    let creator_name: String?
    let creator_username: String?
}

struct NoteListDTO<T: Codable>: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [T]
}
struct MinimalListDTO<T: Codable>: Codable { let results: [T] }

struct CreateNoteDTO: Encodable { let title: String; let description: String }
struct UpdateNoteDTO: Encodable { let title: String; let description: String }

// MARK: Domain
struct Note: Identifiable, Hashable {
    let id: Int
    var title: String
    var description: String
    var createdAt: String
    var updatedAt: String
    var creatorName: String?
    var creatorUsername: String?
}
private extension Note { init(dto: NoteDTO) {
    id = dto.id
    title = dto.title ?? ""
    description = dto.description ?? ""
    createdAt = dto.created_at ?? ""
    updatedAt = dto.updated_at ?? ""
    creatorName = dto.creator_name
    creatorUsername = dto.creator_username
}}

// MARK: Contract
protocol NotesRepository {
    func list(page: Int?, pageSize: Int?) async throws -> (items: [Note], count: Int, next: String?, previous: String?)
    func filter(title: String?, description: String?, page: Int?, pageSize: Int?, updatedGte: String?, updatedLte: String?) async throws -> (items: [Note], count: Int, next: String?, previous: String?)
    func detail(id: Int) async throws -> Note
    func create(title: String, description: String) async throws -> Note
    func update(id: Int, title: String, description: String) async throws -> Note
    func patch(id: Int, title: String?, description: String?) async throws -> Note
    func delete(id: Int) async throws
    func bulk(_ notes: [CreateNoteDTO]) async throws -> [Note]
}

// MARK: Real impl
final class RealNotesRepository: NotesRepository {
    private let http: HTTPClient
    init(http: HTTPClient) { self.http = http }

    func list(page: Int?, pageSize: Int?) async throws -> (items: [Note], count: Int, next: String?, previous: String?) {
        let data = try await http.getData(.notes(page: page, pageSize: pageSize))
        return try parseNotesPage(data, endpoint: "/api/notes/")
    }

    func filter(title: String?, description: String?, page: Int?, pageSize: Int?, updatedGte: String?, updatedLte: String?) async throws -> (items: [Note], count: Int, next: String?, previous: String?) {
        let data = try await http.getData(.notesFilter(title: title, description: description, page: page, pageSize: pageSize, updatedGte: updatedGte, updatedLte: updatedLte))
        return try parseNotesPage(data, endpoint: "/api/notes/filter")
    }

    func detail(id: Int) async throws -> Note {
        let dto: NoteDTO = try await http.get(.noteDetail(id: id))
        return Note(dto: dto)
    }

    func create(title: String, description: String) async throws -> Note {
        let data = try await http.postData(.noteCreate, body: CreateNoteDTO(title: title, description: description))
        if data.isEmpty {
            // treat as success, fetch newest likely match
            return try await newestLikelyMatch(title: title, description: description)
        }
        // try as single object, array, or fallback to list
        let dec = JSONDecoder(); dec.keyDecodingStrategy = .convertFromSnakeCase
        if let dto = try? dec.decode(NoteDTO.self, from: data) { return Note(dto: dto) }
        if let arr = try? dec.decode([NoteDTO].self, from: data), let first = arr.first { return Note(dto: first) }
        return try await newestLikelyMatch(title: title, description: description)
    }

    func update(id: Int, title: String, description: String) async throws -> Note {
        let data = try await http.putData(.noteUpdate(id: id), body: UpdateNoteDTO(title: title, description: description))
        if data.isEmpty { return try await detail(id: id) }
        let dec = JSONDecoder(); dec.keyDecodingStrategy = .convertFromSnakeCase
        if let dto = try? dec.decode(NoteDTO.self, from: data) { return Note(dto: dto) }
        return try await detail(id: id)
    }

    func patch(id: Int, title: String?, description: String?) async throws -> Note {
        let data = try await http.patchData(.notePatch(id: id),
                                            body: UpdateNoteDTO(title: title ?? "", description: description ?? ""))
        if data.isEmpty { return try await detail(id: id) }
        let dec = JSONDecoder(); dec.keyDecodingStrategy = .convertFromSnakeCase
        if let dto = try? dec.decode(NoteDTO.self, from: data) { return Note(dto: dto) }
        return try await detail(id: id)
    }

    func delete(id: Int) async throws { try await http.delete(.noteDelete(id: id)) }

    func bulk(_ notes: [CreateNoteDTO]) async throws -> [Note] {
        let data = try await http.postData(.notesBulk, body: notes)
        if data.isEmpty { return try await list(page: 1, pageSize: 50).items }
        let dec = JSONDecoder(); dec.keyDecodingStrategy = .convertFromSnakeCase
        if let arr = try? dec.decode([NoteDTO].self, from: data) { return arr.map(Note.init(dto:)) }
        if let paged = try? dec.decode(NoteListDTO<NoteDTO>.self, from: data) { return paged.results.map(Note.init(dto:)) }
        return try await list(page: 1, pageSize: 50).items
    }

    // MARK: helpers
    private func parseNotesPage(_ data: Data, endpoint: String) throws -> (items: [Note], count: Int, next: String?, previous: String?) {
        if data.isEmpty { return ([], 0, nil, nil) }
        let dec = JSONDecoder(); dec.keyDecodingStrategy = .convertFromSnakeCase

        if let paged = try? dec.decode(NoteListDTO<NoteDTO>.self, from: data) {
            return (paged.results.map(Note.init(dto:)), paged.count, paged.next, paged.previous)
        }
        if let minimal = try? dec.decode(MinimalListDTO<NoteDTO>.self, from: data) {
            return (minimal.results.map(Note.init(dto:)), minimal.results.count, nil, nil)
        }
        if let arr = try? dec.decode([NoteDTO].self, from: data) {
            return (arr.map(Note.init(dto:)), arr.count, nil, nil)
        }
        if let single = try? dec.decode(NoteDTO.self, from: data) {
            return ([Note(dto: single)], 1, nil, nil)
        }
        // last-resort: if body is text/html or a plain string, just show empty list and log it
        if let str = String(data: data, encoding: .utf8) {
            print("⚠️ Notes decode fallback for \(endpoint): \(str.prefix(200))")
        }
        return ([], 0, nil, nil)
    }

    private func newestLikelyMatch(title: String, description: String) async throws -> Note {
        let page = try await list(page: 1, pageSize: 10)
        if let match = page.items.first(where: { $0.title == title }) { return match }
        if let first = page.items.first { return first }
        // If still nothing, synthesize a minimal object so UI proceeds
        return Note(id: Int.random(in: 100000...999999),
                    title: title, description: description,
                    createdAt: "", updatedAt: "", creatorName: nil, creatorUsername: nil)
    }
}
