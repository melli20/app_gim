import SwiftData
import SwiftUI

struct WeeklyPlanListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WeeklyPlan.startDate, order: .reverse) private var plans: [WeeklyPlan]

    @State private var isShowingPlanEditor = false
    @State private var planPendingDeletion: WeeklyPlan?

    var body: some View {
        Group {
            if plans.isEmpty {
                ContentUnavailableView {
                    Label("Sin tablas semanales", systemImage: "calendar")
                } description: {
                    Text("Crea una tabla manual para organizar ejercicios por días.")
                } actions: {
                    Button {
                        isShowingPlanEditor = true
                    } label: {
                        Label("Nueva tabla", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                List {
                    Section {
                        Button {
                            isShowingPlanEditor = true
                        } label: {
                            Label("Nueva tabla manual", systemImage: "plus")
                        }

                        NavigationLink {
                            WeeklyPlanGeneratorView()
                        } label: {
                            Label("Crear tabla automáticamente", systemImage: "wand.and.stars")
                        }
                    }

                    Section("Tablas guardadas") {
                        ForEach(plans) { plan in
                            NavigationLink {
                                WeeklyPlanDetailView(plan: plan)
                            } label: {
                                WeeklyPlanRowView(plan: plan)
                            }
                            .swipeActions {
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
        .navigationTitle("Semanas")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingPlanEditor = true
                } label: {
                    Label("Nueva tabla", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingPlanEditor) {
            NavigationStack {
                WeeklyPlanEditorView()
            }
        }
        .alert("Eliminar tabla semanal", isPresented: deleteAlertBinding) {
            Button("Cancelar", role: .cancel) {
                planPendingDeletion = nil
            }
            Button("Eliminar", role: .destructive) {
                deletePendingPlan()
            }
        } message: {
            Text("Se eliminarán también todos los días y ejercicios planificados de esta tabla.")
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
}

#Preview {
    NavigationStack {
        WeeklyPlanListView()
    }
    .modelContainer(for: [Exercise.self, WeeklyPlan.self, WeeklyPlanDay.self, PlannedExercise.self], inMemory: true)
}

private struct WeeklyPlanRowView: View {
    let plan: WeeklyPlan

    private var plannedExerciseCount: Int {
        plan.days.reduce(0) { $0 + $1.plannedExercises.count }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(plan.title)
                    .font(.headline)
                    .lineLimit(2)

                Spacer()

                Text("\(plannedExerciseCount)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.tint, in: Capsule())
            }

            HStack(spacing: 10) {
                Label(plan.mainGoal.rawValue, systemImage: "target")
                Label(plan.level.rawValue, systemImage: "chart.bar")
                Label("\(plan.estimatedSessionDurationMinutes) min", systemImage: "timer")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Text(plan.startDate, style: .date)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}

private struct WeeklyPlanEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var mainGoal: ExerciseGoal = .strength
    @State private var level: ExerciseLevel = .basic
    @State private var startDate = Date()
    @State private var estimatedSessionDurationMinutes = 45
    @State private var notes = ""

    var body: some View {
        Form {
            Section("Tabla") {
                TextField("Nombre", text: $title)
                DatePicker("Inicio", selection: $startDate, displayedComponents: .date)

                Picker("Objetivo", selection: $mainGoal) {
                    ForEach(ExerciseGoal.allCases) { goal in
                        Text(goal.rawValue).tag(goal)
                    }
                }

                Picker("Nivel", selection: $level) {
                    ForEach(ExerciseLevel.allCases) { level in
                        Text(level.rawValue).tag(level)
                    }
                }

                Stepper(value: $estimatedSessionDurationMinutes, in: 10...180, step: 5) {
                    LabeledContent("Duración sesión", value: "\(estimatedSessionDurationMinutes) min")
                }
            }

            Section("Notas") {
                TextField("Notas generales", text: $notes, axis: .vertical)
                    .lineLimit(2...6)
            }
        }
        .navigationTitle("Nueva tabla")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Guardar") {
                    savePlan()
                }
                .disabled(title.trimmed.isEmpty)
            }
        }
    }

    private func savePlan() {
        let plan = WeeklyPlan(
            title: title.trimmed,
            mainGoal: mainGoal,
            level: level,
            startDate: startDate,
            estimatedSessionDurationMinutes: estimatedSessionDurationMinutes,
            notes: notes.trimmed
        )

        modelContext.insert(plan)
        try? modelContext.save()
        dismiss()
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
