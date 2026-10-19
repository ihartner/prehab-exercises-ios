import Foundation
import UserNotifications

/// Owns the reminder settings and keeps one repeating local notification per reminder type
/// in sync with them. Unlike Android, iOS repeats calendar-triggered notifications itself,
/// so nothing needs re-arming after a reboot or app update.
@MainActor
final class ReminderManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {

    @Published private(set) var exerciseSettings: ReminderSettings
    @Published private(set) var breathingSettings: ReminderSettings
    /// True only when the user has explicitly denied notifications for this app.
    @Published private(set) var notificationsBlocked = false
    /// Set when the user taps a reminder that should open a specific screen.
    @Published private(set) var pendingDestination: AppRoute?

    private let defaults: UserDefaults
    private let center = UNUserNotificationCenter.current()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.exerciseSettings = ReminderManager.load(.exercise, from: defaults)
        self.breathingSettings = ReminderManager.load(.breathing, from: defaults)
        super.init()
        center.delegate = self
        Task {
            await refreshAuthorization()
            for type in ReminderType.allCases {
                await reschedule(type)
            }
        }
    }

    func settings(for type: ReminderType) -> ReminderSettings {
        switch type {
        case .exercise: return exerciseSettings
        case .breathing: return breathingSettings
        }
    }

    /// The next moment the reminder will fire, for display in Settings.
    func nextReminderDate(for type: ReminderType) -> Date? {
        let current = settings(for: type)
        var components = DateComponents(hour: current.hour, minute: current.minute, second: 0)
        if current.frequency == .weekly {
            components.weekday = current.weekday
        }
        return Calendar.current.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime)
    }

    func update(_ type: ReminderType, _ transform: (inout ReminderSettings) -> Void) {
        var updated = settings(for: type)
        transform(&updated)
        store(updated, for: type)
        Task {
            if updated.enabled {
                await requestAuthorizationIfNeeded()
            }
            await reschedule(type)
        }
    }

    func refreshAuthorization() async {
        let current = await center.notificationSettings()
        notificationsBlocked = current.authorizationStatus == .denied
    }

    func sendTestNotification(for type: ReminderType) async {
        await requestAuthorizationIfNeeded()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(
            identifier: type.testIdentifier,
            content: makeContent(for: type),
            trigger: trigger
        )
        try? await center.add(request)
    }

    /// Returns and clears the screen a tapped reminder asked to open.
    func consumePendingDestination() -> AppRoute? {
        let destination = pendingDestination
        pendingDestination = nil
        return destination
    }

    private static func load(_ type: ReminderType, from defaults: UserDefaults) -> ReminderSettings {
        guard let data = defaults.data(forKey: type.storageKey),
              let decoded = try? JSONDecoder().decode(ReminderSettings.self, from: data) else {
            return type.defaults
        }
        return decoded
    }

    private func store(_ updated: ReminderSettings, for type: ReminderType) {
        switch type {
        case .exercise: exerciseSettings = updated
        case .breathing: breathingSettings = updated
        }
        if let data = try? JSONEncoder().encode(updated) {
            defaults.set(data, forKey: type.storageKey)
        }
    }

    private func requestAuthorizationIfNeeded() async {
        let current = await center.notificationSettings()
        if current.authorizationStatus == .notDetermined {
            _ = try? await center.requestAuthorization(options: [.alert, .sound])
        }
        await refreshAuthorization()
    }

    private func reschedule(_ type: ReminderType) async {
        center.removePendingNotificationRequests(withIdentifiers: [type.identifier])
        let current = settings(for: type)
        guard current.enabled else { return }

        var components = DateComponents(hour: current.hour, minute: current.minute)
        if current.frequency == .weekly {
            components.weekday = current.weekday
        }
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: type.identifier,
            content: makeContent(for: type),
            trigger: trigger
        )
        try? await center.add(request)
    }

    private func makeContent(for type: ReminderType) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = type.title
        content.body = type.body
        content.sound = .default
        if let destination = type.destination {
            content.userInfo = ["destination": destination]
        }
        return content
    }

    // Show reminders as banners even while the app is in the foreground.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    // Tapping a breathing reminder opens the Breathing section.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let destination = response.notification.request.content.userInfo["destination"] as? String
        await MainActor.run {
            if destination == "breathing" {
                self.pendingDestination = .breathing
            }
        }
    }
}
