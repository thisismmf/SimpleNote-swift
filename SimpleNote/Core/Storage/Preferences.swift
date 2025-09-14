// SimpleNote/Core/Storage/Preferences.swift
import Foundation

final class Preferences {
    private let defaults = UserDefaults.standard
    private enum Keys { static let token = "token"; static let refresh = "refreshToken" }

    var token: String? {
        get { defaults.string(forKey: Keys.token) }
        set { defaults.set(newValue, forKey: Keys.token) }
    }

    var refreshToken: String? {
        get { defaults.string(forKey: Keys.refresh) }
        set { defaults.set(newValue, forKey: Keys.refresh) }
    }
}
