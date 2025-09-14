// NotesRepository.swift
import Foundation
struct Note: Identifiable, Hashable { var id: String; var title: String; var body: String }
protocol NotesRepository {
    func list() async throws -> [Note]
    func detail(id: String) async throws -> Note
    func create(title: String, body: String) async throws -> Note
    func update(id: String, title: String, body: String) async throws -> Note
    func delete(id: String) async throws
}
