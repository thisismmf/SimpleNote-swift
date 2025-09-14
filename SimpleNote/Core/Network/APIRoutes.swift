import Foundation

enum APIRoute {
    // Auth
    case register
    case login
    case refresh
    case userInfo
    case changePassword

    // Notes
    case notes(page: Int?, pageSize: Int?)
    case notesFilter(
        title: String?, description: String?,
        page: Int?, pageSize: Int?,
        updatedGte: String?, updatedLte: String?
    )
    case noteDetail(id: Int)
    case noteCreate
    case noteUpdate(id: Int)   // PUT
    case notePatch(id: Int)    // PATCH
    case noteDelete(id: Int)
    case notesBulk

    var path: String {
        switch self {
        // auth
        case .register:          return "/api/auth/register/"
        case .login:             return "/api/auth/token/"
        case .refresh:           return "/api/auth/token/refresh/"
        case .userInfo:          return "/api/auth/userinfo/"
        case .changePassword:    return "/api/auth/change-password/"

        // notes
        case .notes:             return "/api/notes/"
        case .notesFilter:       return "/api/notes/filter"
        case .noteDetail(let id),
             .noteUpdate(let id),
             .notePatch(let id),
             .noteDelete(let id):
            return "/api/notes/\(id)/"
        case .noteCreate:        return "/api/notes/"
        case .notesBulk:         return "/api/notes/bulk"
        }
    }

    /// Query items (for list + filter)
    var queryItems: [URLQueryItem]? {
        switch self {
        case let .notes(page, pageSize):
            return [
                page.map { URLQueryItem(name: "page", value: String($0)) },
                pageSize.map { URLQueryItem(name: "page_size", value: String($0)) }
            ].compactMap { $0 }

        case let .notesFilter(title, description, page, pageSize, updatedGte, updatedLte):
            return [
                title.map { URLQueryItem(name: "title", value: $0) },
                description.map { URLQueryItem(name: "description", value: $0) },
                page.map { URLQueryItem(name: "page", value: String($0)) },
                pageSize.map { URLQueryItem(name: "page_size", value: String($0)) },
                updatedGte.map { URLQueryItem(name: "updated__gte", value: $0) },
                updatedLte.map { URLQueryItem(name: "updated__lte", value: $0) }
            ].compactMap { $0 }

        default: return nil
        }
    }
}
