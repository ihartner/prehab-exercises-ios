import Foundation
import Combine

/// Tracks which calendar days the user has done at least one exercise session.
/// Backed by UserDefaults so it survives app restarts.
@MainActor
final class ProgressStore: ObservableObject {

    private static let storageKey = "completed_dates"
    private static let dateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter
    }()

    @Published private(set) var completedDates: Set<String>

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.completedDates = Set(defaults.stringArray(forKey: Self.storageKey) ?? [])
    }

    func recordCompletionToday() {
        let today = Self.dateFormat.string(from: Date())
        guard !completedDates.contains(today) else { return }
        completedDates.insert(today)
        defaults.set(Array(completedDates), forKey: Self.storageKey)
    }

    func isCompleted(_ date: Date) -> Bool {
        completedDates.contains(Self.dateFormat.string(from: date))
    }
}
