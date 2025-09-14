// SimpleNote/App/SimpleNoteApp.swift
import SwiftUI

@main
struct SimpleNoteApp: App {
    @StateObject private var container: AppContainer

    init() {
        let prefs = Preferences()
        let http = HTTPClient(
            baseURL: URL(string: "https://simple.darkube.app")!, // ← your host
            tokenProvider: { prefs.token }
        )
        _container = StateObject(
            wrappedValue: AppContainer(
                authRepository: RealAuthRepository(httpClient: http, preferences: prefs),
                notesRepository: FakeNotesRepository(),
                preferences: prefs
            )
        )
    }

    var body: some Scene {
        WindowGroup { AppRouter().environmentObject(container) }
    }
}
