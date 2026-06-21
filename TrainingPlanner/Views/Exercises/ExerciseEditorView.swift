import SwiftUI

struct ExerciseEditorView: View {
    var body: some View {
        ContentUnavailableView(
            "Editor de ejercicio",
            systemImage: "square.and.pencil",
            description: Text("El formulario de creación y edición se implementará en la Fase 2.")
        )
        .navigationTitle("Editar ejercicio")
    }
}
