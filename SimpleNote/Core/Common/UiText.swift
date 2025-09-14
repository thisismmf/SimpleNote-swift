import Foundation

enum UiText {
    case plain(String)
    var resolved: String {
        switch self {
        case .plain(let s): return s
        }
    }
}
