import Foundation
#if canImport(SwiftData)
import SwiftData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: ModelContainer
    init() {
        container = try! ModelContainer(for: NoteEntity.self)
    }
}
#endif
