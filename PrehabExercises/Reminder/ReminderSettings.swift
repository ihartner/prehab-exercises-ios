import Foundation

enum ReminderFrequency: String, Codable, CaseIterable, Equatable {
    case daily
    case weekly

    var displayName: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        }
    }
}

struct ReminderSettings: Codable, Equatable {
    var enabled: Bool = false
    var frequency: ReminderFrequency = .daily
    /// Calendar weekday: 1 = Sunday ... 7 = Saturday.
    var weekday: Int = 1
    var hour: Int = 9
    var minute: Int = 0
}
