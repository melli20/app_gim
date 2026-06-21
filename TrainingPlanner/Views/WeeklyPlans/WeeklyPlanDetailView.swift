import SwiftUI

struct WeeklyPlanDetailView: View {
    let plan: WeeklyPlan

    var body: some View {
        List(plan.days.sorted { $0.weekdayRawValue < $1.weekdayRawValue }) { day in
            Section(day.weekday.title) {
                if day.plannedExercises.isEmpty {
                    Text("Sin ejercicios")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(day.plannedExercises.sorted { $0.sortOrder < $1.sortOrder }) { plannedExercise in
                        Text(plannedExercise.exercise?.name ?? "Ejercicio eliminado")
                    }
                }
            }
        }
        .navigationTitle(plan.title)
    }
}
