import Foundation

enum BreathingStatus: Equatable {
    case intro
    case running
    case finished
}

struct BreathingUiState {
    let exercise: BreathingExercise
    var status: BreathingStatus = .intro
    var cycle: Int = 0
    var cue: String = "Get comfortable"
    var secondsRemaining: Int = 0
    /// 0 = lungs empty, 1 = lungs full; drives the size of the breathing circle.
    var level: Double = 0
    var isPaused: Bool = false
    var voiceEnabled: Bool = true
}

@MainActor
final class BreathingSessionViewModel: ObservableObject {

    @Published private(set) var state: BreathingUiState

    private let exercise: BreathingExercise
    private let voice = VoiceGuide()
    private var sessionTask: Task<Void, Never>?

    private static let tickMilliseconds = 50

    init(exerciseId: Int) {
        let exercise = BreathingRepository.byId(exerciseId)
        self.exercise = exercise
        self.state = BreathingUiState(exercise: exercise)
        sessionTask = Task { [weak self] in
            await self?.runSession()
        }
    }

    private func runSession() async {
        await sayAndWait("\(exercise.name). \(exercise.intro)")
        if Task.isCancelled { return }
        await sayAndWait("Let's begin.")

        var level = 0.0
        for cycle in 1...max(exercise.cycles, 1) {
            for step in exercise.steps {
                if Task.isCancelled { return }
                state.status = .running
                state.cycle = cycle
                state.cue = step.cue
                state.secondsRemaining = step.seconds
                say(step.cue)
                level = await runStep(step, startLevel: level)
            }
        }

        if Task.isCancelled { return }
        state.status = .finished
        state.cue = "Well done"
        await sayAndWait("Well done. Take a moment to notice how you feel.")
    }

    /// Animates the breathing level across one step and returns the level it finished at.
    private func runStep(_ step: BreathStep, startLevel: Double) async -> Double {
        let totalMs = step.seconds * 1000
        var elapsedMs = 0
        while elapsedMs < totalMs {
            await awaitIfPaused()
            if Task.isCancelled { return startLevel }
            try? await Task.sleep(nanoseconds: UInt64(Self.tickMilliseconds) * 1_000_000)
            if Task.isCancelled { return startLevel }
            elapsedMs += Self.tickMilliseconds

            let fraction = min(Double(elapsedMs) / Double(totalMs), 1)
            let eased = fraction * fraction * (3 - 2 * fraction)
            state.level = startLevel + (step.endLevel - startLevel) * eased
            state.secondsRemaining = Int((Double(totalMs - elapsedMs) / 1000.0).rounded(.up))
        }
        return step.endLevel
    }

    private func awaitIfPaused() async {
        while state.isPaused {
            if Task.isCancelled { return }
            try? await Task.sleep(nanoseconds: 200_000_000)
        }
    }

    private func say(_ text: String) {
        if state.voiceEnabled { voice.speak(text) }
    }

    private func sayAndWait(_ text: String) async {
        if state.voiceEnabled {
            await voice.speakAndWait(text)
        } else {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
        }
    }

    func togglePause() {
        state.isPaused.toggle()
        if state.isPaused { voice.stop() }
    }

    func toggleVoice() {
        state.voiceEnabled.toggle()
        if !state.voiceEnabled { voice.stop() }
    }

    func endSession() {
        sessionTask?.cancel()
        voice.stop()
    }

    func cleanup() {
        sessionTask?.cancel()
        voice.stop()
    }
}
