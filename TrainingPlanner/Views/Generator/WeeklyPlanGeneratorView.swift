import SwiftUI

struct WeeklyPlanGeneratorView: View {
    var body: some View {
        ContentUnavailableView(
            "Generador semanal",
            systemImage: "wand.and.stars",
            description: Text("La generación automática se implementará en la Fase 5.")
        )
        .navigationTitle("Generador")
    }
}

#Preview {
    NavigationStack {
        WeeklyPlanGeneratorView()
    }
}
