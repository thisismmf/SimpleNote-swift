import Foundation

enum APIRoute {
    case register
    case login
    case refresh
    case userInfo

    var path: String {
        switch self {
        case .register: return "/api/auth/register/"
        case .login:    return "/api/auth/token/"
        case .refresh:  return "/api/auth/token/refresh/"
        case .userInfo: return "/api/auth/userinfo/"
        }
    }
}
