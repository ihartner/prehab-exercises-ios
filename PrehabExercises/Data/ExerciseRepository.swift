import Foundation

/// Exercise plan transcribed from PREhab exercises.pdf.
/// Phase 1 pre-surgery exercises, ordered lying -> sitting -> standing.
enum ExerciseRepository {
    static let all: [Exercise] = [
        Exercise(
            id: 1,
            name: "Ankle Pumps",
            phase: .lying,
            type: .reps,
            instructions: [
                "Lie down.",
                "Bend your ankle to move one foot up and down. Then do the other foot."
            ],
            reps: 10,
            holdSeconds: 3,
            restSeconds: 3,
            imageName: "ex_1"
        ),
        Exercise(
            id: 2,
            name: "Simple Thigh Squeezes",
            phase: .lying,
            type: .reps,
            instructions: [
                "Lie down and bring one knee up for support. Keep the kneecap and toes of your straight leg facing the ceiling.",
                "Pull your toes up toward your head.",
                "Tighten the muscles in front of your thigh and push the back of your knee into the bed."
            ],
            reps: 5,
            holdSeconds: 6,
            restSeconds: 5,
            imageName: "ex_2"
        ),
        Exercise(
            id: 3,
            name: "Harder Thigh Squeezes",
            phase: .lying,
            type: .reps,
            instructions: [
                "Lie down and place a firm roll under your knee.",
                "Straighten your leg, lifting your foot off the bed."
            ],
            reps: 5,
            holdSeconds: 6,
            restSeconds: 5,
            imageName: "ex_3"
        ),
        Exercise(
            id: 4,
            name: "Thigh Lifts",
            phase: .lying,
            type: .reps,
            instructions: [
                "Lie down and bring one knee up for support.",
                "Tighten your thigh muscles and lift your other leg, keeping the knee straight."
            ],
            reps: 5,
            holdSeconds: 6,
            restSeconds: 5,
            imageName: "ex_4"
        ),
        Exercise(
            id: 5,
            name: "Knee Straightening",
            phase: .lying,
            type: .reps,
            instructions: [
                "Lie down and bring one knee up for support. Keep the kneecap and toes of your straight leg facing the ceiling.",
                "Place a small roll under one ankle and push the knee down toward the bed."
            ],
            reps: 5,
            holdSeconds: 30,
            restSeconds: 8,
            imageName: "ex_5"
        ),
        Exercise(
            id: 6,
            name: "Knee Bend",
            phase: .lying,
            type: .reps,
            instructions: [
                "Bend your knee by sliding your heel along the bed toward your buttocks. Keep your knee facing the ceiling.",
                "Slowly straighten your knee by sliding your heel back to the starting position."
            ],
            reps: 5,
            holdSeconds: 6,
            restSeconds: 5,
            imageName: "ex_6"
        ),
        Exercise(
            id: 7,
            name: "Core Stability",
            phase: .lying,
            type: .reps,
            instructions: [
                "Lie or sit with your back supported, bend both knees, and keep your feet flat.",
                "Tighten your lower stomach muscles by pulling your belly button down towards your spine.",
                "Squeeze the pelvic muscles that stop the flow of pee. Breathe normally while holding."
            ],
            reps: 5,
            holdSeconds: 6,
            restSeconds: 5,
            imageName: "ex_7"
        ),
        Exercise(
            id: 8,
            name: "Bridges",
            phase: .lying,
            type: .duration,
            instructions: [
                "Lying on your back with a block between your knees, inhale to prepare.",
                "Exhale, zip up through your deep core, press through your feet, and bridge your hips up.",
                "Lower and repeat for the full minute."
            ],
            durationSeconds: 60,
            imageName: "ex_8"
        ),
        Exercise(
            id: 9,
            name: "Armchair Push-Ups",
            phase: .sitting,
            type: .reps,
            instructions: [
                "Sit on a steady chair, with your feet flat on the floor.",
                "Push up with both arms to lift yourself a few inches off the seat."
            ],
            reps: 5,
            holdSeconds: 6,
            restSeconds: 5,
            imageName: "ex_9"
        ),
        Exercise(
            id: 10,
            name: "Sitting Knee Bends",
            phase: .sitting,
            type: .reps,
            instructions: [
                "Sit on a steady chair with your feet flat on the floor.",
                "Slowly slide your foot back as far as you can."
            ],
            reps: 5,
            holdSeconds: 6,
            restSeconds: 5,
            imageName: "ex_10"
        ),
        Exercise(
            id: 11,
            name: "Sitting Knee Straightening",
            phase: .sitting,
            type: .reps,
            instructions: [
                "Sit on a steady chair with your thigh supported.",
                "Lift your foot and straighten your knee."
            ],
            reps: 5,
            holdSeconds: 6,
            restSeconds: 5,
            imageName: "ex_11"
        ),
        Exercise(
            id: 12,
            name: "Standing Knee Bends",
            phase: .standing,
            type: .reps,
            instructions: [
                "Stand straight, tuck in your stomach, and tighten your buttocks. Hold on to a table or counter for support.",
                "Slowly bend your knee by lifting your heel towards your buttocks."
            ],
            reps: 5,
            holdSeconds: 6,
            restSeconds: 5,
            imageName: "ex_12"
        ),
        Exercise(
            id: 13,
            name: "Standing Knee Lift",
            phase: .standing,
            type: .reps,
            instructions: [
                "Hold on to a table or counter for support.",
                "Lift your knee, as if you were going up a step."
            ],
            reps: 5,
            holdSeconds: 6,
            restSeconds: 5,
            imageName: "ex_13"
        ),
        Exercise(
            id: 14,
            name: "Mini Knee Bends",
            phase: .standing,
            type: .reps,
            instructions: [
                "Hold on to a table or counter for support. Stand with your legs shoulder-width apart and your toes pointed forward.",
                "Keeping your weight on your heels, slightly bend your knees so you can still see your toes. Stick your buttocks back like you are starting to sit down."
            ],
            reps: 5,
            holdSeconds: 6,
            restSeconds: 5,
            imageName: "ex_14"
        ),
        Exercise(
            id: 15,
            name: "Heel Raises",
            phase: .standing,
            type: .reps,
            instructions: [
                "Place both hands on a supportive surface for balance. Stand with equal weight on both feet.",
                "Raise both heels off the ground, going up on your toes, then lower slowly."
            ],
            reps: 10,
            holdSeconds: 3,
            restSeconds: 3,
            imageName: "ex_15"
        )
    ]
}
