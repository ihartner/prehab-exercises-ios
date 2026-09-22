import Foundation

struct CalendarDay: Identifiable {
    let date: Date
    let dayNumber: Int
    let isCompleted: Bool
    let isToday: Bool

    var id: TimeInterval { date.timeIntervalSince1970 }
}

struct MonthProgress {
    let monthDate: Date
    /// Each inner array has exactly 7 entries (Sun-Sat); nil marks a padding cell outside the month.
    let weeks: [[CalendarDay?]]
    let completedCount: Int
    let monthTitle: String
}

func computeMonthProgress(monthDate: Date, store: ProgressStore, today: Date = Date()) -> MonthProgress {
    var calendar = Calendar(identifier: .gregorian)
    calendar.firstWeekday = 1 // Sunday

    let components = calendar.dateComponents([.year, .month], from: monthDate)
    let firstOfMonth = calendar.date(from: components) ?? monthDate
    let startOfToday = calendar.startOfDay(for: today)

    let weekdayOfFirst = calendar.component(.weekday, from: firstOfMonth) // 1 = Sunday
    let leadingBlanks = weekdayOfFirst - 1
    let daysInMonth = calendar.range(of: .day, in: .month, for: firstOfMonth)?.count ?? 30

    var cells: [CalendarDay?] = Array(repeating: nil, count: leadingBlanks)
    for day in 1...daysInMonth {
        guard let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) else { continue }
        cells.append(
            CalendarDay(
                date: date,
                dayNumber: day,
                isCompleted: store.isCompleted(date),
                isToday: calendar.isDate(date, inSameDayAs: startOfToday)
            )
        )
    }
    while cells.count % 7 != 0 {
        cells.append(nil)
    }

    let weeks = stride(from: 0, to: cells.count, by: 7).map { Array(cells[$0..<$0 + 7]) }
    let completedCount = weeks.flatMap { $0 }.filter { $0?.isCompleted == true }.count

    let titleFormatter = DateFormatter()
    titleFormatter.dateFormat = "LLLL yyyy"

    return MonthProgress(
        monthDate: firstOfMonth,
        weeks: weeks,
        completedCount: completedCount,
        monthTitle: titleFormatter.string(from: firstOfMonth)
    )
}
