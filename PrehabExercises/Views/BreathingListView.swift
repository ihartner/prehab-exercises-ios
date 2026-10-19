import SwiftUI

struct BreathingListView: View {
    let onOpen: (Int) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Slow, guided breathing to help you relax and feel grounded. "
                    + "These are separate from your prehab exercises and don't count toward your weekly goal.")
                    .font(.subheadline)
                    .foregroundStyle(AppColor.inkMuted)

                ForEach(BreathingRepository.all) { exercise in
                    Button {
                        onOpen(exercise.id)
                    } label: {
                        BreathingCard(exercise: exercise)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
        .background(AppColor.background)
        .navigationTitle("Breathing")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColor.primaryContainer, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

private struct BreathingCard: View {
    let exercise: BreathingExercise

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColor.imageBackground)
                    .frame(width: 56, height: 56)
                Image(systemName: "figure.mind.and.body")
                    .font(.title)
                    .foregroundStyle(AppColor.primary)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(exercise.pattern)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppColor.secondaryContainer)
                    .foregroundStyle(AppColor.onSecondaryContainer)
                    .clipShape(Capsule())

                Text(exercise.name)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppColor.ink)

                Text(exercise.tagline)
                    .font(.subheadline)
                    .foregroundStyle(AppColor.inkMuted)
                    .multilineTextAlignment(.leading)

                Text(exercise.durationLabel)
                    .font(.footnote)
                    .foregroundStyle(AppColor.inkMuted)
            }
            Spacer()
        }
        .padding(16)
        .background(AppColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
