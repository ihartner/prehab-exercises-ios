import SwiftUI

struct BreathingSessionView: View {
    @StateObject private var viewModel: BreathingSessionViewModel
    let onExit: () -> Void

    init(exerciseId: Int, onExit: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: BreathingSessionViewModel(exerciseId: exerciseId))
        self.onExit = onExit
    }

    var body: some View {
        Group {
            if viewModel.state.status == .finished {
                BreathingCompleteView(onDone: onExit)
            } else {
                sessionContent
            }
        }
        .navigationBarBackButtonHidden(true)
        .onDisappear { viewModel.cleanup() }
    }

    private var sessionContent: some View {
        let state = viewModel.state
        let exercise = state.exercise

        return ScrollView {
            VStack(spacing: 16) {
                Text(exercise.name)
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(AppColor.ink)
                    .multilineTextAlignment(.center)

                Text(state.status == .running ? "Cycle \(state.cycle) of \(exercise.cycles)" : exercise.pattern)
                    .font(.title3)
                    .foregroundStyle(AppColor.inkMuted)

                Text(state.cue)
                    .font(.title.weight(.medium))
                    .foregroundStyle(AppColor.ink)
                    .multilineTextAlignment(.center)
                    .frame(height: 40)
                    .padding(.top, 8)

                BreathingCircle(
                    level: state.level,
                    secondsRemaining: state.status == .running ? state.secondsRemaining : nil
                )
                .padding(.vertical, 8)

                if state.status == .intro {
                    Text(exercise.intro)
                        .font(.body)
                        .foregroundStyle(AppColor.inkMuted)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 20) {
                    Button {
                        viewModel.toggleVoice()
                    } label: {
                        Image(systemName: state.voiceEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .frame(width: 56, height: 56)
                    }
                    .buttonStyle(.bordered)
                    .clipShape(Circle())
                    .accessibilityLabel(state.voiceEnabled ? "Mute voice" : "Unmute voice")

                    Button {
                        viewModel.togglePause()
                    } label: {
                        Image(systemName: state.isPaused ? "play.fill" : "pause.fill")
                            .font(.title2)
                            .frame(width: 72, height: 72)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColor.primary)
                    .foregroundStyle(AppColor.onPrimary)
                    .clipShape(Circle())
                    .accessibilityLabel(state.isPaused ? "Resume" : "Pause")
                }
                .padding(.top, 8)

                Button("End Session") {
                    viewModel.endSession()
                    onExit()
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(AppColor.error)
                .padding(.top, 8)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .background(AppColor.background)
    }
}

private struct BreathingCircle: View {
    let level: Double
    let secondsRemaining: Int?

    private let maxSize: CGFloat = 280

    var body: some View {
        let scale = 0.5 + 0.5 * min(max(level, 0), 1)

        ZStack {
            Circle()
                .stroke(AppColor.inkMuted.opacity(0.35), lineWidth: 2)
                .frame(width: maxSize, height: maxSize)

            Circle()
                .fill(AppColor.primary.opacity(0.3))
                .overlay(Circle().stroke(AppColor.primary, lineWidth: 3))
                .frame(width: maxSize * scale, height: maxSize * scale)
                .animation(.linear(duration: 0.05), value: level)

            if let secondsRemaining {
                Text("\(secondsRemaining)")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(AppColor.ink)
            }
        }
        .frame(width: maxSize, height: maxSize)
    }
}

private struct BreathingCompleteView: View {
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(AppColor.primary)
            Text("Well done")
                .font(.title.weight(.semibold))
                .foregroundStyle(AppColor.ink)
            Text("Take a moment to notice how you feel.")
                .font(.body)
                .foregroundStyle(AppColor.inkMuted)
                .multilineTextAlignment(.center)
            Button("Done", action: onDone)
                .buttonStyle(.borderedProminent)
                .tint(AppColor.primary)
                .foregroundStyle(AppColor.onPrimary)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
    }
}
