import Foundation

/// App-level container (very lightweight DI)
final class AppContainer: ObservableObject {
    let authRepository: AuthRepository
    let notesRepository: NotesRepository
    let preferences: Preferences

    init(
        authRepository: AuthRepository = FakeAuthRepository(),
        notesRepository: NotesRepository = FakeNotesRepository(),
        preferences: Preferences = Preferences()
    ) {
        self.authRepository = authRepository
        self.notesRepository = notesRepository
        self.preferences = preferences
    }
}
