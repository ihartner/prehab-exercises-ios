import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var reminders: ReminderManager

    var body: some View {
        let settings = reminders.settings

        ScrollView {
            VStack(spacing: 16) {
                SettingsCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Exercise reminders")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(AppColor.ink)
                            Text("Get a notification reminding you to do your exercises.")
                                .font(.footnote)
                                .foregroundStyle(AppColor.inkMuted)
                        }
                        Spacer()
                        Toggle("", isOn: enabledBinding)
                            .labelsHidden()
                            .tint(AppColor.primary)
                    }
                }

                if settings.enabled {
                    SettingsCard {
                        VStack(alignment: .leading, spacing: 16) {
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

                            if let next = reminders.nextReminderDate {
                                Text("Next reminder: \(next.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.footnote)
                                    .foregroundStyle(AppColor.inkMuted)
                            }
                        }
                    }

                    if reminders.notificationsBlocked {
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

                    Button {
                        Task { await reminders.sendTestNotification() }
                    } label: {
                        Text("Send test notification")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.bordered)
                    .tint(AppColor.primary)
                }
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

    private var enabledBinding: Binding<Bool> {
        Binding(
            get: { reminders.settings.enabled },
            set: { value in reminders.update { $0.enabled = value } }
        )
    }

    private var frequencyBinding: Binding<ReminderFrequency> {
        Binding(
            get: { reminders.settings.frequency },
            set: { value in reminders.update { $0.frequency = value } }
        )
    }

    private var timeBinding: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(
                    from: DateComponents(hour: reminders.settings.hour, minute: reminders.settings.minute)
                ) ?? Date()
            },
            set: { date in
                let components = Calendar.current.dateComponents([.hour, .minute], from: date)
                reminders.update {
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
                    reminders.update { $0.weekday = day }
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
