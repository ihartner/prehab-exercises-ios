import SwiftUI

struct SessionView: View {
    @StateObject private var viewModel: SessionViewModel
    let onSessionEnded: () -> Void

    init(startIndex: Int, progressStore: ProgressStore, onSessionEnded: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: SessionViewModel(startIndex: startIndex, progressStore: progressStore))
        self.onSessionEnded = onSessionEnded
    }

    var body: some View {
        Group {
            if viewModel.state.status == .finished {
                SessionCompleteView(onDone: onSessionEnded)
            } else if let exercise = viewModel.state.exercise {
                sessionContent(exercise: exercise)
            } else {
                Color.clear
            }
        }
        .navigationBarBackButtonHidden(viewModel.state.status == .running)
        .onDisappear { viewModel.cleanup() }
    }

    private func sessionContent(exercise: Exercise) -> some View {
        let state = viewModel.state
        let totalForStage: Int = {
            switch state.stage {
            case .hold: return exercise.reps > 0 ? exercise.holdSeconds : exercise.durationSeconds
            case .rest: return exercise.restSeconds
            case .intro: return 1
            }
        }()
        let progressFraction: Double = state.stage == .intro
            ? 0
            : min(max(Double(state.secondsRemaining) / Double(max(totalForStage, 1)), 0), 1)

        return ScrollView {
            VStack(spacing: 16) {
                ProgressView(value: Double(state.exerciseIndex + 1), total: Double(state.totalExercises))
                    .tint(AppColor.primary)

                Text("Exercise \(state.exerciseIndex + 1) of \(state.totalExercises)")
                    .font(.subheadline)
                    .foregroundStyle(AppColor.inkMuted)

                Label(exercise.phase.displayName, systemImage: exercise.phase.systemImageName)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(AppColor.secondaryContainer)
                    .foregroundStyle(AppColor.onSecondaryContainer)
                    .clipShape(Capsule())

                if let imageName = exercise.imageName {
                    Image(imageName)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(AppColor.primary)
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .frame(height: 140)
                        .background(AppColor.imageBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Text(exercise.name)
                    .font(.title.weight(.semibold))
                    .foregroundStyle(AppColor.ink)
                    .multilineTextAlignment(.center)

                if exercise.reps > 0 {
                    Text("Rep \(state.currentRep) of \(exercise.reps)")
                        .font(.title3)
                        .foregroundStyle(AppColor.inkMuted)
                }

                ZStack {
                    Circle()
                        .stroke(AppColor.imageBackground, lineWidth: 10)
                        .frame(width: 180, height: 180)
                    Circle()
                        .trim(from: 0, to: progressFraction)
                        .stroke(
                            state.stage == .rest ? AppColor.secondaryContainer : AppColor.primary,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 180, height: 180)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progressFraction)

                    VStack(spacing: 4) {
                        Text(state.stage == .intro ? "" : "\(state.secondsRemaining)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(AppColor.ink)
                        Text(stageLabel(state.stage))
                            .font(.title3)
                            .foregroundStyle(AppColor.inkMuted)
                    }
                }
                .padding(.vertical, 16)

                HStack(spacing: 20) {
                    Button {
                        viewModel.skip()
                    } label: {
                        Image(systemName: "forward.end.fill")
                            .frame(width: 56, height: 56)
                    }
                    .buttonStyle(.bordered)
                    .clipShape(Circle())

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
                }

                Button("End Session") {
                    viewModel.endSession()
                    onSessionEnded()
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

    private func stageLabel(_ stage: RepStage) -> String {
        switch stage {
        case .intro: return "Get ready"
        case .hold: return "Hold"
        case .rest: return "Rest"
        }
    }
}

private struct SessionCompleteView: View {
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(AppColor.primary)
            Text("Session complete!")
                .font(.title.weight(.semibold))
                .foregroundStyle(AppColor.ink)
            Button("Back to Home", action: onDone)
                .buttonStyle(.borderedProminent)
                .tint(AppColor.primary)
                .foregroundStyle(AppColor.onPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
    }
}
