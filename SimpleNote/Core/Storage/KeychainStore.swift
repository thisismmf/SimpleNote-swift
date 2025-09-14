import Foundation

/// Placeholder for a future Keychain wrapper (no 3rd party libs).
struct KeychainStore {
    func set(_ value: String, for key: String) { /* TODO */ }
    func get(_ key: String) -> String? { nil }
}
