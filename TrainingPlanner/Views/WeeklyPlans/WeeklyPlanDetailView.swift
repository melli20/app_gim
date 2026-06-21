import SwiftData
import SwiftUI

struct WeeklyPlanDetailView: View {
    @Environment(\.modelContext) private var modelContext

    let plan: WeeklyPlan

    @State private var dayAddingExercise: WeeklyPlanDay?
    @State private var plannedExerciseBeingEdited: PlannedExercise?

    private var sortedDays: [WeeklyPlanDay] {
        plan.days.sorted { $0.weekdayRawValue < $1.weekdayRawValue }
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Label(plan.mainGoal.rawValue, systemImage: "target")
                        Spacer()
                        Label(plan.level.rawValue, systemImage: "chart.bar")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    HStack {
                        Label("\(plan.estimatedSessionDurationMinutes) min por sesión", systemImage: "timer")
                        Spacer()
                        Text(plan.startDate, style: .date)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    if !plan.notes.trimmed.isEmpty {
                        Text(plan.notes)
                            .font(.body)
                    }
                }
                .padding(.vertical, 4)
            }

            ForEach(sortedDays) { day in
                Section {
                    if day.plannedExercises.isEmpty {
                        Text("Sin ejercicios")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(day.plannedExercises.sorted { $0.sortOrder < $1.sortOrder }) { plannedExercise in
                            PlannedExerciseRowView(plannedExercise: plannedExercise) {
                                plannedExercise.isCompleted.toggle()
                                try? modelContext.save()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                plannedExerciseBeingEdited = plannedExercise
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    modelContext.delete(plannedExercise)
                                    try? modelContext.save()
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                        }
                    }

                    Button {
                        dayAddingExercise = day
                    } label: {
                        Label("Añadir ejercicio", systemImage: "plus")
                    }
                } header: {
                    Text(day.weekday.title)
                }
            }
        }
        .navigationTitle(plan.title)
        .sheet(item: $dayAddingExercise) { day in
            NavigationStack {
                ExercisePickerForDayView(day: day)
            }
        }
        .sheet(item: $plannedExerciseBeingEdited) { plannedExercise in
            NavigationStack {
                PlannedExerciseEditorView(plannedExercise: plannedExercise)
            }
        }
    }
}

private struct PlannedExerciseRowView: View {
    let plannedExercise: PlannedExercise
    let toggleCompleted: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: toggleCompleted) {
                Image(systemName: plannedExercise.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(plannedExercise.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 7) {
                Text(plannedExercise.exercise?.name ?? "Ejercicio eliminado")
                    .font(.headline)
                    .strikethrough(plannedExercise.isCompleted)

                HStack(spacing: 10) {
                    Text("\(plannedExercise.customSets) series")
                    Text("\(plannedExercise.customRepetitions) reps")
                    Text(plannedExercise.customTargetTime.trimmed.isEmpty ? "Sin tiempo" : plannedExercise.customTargetTime)
                    Text(plannedExercise.customRestTime.trimmed.isEmpty ? "Sin descanso" : plannedExercise.customRestTime)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

                if !plannedExercise.specificNotes.trimmed.isEmpty {
                    Text(plannedExercise.specificNotes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

private struct ExercisePickerForDayView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.name) private var exercises: [Exercise]

    let day: WeeklyPlanDay

    @State private var searchText = ""

    private var filteredExercises: [Exercise] {
        exercises.filter { exercise in
            searchText.isEmpty
                || exercise.name.localizedStandardContains(searchText)
                || exercise.category.localizedStandardContains(searchText)
                || exercise.muscleGroup.localizedStandardContains(searchText)
        }
    }

    var body: some View {
        List {
            if exercises.isEmpty {
                ContentUnavailableView(
                    "No hay ejercicios",
                    systemImage: "figure.strengthtraining.traditional",
                    description: Text("Crea ejercicios en la base de datos antes de añadirlos a una tabla.")
                )
            } else {
                ForEach(filteredExercises) { exercise in
                    Button {
                        add(exercise)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(exercise.name)
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Text("\(exercise.category) · \(exercise.muscleGroup)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text("\(exercise.sets) series · \(exercise.repetitions) reps · \(exercise.restTime)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle(day.weekday.title)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Buscar ejercicio")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") {
                    dismiss()
                }
            }
        }
    }

    private func add(_ exercise: Exercise) {
        let nextSortOrder = (day.plannedExercises.map(\.sortOrder).max() ?? -1) + 1
        let plannedExercise = PlannedExercise(
            exercise: exercise,
            customSets: exercise.sets,
            customRepetitions: exercise.repetitions,
            customTargetTime: exercise.targetTime,
            customRestTime: exercise.restTime,
            sortOrder: nextSortOrder
        )

        modelContext.insert(plannedExercise)
        day.plannedExercises.append(plannedExercise)
        try? modelContext.save()
        dismiss()
    }
}

private struct PlannedExerciseEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var plannedExercise: PlannedExercise

    var body: some View {
        Form {
            Section("Ejercicio") {
                Text(plannedExercise.exercise?.name ?? "Ejercicio eliminado")
                    .font(.headline)

                Toggle("Completado", isOn: $plannedExercise.isCompleted)
            }

            Section("Trabajo del día") {
                Stepper(value: $plannedExercise.customSets, in: 1...20) {
                    LabeledContent("Series", value: "\(plannedExercise.customSets)")
                }

                Stepper(value: $plannedExercise.customRepetitions, in: 0...200) {
                    LabeledContent("Repeticiones", value: "\(plannedExercise.customRepetitions)")
                }

                TextField("Tiempo objetivo", text: $plannedExercise.customTargetTime)
                TextField("Descanso", text: $plannedExercise.customRestTime)
            }

            Section("Notas") {
                TextField("Notas específicas", text: $plannedExercise.specificNotes, axis: .vertical)
                    .lineLimit(2...6)
            }
        }
        .navigationTitle("Editar ejercicio")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Guardar") {
                    try? modelContext.save()
                    dismiss()
                }
            }
        }
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
