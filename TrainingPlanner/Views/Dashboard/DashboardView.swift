import SwiftData
import SwiftUI

struct DashboardView: View {
    @Query private var exercises: [Exercise]
    @Query(sort: \WeeklyPlan.startDate, order: .reverse) private var plans: [WeeklyPlan]

    private var plannedExerciseCount: Int {
        plans.reduce(0) { result, plan in
            result + plan.days.reduce(0) { $0 + $1.plannedExercises.count }
        }
    }

    private var completedExerciseCount: Int {
        plans.reduce(0) { result, plan in
            result + plan.days.reduce(0) { dayResult, day in
                dayResult + day.plannedExercises.filter(\.isCompleted).count
            }
        }
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Training Planner")
                        .font(.title2.bold())

                    Text("Gestiona ejercicios, crea semanas de trabajo y reutiliza planificaciones anteriores.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section("Resumen") {
                HStack(spacing: 12) {
                    DashboardMetric(title: "Ejercicios", value: "\(exercises.count)", systemImage: "figure.strengthtraining.traditional")
                    DashboardMetric(title: "Semanas", value: "\(plans.count)", systemImage: "calendar")
                    DashboardMetric(title: "Hechos", value: "\(completedExerciseCount)/\(plannedExerciseCount)", systemImage: "checkmark.circle")
                }
                .padding(.vertical, 4)
            }

            Section("Accesos rápidos") {
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

                NavigationLink {
                    PlanHistoryView()
                } label: {
                    Label("Historial", systemImage: "clock.arrow.circlepath")
                }
            }

            if let latestPlan = plans.first {
                Section("Última tabla") {
                    NavigationLink {
                        WeeklyPlanDetailView(plan: latestPlan)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(latestPlan.title)
                                .font(.headline)

                            HStack {
                                Label(latestPlan.mainGoal.rawValue, systemImage: "target")
                                Label("\(latestPlan.estimatedSessionDurationMinutes) min", systemImage: "timer")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Inicio")
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
    .modelContainer(for: [Exercise.self, WeeklyPlan.self, WeeklyPlanDay.self, PlannedExercise.self], inMemory: true)
}

private struct DashboardMetric: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(.tint)

            Text(value)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
