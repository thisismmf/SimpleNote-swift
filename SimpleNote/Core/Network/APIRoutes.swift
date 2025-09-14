// SimpleNote/Core/Network/APIRoutes.swift
import Foundation

enum APIRoute {
    case login
    case register
    case userInfo
    // case changePassword  // add when you wire it

    var path: String {
        switch self {
        case .login:        return "/api/auth/token/"
        case .register:     return "/api/auth/register/"
        case .userInfo:     return "/api/auth/userinfo/"
        }
    }
}
