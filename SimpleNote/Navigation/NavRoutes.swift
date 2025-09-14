import Foundation

enum NavRoute: Hashable {
    case onboarding
    case authLogin
    case authRegister
    case authForgot
    case home
    case noteDetail(id: String)
    case noteEdit(id: String?)
    case settings
    case settingsChangePassword
    case logoutConfirm
}
