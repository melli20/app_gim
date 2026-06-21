import SwiftUI

struct ExerciseListView: View {
    var body: some View {
        ContentUnavailableView(
            "Ejercicios",
            systemImage: "figure.strengthtraining.traditional",
            description: Text("El CRUD completo se implementará en la Fase 2.")
        )
        .navigationTitle("Ejercicios")
    }
}

#Preview {
    NavigationStack {
        ExerciseListView()
    }
}
