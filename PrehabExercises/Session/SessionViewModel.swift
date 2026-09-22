import Foundation

enum RepStage: Equatable {
    case intro
    case hold
    case rest
}

enum SessionStatus: Equatable {
    case running
    case finished
}

struct SessionUiState {
    var exercise: Exercise?
    var exerciseIndex: Int = 0
    var totalExercises: Int = 0
    var stage: RepStage = .intro
    var currentRep: Int = 0
    var secondsRemaining: Int = 0
    var isPaused: Bool = false
    var status: SessionStatus = .running
}

@MainActor
final class SessionViewModel: ObservableObject {

    @Published private(set) var state: SessionUiState

    private let exercises: [Exercise] = ExerciseRepository.all
    private let voice = VoiceGuide()
    private let progressStore: ProgressStore
    private var sessionTask: Task<Void, Never>?

    init(startIndex: Int, progressStore: ProgressStore) {
        self.progressStore = progressStore
        self.state = SessionUiState(totalExercises: ExerciseRepository.all.count)
        runFrom(startIndex)
    }

    private func runFrom(_ index: Int) {
        sessionTask?.cancel()
        sessionTask = Task { [weak self] in
            guard let self else { return }
            var currentIndex = index
            var previousPhase: ExercisePhase? = index > 0 ? self.exercises[index - 1].phase : nil

            while currentIndex < self.exercises.count {
                if Task.isCancelled { return }
                let exercise = self.exercises[currentIndex]
                if previousPhase != exercise.phase {
                    await self.announcePhaseTransition(exercise)
                    if Task.isCancelled { return }
                }
                previousPhase = exercise.phase
                await self.runExercise(index: currentIndex, exercise: exercise)
                if Task.isCancelled { return }
                currentIndex += 1
            }

            if Task.isCancelled { return }
            self.state.status = .finished
            self.progressStore.recordCompletionToday()
            await self.voice.speakAndWait("Great job. You've completed today's session.")
        }
    }

    private func announcePhaseTransition(_ exercise: Exercise) async {
        await voice.speakAndWait(
            "Now let's move on to the \(exercise.phase.displayName.lowercased()) exercises. \(exercise.phase.positionCue)"
        )
    }

    private func runExercise(index: Int, exercise: Exercise) async {
        state.exercise = exercise
        state.exerciseIndex = index
        state.stage = .intro
        state.currentRep = 0
        state.secondsRemaining = 0

        await voice.speakAndWait("\(exercise.name). \(exercise.instructions.joined(separator: " "))")
        if Task.isCancelled { return }

        switch exercise.type {
        case .reps:
            await runRepsExercise(exercise)
        case .duration:
            await runDurationExercise(exercise)
        }
    }

    private func runRepsExercise(_ exercise: Exercise) async {
        for rep in 1...max(exercise.reps, 1) {
            await awaitIfPaused()
            if Task.isCancelled { return }
            state.stage = .hold
            state.currentRep = rep
            voice.speak("Rep \(rep)")
            await countdown(exercise.holdSeconds)
            if Task.isCancelled { return }

            if rep < exercise.reps {
                state.stage = .rest
                voice.speak("Rest")
                await countdown(exercise.restSeconds)
                if Task.isCancelled { return }
            }
        }
    }

    private func runDurationExercise(_ exercise: Exercise) async {
        state.stage = .hold
        state.currentRep = 1
        await countdown(exercise.durationSeconds)
    }

    private func countdown(_ seconds: Int) async {
        var remaining = seconds
        state.secondsRemaining = remaining
        while remaining > 0 {
            await awaitIfPaused()
            if Task.isCancelled { return }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            if Task.isCancelled { return }
            remaining -= 1
            state.secondsRemaining = remaining
        }
    }

    private func awaitIfPaused() async {
        while state.isPaused {
            if Task.isCancelled { return }
            try? await Task.sleep(nanoseconds: 200_000_000)
        }
    }

    func togglePause() {
        state.isPaused.toggle()
        if state.isPaused { voice.stop() }
    }

    func skip() {
        let nextIndex = state.exerciseIndex + 1
        voice.stop()
        state.isPaused = false
        runFrom(nextIndex)
    }

    func endSession() {
        sessionTask?.cancel()
        voice.stop()
        state.status = .finished
        progressStore.recordCompletionToday()
    }

    func cleanup() {
        sessionTask?.cancel()
        voice.stop()
    }
}
