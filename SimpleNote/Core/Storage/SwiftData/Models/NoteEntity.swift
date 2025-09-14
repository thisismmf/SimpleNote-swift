import Foundation
#if canImport(SwiftData)
import SwiftData

@Model
final class NoteEntity {
    @Attribute(.unique) var id: String
    var title: String
    var body: String

    init(id: String, title: String, body: String) {
        self.id = id
        self.title = title
        self.body = body
    }
}
#endif
