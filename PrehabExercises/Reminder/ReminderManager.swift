import Foundation
import UserNotifications

/// Owns the reminder settings and keeps a repeating local notification in sync with them.
/// Unlike Android, iOS repeats calendar-triggered notifications itself, so nothing needs
/// re-arming after a reboot or app update.
@MainActor
final class ReminderManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {

    private static let storageKey = "reminder_settings"
    private static let reminderIdentifier = "exercise_reminder"
    private static let testIdentifier = "exercise_reminder_test"

    @Published private(set) var settings: ReminderSettings
    /// True only when the user has explicitly denied notifications for this app.
    @Published private(set) var notificationsBlocked = false

    private let defaults: UserDefaults
    private let center = UNUserNotificationCenter.current()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: ReminderManager.storageKey),
           let decoded = try? JSONDecoder().decode(ReminderSettings.self, from: data) {
            self.settings = decoded
        } else {
            self.settings = ReminderSettings()
        }
        super.init()
        center.delegate = self
        Task {
            await refreshAuthorization()
            await reschedule()
        }
    }

    /// The next moment the reminder will fire, for display in Settings.
    var nextReminderDate: Date? {
        var components = DateComponents(hour: settings.hour, minute: settings.minute, second: 0)
        if settings.frequency == .weekly {
            components.weekday = settings.weekday
        }
        return Calendar.current.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime)
    }

    func update(_ transform: (inout ReminderSettings) -> Void) {
        var updated = settings
        transform(&updated)
        settings = updated
        save()
        Task {
            if updated.enabled {
                await requestAuthorizationIfNeeded()
            }
            await reschedule()
        }
    }

    func refreshAuthorization() async {
        let current = await center.notificationSettings()
        notificationsBlocked = current.authorizationStatus == .denied
    }

    func sendTestNotification() async {
        await requestAuthorizationIfNeeded()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(
            identifier: Self.testIdentifier,
            content: makeContent(),
            trigger: trigger
        )
        try? await center.add(request)
    }

    private func requestAuthorizationIfNeeded() async {
        let current = await center.notificationSettings()
        if current.authorizationStatus == .notDetermined {
            _ = try? await center.requestAuthorization(options: [.alert, .sound])
        }
        await refreshAuthorization()
    }

    private func reschedule() async {
        center.removePendingNotificationRequests(withIdentifiers: [Self.reminderIdentifier])
        guard settings.enabled else { return }

        var components = DateComponents(hour: settings.hour, minute: settings.minute)
        if settings.frequency == .weekly {
            components.weekday = settings.weekday
        }
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: Self.reminderIdentifier,
            content: makeContent(),
            trigger: trigger
        )
        try? await center.add(request)
    }

    private func makeContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Time for your prehab exercises"
        content.body = "Tap to start today's session."
        content.sound = .default
        return content
    }

    private func save() {
        if let data = try? JSONEncoder().encode(settings) {
            defaults.set(data, forKey: Self.storageKey)
        }
    }

    // Show reminders as banners even while the app is in the foreground.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
