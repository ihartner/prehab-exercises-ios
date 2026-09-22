import SwiftUI

struct CalendarView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @State private var displayedMonth: Date = Date()

    private static let weekdayHeaders = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        let monthProgress = computeMonthProgress(monthDate: displayedMonth, store: progressStore)
        let isCurrentOrFutureMonth = !isMonthBeforeCurrent(displayedMonth)

        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Button {
                        shiftMonth(by: -1)
                    } label: {
                        Image(systemName: "chevron.left")
                    }

                    Spacer()
                    Text(monthProgress.monthTitle)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(AppColor.ink)
                    Spacer()

                    Button {
                        shiftMonth(by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                    .disabled(isCurrentOrFutureMonth)
                }

                HStack {
                    ForEach(Array(Self.weekdayHeaders.enumerated()), id: \.offset) { _, label in
                        Text(label)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppColor.inkMuted)
                            .frame(width: 40)
                    }
                }

                VStack(spacing: 8) {
                    ForEach(Array(monthProgress.weeks.enumerated()), id: \.offset) { _, week in
                        HStack {
                            ForEach(Array(week.enumerated()), id: \.offset) { _, day in
                                CalendarDayCell(day: day)
                            }
                        }
                    }
                }

                let dayWord = monthProgress.completedCount == 1 ? "day" : "days"
                Text("\(monthProgress.completedCount) \(dayWord) completed this month")
                    .font(.body)
                    .foregroundStyle(AppColor.inkMuted)
                    .padding(.top, 8)

                Spacer()
            }
            .padding(16)
        }
        .background(AppColor.background)
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColor.primaryContainer, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func shiftMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }

    private func isMonthBeforeCurrent(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let comparison = calendar.compare(date, to: Date(), toGranularity: .month)
        return comparison == .orderedAscending
    }
}

private struct CalendarDayCell: View {
    let day: CalendarDay?

    var body: some View {
        Group {
            if let day {
                ZStack {
                    Circle()
                        .fill(day.isCompleted ? AppColor.primary : Color.clear)
                        .frame(width: 40, height: 40)
                    if day.isToday && !day.isCompleted {
                        Circle()
                            .stroke(AppColor.primary, lineWidth: 2)
                            .frame(width: 40, height: 40)
                    }
                    Text("\(day.dayNumber)")
                        .font(.body)
                        .foregroundStyle(day.isCompleted ? AppColor.onPrimary : AppColor.ink)
                }
            } else {
                Color.clear
            }
        }
        .frame(width: 40, height: 40)
        .frame(maxWidth: .infinity)
    }
}
