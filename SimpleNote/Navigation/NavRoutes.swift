import Foundation

enum NavRoute: Hashable {
    case onboarding
    case authLogin
    case authRegister
    case authForgot
    case home
    case noteDetail(id: Int)
    case noteEdit(id: Int?)   // nil = new
    case settings
    case settingsChangePassword
    case logoutConfirm
}
