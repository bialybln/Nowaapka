import Foundation
import SwiftData

@Model
final class UserSettings {
    enum AuthMethod: String, Codable, CaseIterable, Identifiable {
        case pin
        case biometric

        var id: String { rawValue }
        var description: String {
            switch self {
            case .pin: return "PIN / Hasło"
            case .biometric: return "Face ID / Touch ID"
            }
        }
    }

    var capitalGoal: Double
    var initialCapital: Double
    var currentCapital: Double
    var preferredAuthMethod: AuthMethod
    var storedPasswordIdentifier: String?

    init(capitalGoal: Double, initialCapital: Double, currentCapital: Double, preferredAuthMethod: AuthMethod, storedPasswordIdentifier: String? = nil) {
        self.capitalGoal = capitalGoal
        self.initialCapital = initialCapital
        self.currentCapital = currentCapital
        self.preferredAuthMethod = preferredAuthMethod
        self.storedPasswordIdentifier = storedPasswordIdentifier
    }
}
