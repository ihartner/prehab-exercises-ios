import SwiftUI

@main
struct PrehabExercisesApp: App {
    @StateObject private var progressStore = ProgressStore()
    @StateObject private var reminderManager = ReminderManager()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(progressStore)
                .environmentObject(reminderManager)
        }
    }
}
