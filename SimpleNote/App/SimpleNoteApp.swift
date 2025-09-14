import SwiftUI

@main
struct SimpleNoteApp: App {
    @StateObject private var container: AppContainer

    init() {
        let prefs = Preferences()
        var http = HTTPClient()
        http.baseURL = URL(string: "https://simple.darkube.app")!   // ← your host
        http.tokenProvider = { prefs.token }

        let notesRepo = RealNotesRepository(http: http)
        let authRepo  = RealAuthRepository(httpClient: http, preferences: prefs)

        _container = StateObject(
            wrappedValue: AppContainer(
                authRepository: authRepo,
                notesRepository: notesRepo,
                preferences: prefs
            )
        )
    }

    var body: some Scene {
        WindowGroup { AppRouter().environmentObject(container) }
    }
}
