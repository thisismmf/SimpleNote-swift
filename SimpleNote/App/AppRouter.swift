import SwiftUI

struct AppRouter: View {
    @EnvironmentObject private var container: AppContainer
    @State private var path: [NavRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            OnboardingScreen(onGetStarted: { path.append(.authLogin) })
                .navigationDestination(for: NavRoute.self) { route in
                    switch route {
                    case .onboarding:
                        OnboardingScreen(onGetStarted: { path.append(.authLogin) })
                    case .authLogin:
                        LoginScreen(
                            onLoginSuccess: { path = [.home] },
                            onRegister: { path.append(.authRegister) },
                            onForgot: { path.append(.authForgot) }
                        )
                    case .authRegister:
                        RegisterScreen(onRegistered: { path = [.authLogin] })
                    case .authForgot:
                        ForgotScreen(onDone: { path = [.authLogin] })
                    case .home:
                        HomeScreen(
                            onOpenSettings: { path.append(.settings) },
                            onOpenNote: { id in path.append(.noteDetail(id: id)) },
                            onCreateNote: { path.append(.noteEdit(id: nil)) }
                        )
                    case .noteDetail(let id):
                        NoteDetailScreen(noteID: id, onEdit: { nid in path.append(.noteEdit(id: nid)) })
                    case .noteEdit(let id):
                        NoteEditScreen(noteID: id, onDone: { path = [.home] })
                    case .settings:
                        SettingsScreen(
                            onChangePassword: { path.append(.settingsChangePassword) },
                            onLogout: { path.append(.logoutConfirm) }
                        )
                    case .settingsChangePassword:
                        ChangePasswordScreen(onDone: { path.removeLast() })
                    case .logoutConfirm:
                        LogoutConfirmSheet(onConfirm: { path = [.authLogin] }, onCancel: { path.removeLast() })
                    }
                }
        }
    }
}
