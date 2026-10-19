import Foundation

/// One phase of a breath. `endLevel` is how full the lungs (and the on-screen circle) should be
/// at the end of the step: 0 = empty, 1 = full.
struct BreathStep {
    let cue: String
    let seconds: Int
    let endLevel: Double
}

struct BreathingExercise: Identifiable {
    let id: Int
    let name: String
    let pattern: String
    let tagline: String
    let intro: String
    let steps: [BreathStep]
    let cycles: Int

    var totalSeconds: Int {
        steps.reduce(0) { $0 + $1.seconds } * cycles
    }

    var durationLabel: String {
        let minutes = Int((Double(totalSeconds) / 60.0).rounded(.up))
        return minutes <= 1 ? "About 1 min" : "About \(minutes) min"
    }
}

enum BreathingRepository {
    static let all: [BreathingExercise] = [
        BreathingExercise(
            id: 1,
            name: "Box Breathing",
            pattern: "4 - 4 - 4 - 4",
            tagline: "Steady and grounding. Calms your nerves and sharpens focus.",
            intro: "Box breathing. Sit comfortably with your feet on the floor and your back supported. "
                + "We'll breathe in, hold, breathe out, and hold, each for four counts. "
                + "Breathe in through your nose and out through your mouth.",
            steps: [
                BreathStep(cue: "Breathe in", seconds: 4, endLevel: 1),
                BreathStep(cue: "Hold", seconds: 4, endLevel: 1),
                BreathStep(cue: "Breathe out", seconds: 4, endLevel: 0),
                BreathStep(cue: "Hold", seconds: 4, endLevel: 0)
            ],
            cycles: 6
        ),
        BreathingExercise(
            id: 2,
            name: "4-7-8 Breathing",
            pattern: "4 - 7 - 8",
            tagline: "Deeply relaxing. A slow rhythm that helps you unwind and prepare for sleep.",
            intro: "Four seven eight breathing. Rest the tip of your tongue behind your upper front teeth. "
                + "Breathe in quietly through your nose for four, hold for seven, "
                + "and breathe out slowly through your mouth for eight.",
            steps: [
                BreathStep(cue: "Breathe in", seconds: 4, endLevel: 1),
                BreathStep(cue: "Hold", seconds: 7, endLevel: 1),
                BreathStep(cue: "Breathe out slowly", seconds: 8, endLevel: 0)
            ],
            cycles: 4
        ),
        BreathingExercise(
            id: 3,
            name: "Belly Breathing",
            pattern: "4 - 6",
            tagline: "Slow breaths into your belly. Eases tension and slows your heart rate.",
            intro: "Belly breathing. Place one hand on your chest and one on your belly. "
                + "Breathe in slowly through your nose and feel your belly rise. "
                + "Then breathe out slowly through pursed lips, as if blowing through a straw.",
            steps: [
                BreathStep(cue: "Breathe in", seconds: 4, endLevel: 1),
                BreathStep(cue: "Breathe out slowly", seconds: 6, endLevel: 0)
            ],
            cycles: 8
        ),
        BreathingExercise(
            id: 4,
            name: "Coherent Breathing",
            pattern: "5 - 5",
            tagline: "Smooth, even breaths at about six a minute. Balances mind and body.",
            intro: "Coherent breathing. Breathe in gently through your nose for five, "
                + "and breathe out for five, with no pause in between. "
                + "Keep each breath smooth and relaxed.",
            steps: [
                BreathStep(cue: "Breathe in", seconds: 5, endLevel: 1),
                BreathStep(cue: "Breathe out", seconds: 5, endLevel: 0)
            ],
            cycles: 10
        ),
        BreathingExercise(
            id: 5,
            name: "Physiological Sigh",
            pattern: "2 + 1 - 6",
            tagline: "A quick reset. Two breaths in and one long breath out melt away tension.",
            intro: "Physiological sigh. Breathe in deeply through your nose, "
                + "then take a second, short sip of air on top to fill your lungs completely. "
                + "Then let a long, slow breath out through your mouth.",
            steps: [
                BreathStep(cue: "Breathe in", seconds: 2, endLevel: 0.75),
                BreathStep(cue: "A little more", seconds: 1, endLevel: 1),
                BreathStep(cue: "Breathe out slowly", seconds: 6, endLevel: 0)
            ],
            cycles: 6
        )
    ]

    static func byId(_ id: Int) -> BreathingExercise {
        all.first { $0.id == id } ?? all[0]
    }
}
