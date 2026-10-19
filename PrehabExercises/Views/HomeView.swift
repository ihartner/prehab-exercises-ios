import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @State private var path = NavigationPath()

    private let exercises = ExerciseRepository.all

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: 12) {
                    WeeklyProgressCard(weekProgress: computeWeekProgress(store: progressStore))

                    Button {
                        path.append(AppRoute.session(startIndex: 0))
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Full Session")
                                .font(.title3.bold())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColor.primary)
                    .foregroundStyle(AppColor.onPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                        Button {
                            path.append(AppRoute.session(startIndex: index))
                        } label: {
                            ExerciseCard(exercise: exercise)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
            .background(AppColor.background)
            .navigationTitle("Prehab Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColor.primaryContainer, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button {
                            path.append(AppRoute.calendar)
                        } label: {
                            Label("Calendar", systemImage: "calendar")
                        }
                        Button {
                            path.append(AppRoute.settings)
                        } label: {
                            Label("Settings", systemImage: "gearshape")
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(AppColor.onPrimaryContainer)
                    }
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .session(let startIndex):
                    SessionView(startIndex: startIndex, progressStore: progressStore) {
                        path.removeLast(path.count)
                    }
                case .calendar:
                    CalendarView()
                case .settings:
                    SettingsView()
                }
            }
        }
    }
}

private struct WeeklyProgressCard: View {
    let weekProgress: WeekProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("This week")
                    .font(.title3.weight(.semibold))
                Spacer()
                Text("\(weekProgress.completedCount) of \(weekProgress.goal) days")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(weekProgress.completedCount >= weekProgress.goal ? AppColor.primary : AppColor.inkMuted)
            }

            HStack {
                ForEach(weekProgress.days) { day in
                    DayDot(day: day)
                    if day.id != weekProgress.days.last?.id {
                        Spacer()
                    }
                }
            }

            if weekProgress.currentStreakDays > 1 {
                Text("\u{1F525} \(weekProgress.currentStreakDays) day streak")
                    .font(.subheadline)
                    .foregroundStyle(AppColor.inkMuted)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct DayDot: View {
    let day: DayStatus

    var body: some View {
        ZStack {
            Circle()
                .fill(day.isCompleted ? AppColor.primary : AppColor.imageBackground)
                .frame(width: 32, height: 32)
            if day.isToday && !day.isCompleted {
                Circle()
                    .stroke(AppColor.primary, lineWidth: 2)
                    .frame(width: 32, height: 32)
            }
            Text(day.label)
                .font(.caption2)
                .foregroundStyle(day.isCompleted ? AppColor.onPrimary : AppColor.inkMuted)
        }
    }
}

private struct ExerciseCard: View {
    let exercise: Exercise

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColor.imageBackground)
                    .frame(width: 56, height: 56)
                if let imageName = exercise.imageName {
                    Image(imageName)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(AppColor.primary)
                        .frame(width: 48, height: 48)
                        .padding(4)
                } else {
                    Image(systemName: exercise.phase.systemImageName)
                        .foregroundStyle(AppColor.primary)
                        .font(.title2)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(exercise.phase.displayName)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppColor.secondaryContainer)
                    .foregroundStyle(AppColor.onSecondaryContainer)
                    .clipShape(Capsule())

                Text(exercise.name)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppColor.ink)

                Text(exercise.reps > 0 ? "\(exercise.reps) reps, hold \(exercise.holdSeconds)s" : "\(exercise.durationSeconds)s")
                    .font(.subheadline)
                    .foregroundStyle(AppColor.inkMuted)
            }
            Spacer()
        }
        .padding(16)
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
