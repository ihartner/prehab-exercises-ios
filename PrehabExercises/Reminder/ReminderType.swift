import Foundation

/// The independent reminders the app can schedule. Each has its own notification request,
/// stored settings, and default schedule.
enum ReminderType: String, CaseIterable {
    case exercise
    case breathing

    var identifier: String { "reminder_\(rawValue)" }
    var testIdentifier: String { "reminder_\(rawValue)_test" }

    /// The exercise reminder keeps its original key so previously saved settings still load.
    var storageKey: String {
        switch self {
        case .exercise: return "reminder_settings"
        case .breathing: return "reminder_settings_breathing"
        }
    }

    var title: String {
        switch self {
        case .exercise: return "Time for your prehab exercises"
        case .breathing: return "Time to take a breath"
        }
    }

    var body: String {
        switch self {
        case .exercise: return "Tap to start today's session."
        case .breathing: return "Tap to start a guided breathing exercise."
        }
    }

    /// Where tapping the notification should land; nil just opens the Home screen.
    var destination: String? {
        switch self {
        case .exercise: return nil
        case .breathing: return "breathing"
        }
    }

    var defaults: ReminderSettings {
        switch self {
        case .exercise: return ReminderSettings()
        case .breathing: return ReminderSettings(hour: 20)
        }
    }
}
