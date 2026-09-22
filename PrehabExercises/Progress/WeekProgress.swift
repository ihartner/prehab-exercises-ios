import Foundation

struct DayStatus: Identifiable {
    let date: Date
    let label: String
    let isCompleted: Bool
    let isToday: Bool

    var id: TimeInterval { date.timeIntervalSince1970 }
}

struct WeekProgress {
    let days: [DayStatus]
    let completedCount: Int
    let goal: Int
    let currentStreakDays: Int
}

private let weeklyGoal = 4

/// Builds a Sunday-Saturday view of the current week.
func computeWeekProgress(store: ProgressStore, today: Date = Date()) -> WeekProgress {
    var calendar = Calendar(identifier: .gregorian)
    calendar.firstWeekday = 1 // Sunday

    let startOfToday = calendar.startOfDay(for: today)
    let weekday = calendar.component(.weekday, from: startOfToday) // 1 = Sunday ... 7 = Saturday
    let daysSinceSunday = weekday - 1
    guard let startOfWeek = calendar.date(byAdding: .day, value: -daysSinceSunday, to: startOfToday) else {
        return WeekProgress(days: [], completedCount: 0, goal: weeklyGoal, currentStreakDays: 0)
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "EEEEE" // narrow weekday symbol, e.g. "S"

    let days: [DayStatus] = (0..<7).compactMap { offset in
        guard let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek) else { return nil }
        return DayStatus(
            date: date,
            label: formatter.string(from: date),
            isCompleted: store.isCompleted(date),
            isToday: calendar.isDate(date, inSameDayAs: startOfToday)
        )
    }

    let completedCount = days.filter { $0.isCompleted }.count

    var streak = 0
    var cursor = startOfToday
    while store.isCompleted(cursor) {
        streak += 1
        guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
        cursor = previous
    }

    return WeekProgress(days: days, completedCount: completedCount, goal: weeklyGoal, currentStreakDays: streak)
}
