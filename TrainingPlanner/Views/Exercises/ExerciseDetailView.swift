import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise

    var body: some View {
        List {
            Section("Resumen") {
                Text(exercise.exerciseExplanation)
                LabeledContent("Nivel", value: exercise.level.rawValue)
                LabeledContent("Objetivo", value: exercise.goal.rawValue)
            }
        }
        .navigationTitle(exercise.name)
    }
}
