import Foundation

enum ExercisePhase: String, CaseIterable, Equatable {
    case lying
    case sitting
    case standing

    var displayName: String {
        switch self {
        case .lying: return "Lying"
        case .sitting: return "Sitting"
        case .standing: return "Standing"
        }
    }

    var positionCue: String {
        switch self {
        case .lying: return "Lie down on a firm, flat surface such as a bed or mat."
        case .sitting: return "Have a seat in a steady chair with your feet flat on the floor."
        case .standing: return "Stand up. Hold on to a table or counter for support."
        }
    }

    var systemImageName: String {
        switch self {
        case .lying: return "bed.double.fill"
        case .sitting: return "chair.fill"
        case .standing: return "figure.stand"
        }
    }
}

enum ExerciseType {
    case reps
    case duration
}

struct Exercise: Identifiable {
    let id: Int
    let name: String
    let phase: ExercisePhase
    let type: ExerciseType
    let instructions: [String]
    var reps: Int = 0
    var holdSeconds: Int = 4
    var restSeconds: Int = 3
    var durationSeconds: Int = 0
    /// Name of the image asset (a template/alpha-mask PNG) in Assets.xcassets, if any.
    var imageName: String? = nil
}
