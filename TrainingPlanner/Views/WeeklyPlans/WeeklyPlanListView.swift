import SwiftUI

struct WeeklyPlanListView: View {
    var body: some View {
        List {
            NavigationLink {
                WeeklyPlanGeneratorView()
            } label: {
                Label("Crear tabla automáticamente", systemImage: "wand.and.stars")
            }

            ContentUnavailableView(
                "Tablas semanales",
                systemImage: "calendar",
                description: Text("La creación manual se implementará en la Fase 4.")
            )
        }
        .navigationTitle("Semanas")
    }
}

#Preview {
    NavigationStack {
        WeeklyPlanListView()
    }
}
