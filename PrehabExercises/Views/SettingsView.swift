import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var reminders: ReminderManager

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if reminders.notificationsBlocked
                    && (reminders.exerciseSettings.enabled || reminders.breathingSettings.enabled) {
                    SettingsCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notifications are turned off for this app, so reminders won't appear.")
                                .font(.subheadline)
                                .foregroundStyle(AppColor.error)
                            Button("Open notification settings") {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .foregroundStyle(AppColor.primary)
                        }
                    }
                }

                ReminderSection(
                    type: .exercise,
                    title: "Exercise reminders",
                    description: "Get a notification reminding you to do your prehab exercises."
                )
                ReminderSection(
                    type: .breathing,
                    title: "Breathing reminders",
                    description: "Get a notification reminding you to take a guided breathing break."
                )
            }
            .padding(16)
        }
        .background(AppColor.background)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColor.primaryContainer, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task { await reminders.refreshAuthorization() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Task { await reminders.refreshAuthorization() }
        }
    }
}

/// A reminder's on/off switch and, when on, its daily/weekly, day, and time options.
private struct ReminderSection: View {
    @EnvironmentObject private var reminders: ReminderManager

    let type: ReminderType
    let title: String
    let description: String

    var body: some View {
        let settings = reminders.settings(for: type)

        SettingsCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(AppColor.ink)
                        Text(description)
                            .font(.footnote)
                            .foregroundStyle(AppColor.inkMuted)
                    }
                    Spacer()
                    Toggle("", isOn: enabledBinding)
                        .labelsHidden()
                        .tint(AppColor.primary)
                }

                if settings.enabled {
                    Text("Repeat")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColor.ink)
                    Picker("Repeat", selection: frequencyBinding) {
                        ForEach(ReminderFrequency.allCases, id: \.self) { frequency in
                            Text(frequency.displayName).tag(frequency)
                        }
                    }
                    .pickerStyle(.segmented)

                    if settings.frequency == .weekly {
                        Text("Day")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppColor.ink)
                        weekdaySelector(selected: settings.weekday)
                    }

                    DatePicker(
                        "Time",
                        selection: timeBinding,
                        displayedComponents: .hourAndMinute
                    )
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColor.ink)
                    .tint(AppColor.primary)

                    if let next = reminders.nextReminderDate(for: type) {
                        Text("Next reminder: \(next.formatted(date: .abbreviated, time: .shortened))")
                            .font(.footnote)
                            .foregroundStyle(AppColor.inkMuted)
                    }

                    Button("Send test notification") {
                        Task { await reminders.sendTestNotification(for: type) }
                    }
                    .foregroundStyle(AppColor.primary)
                }
            }
        }
    }

    private var enabledBinding: Binding<Bool> {
        Binding(
            get: { reminders.settings(for: type).enabled },
            set: { value in reminders.update(type) { $0.enabled = value } }
        )
    }

    private var frequencyBinding: Binding<ReminderFrequency> {
        Binding(
            get: { reminders.settings(for: type).frequency },
            set: { value in reminders.update(type) { $0.frequency = value } }
        )
    }

    private var timeBinding: Binding<Date> {
        Binding(
            get: {
                let current = reminders.settings(for: type)
                return Calendar.current.date(
                    from: DateComponents(hour: current.hour, minute: current.minute)
                ) ?? Date()
            },
            set: { date in
                let components = Calendar.current.dateComponents([.hour, .minute], from: date)
                reminders.update(type) {
                    $0.hour = components.hour ?? 9
                    $0.minute = components.minute ?? 0
                }
            }
        )
    }

    private func weekdaySelector(selected: Int) -> some View {
        let calendar = Calendar.current
        return HStack {
            ForEach(1...7, id: \.self) { day in
                Button {
                    reminders.update(type) { $0.weekday = day }
                } label: {
                    Text(calendar.veryShortWeekdaySymbols[day - 1])
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 38, height: 38)
                        .background(day == selected ? AppColor.primary : AppColor.imageBackground)
                        .foregroundStyle(day == selected ? AppColor.onPrimary : AppColor.inkMuted)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(calendar.weekdaySymbols[day - 1])
                if day != 7 {
                    Spacer()
                }
            }
        }
    }
}

private struct SettingsCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColor.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
