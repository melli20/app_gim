import SwiftData
import SwiftUI

struct PlanHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WeeklyPlan.startDate, order: .reverse) private var plans: [WeeklyPlan]

    @State private var planPendingDeletion: WeeklyPlan?
    @State private var duplicatedPlan: WeeklyPlan?

    var body: some View {
        Group {
            if plans.isEmpty {
                ContentUnavailableView(
                    "Sin historial",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Las tablas semanales creadas aparecerán aquí.")
                )
            } else {
                List {
                    Section("Resumen") {
                        HistorySummaryView(plans: plans)
                    }

                    Section("Tablas semanales") {
                        ForEach(plans) { plan in
                            NavigationLink {
                                WeeklyPlanDetailView(plan: plan)
                            } label: {
                                HistoryPlanRowView(plan: plan)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    planPendingDeletion = plan
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }

                                Button {
                                    duplicatedPlan = duplicate(plan)
                                } label: {
                                    Label("Duplicar", systemImage: "doc.on.doc")
                                }
                                .tint(.blue)
                            }
                            .contextMenu {
                                Button {
                                    duplicatedPlan = duplicate(plan)
                                } label: {
                                    Label("Duplicar semana", systemImage: "doc.on.doc")
                                }

                                Button(role: .destructive) {
                                    planPendingDeletion = plan
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Historial")
        .alert("Eliminar tabla", isPresented: deleteAlertBinding) {
            Button("Cancelar", role: .cancel) {
                planPendingDeletion = nil
            }
            Button("Eliminar", role: .destructive) {
                deletePendingPlan()
            }
        } message: {
            Text("Esta tabla y sus ejercicios planificados se eliminarán del historial.")
        }
        .sheet(item: $duplicatedPlan) { plan in
            NavigationStack {
                DuplicatedPlanResultView(plan: plan)
            }
        }
    }

    private var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { planPendingDeletion != nil },
            set: { isPresented in
                if !isPresented {
                    planPendingDeletion = nil
                }
            }
        )
    }

    private func deletePendingPlan() {
        guard let planPendingDeletion else { return }
        modelContext.delete(planPendingDeletion)
        try? modelContext.save()
        self.planPendingDeletion = nil
    }

    private func duplicate(_ plan: WeeklyPlan) -> WeeklyPlan {
        let duplicatedDays = Weekday.allCases.map { weekday in
            WeeklyPlanDay(weekday: weekday)
        }

        let copiedPlan = WeeklyPlan(
            title: "\(plan.title) copia",
            mainGoal: plan.mainGoal,
            level: plan.level,
            startDate: Date(),
            estimatedSessionDurationMinutes: plan.estimatedSessionDurationMinutes,
            notes: duplicatedNotes(from: plan),
            days: duplicatedDays
        )

        for originalDay in plan.days {
            guard let targetDay = duplicatedDays.first(where: { $0.weekday == originalDay.weekday }) else {
                continue
            }

            for originalPlannedExercise in originalDay.plannedExercises.sorted(by: { $0.sortOrder < $1.sortOrder }) {
                let copy = PlannedExercise(
                    exercise: originalPlannedExercise.exercise,
                    customSets: originalPlannedExercise.customSets,
                    customRepetitions: originalPlannedExercise.customRepetitions,
                    customTargetTime: originalPlannedExercise.customTargetTime,
                    customRestTime: originalPlannedExercise.customRestTime,
                    specificNotes: originalPlannedExercise.specificNotes,
                    isCompleted: false,
                    sortOrder: originalPlannedExercise.sortOrder
                )

                modelContext.insert(copy)
                targetDay.plannedExercises.append(copy)
            }
        }

        modelContext.insert(copiedPlan)
        try? modelContext.save()
        return copiedPlan
    }

    private func duplicatedNotes(from plan: WeeklyPlan) -> String {
        let suffix = "Duplicada desde \(plan.title)."
        guard !plan.notes.trimmed.isEmpty else {
            return suffix
        }

        return "\(plan.notes) \(suffix)"
    }
}

#Preview {
    NavigationStack {
        PlanHistoryView()
    }
    .modelContainer(for: [Exercise.self, WeeklyPlan.self, WeeklyPlanDay.self, PlannedExercise.self], inMemory: true)
}

private struct HistorySummaryView: View {
    let plans: [WeeklyPlan]

    private var totalExercises: Int {
        plans.reduce(0) { result, plan in
            result + plan.days.reduce(0) { $0 + $1.plannedExercises.count }
        }
    }

    private var completedExercises: Int {
        plans.reduce(0) { result, plan in
            result + plan.days.reduce(0) { dayResult, day in
                dayResult + day.plannedExercises.filter(\.isCompleted).count
            }
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            SummaryMetric(title: "Tablas", value: "\(plans.count)", systemImage: "calendar")
            SummaryMetric(title: "Ejercicios", value: "\(totalExercises)", systemImage: "list.bullet.clipboard")
            SummaryMetric(title: "Completados", value: "\(completedExercises)", systemImage: "checkmark.circle")
        }
        .padding(.vertical, 4)
    }
}

private struct SummaryMetric: View {
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

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct HistoryPlanRowView: View {
    let plan: WeeklyPlan

    private var plannedExerciseCount: Int {
        plan.days.reduce(0) { $0 + $1.plannedExercises.count }
    }

    private var completedExerciseCount: Int {
        plan.days.reduce(0) { result, day in
            result + day.plannedExercises.filter(\.isCompleted).count
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(plan.title)
                    .font(.headline)
                    .lineLimit(2)

                Spacer()

                Text("\(completedExerciseCount)/\(plannedExerciseCount)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                Label(plan.mainGoal.rawValue, systemImage: "target")
                Label(plan.level.rawValue, systemImage: "chart.bar")
                Label("\(plan.estimatedSessionDurationMinutes) min", systemImage: "timer")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            HStack {
                Text(plan.startDate, style: .date)
                Spacer()
                Text(plan.createdAt, style: .date)
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}

private struct DuplicatedPlanResultView: View {
    @Environment(\.dismiss) private var dismiss
    let plan: WeeklyPlan

    var body: some View {
        List {
            Section {
                ContentUnavailableView(
                    "Semana duplicada",
                    systemImage: "doc.on.doc",
                    description: Text("Se ha creado una nueva tabla con los ejercicios sin completar.")
                )
            }

            Section {
                NavigationLink {
                    WeeklyPlanDetailView(plan: plan)
                } label: {
                    Label("Abrir tabla duplicada", systemImage: "calendar")
                }

                Button("Cerrar") {
                    dismiss()
                }
            }
        }
        .navigationTitle(plan.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
