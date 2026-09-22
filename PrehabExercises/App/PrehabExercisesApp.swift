import SwiftUI

@main
struct PrehabExercisesApp: App {
    @StateObject private var progressStore = ProgressStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(progressStore)
        }
    }
}
