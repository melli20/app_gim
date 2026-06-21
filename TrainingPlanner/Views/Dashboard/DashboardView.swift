import SwiftUI

struct DashboardView: View {
    var body: some View {
        List {
            Section {
                NavigationLink {
                    ExerciseListView()
                } label: {
                    Label("Base de ejercicios", systemImage: "figure.strengthtraining.traditional")
                }

                NavigationLink {
                    WeeklyPlanListView()
                } label: {
                    Label("Tablas semanales", systemImage: "calendar")
                }

                NavigationLink {
                    WeeklyPlanGeneratorView()
                } label: {
                    Label("Generador semanal", systemImage: "wand.and.stars")
                }
            }

            Section("Estado") {
                ContentUnavailableView(
                    "Training Planner",
                    systemImage: "checklist",
                    description: Text("Fase 1: navegación, modelos y SwiftData preparados.")
                )
            }
        }
        .navigationTitle("Inicio")
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
}
