import SwiftData
import SwiftUI

struct WeeklyPlanGeneratorView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.name) private var exercises: [Exercise]

    @State private var title = ""
    @State private var mainGoal: ExerciseGoal = .strength
    @State private var level: ExerciseLevel = .basic
    @State private var trainingDays = 3
    @State private var sessionDuration = 45
    @State private var weeklyFrequency = 3
    @State private var startDate = Date()
    @State private var selectedCategories: Set<String> = []
    @State private var selectedMuscleGroups: Set<String> = []
    @State private var generatedPlan: WeeklyPlan?
    @State private var generationMessage: String?

    private var availableCategories: [String] {
        Array(Set(exercises.map(\.category).filter { !$0.trimmed.isEmpty })).sorted()
    }

    private var availableMuscleGroups: [String] {
        Array(Set(exercises.map(\.muscleGroup).filter { !$0.trimmed.isEmpty })).sorted()
    }

    var body: some View {
        Form {
            if exercises.isEmpty {
                Section {
                    ContentUnavailableView(
                        "Sin ejercicios",
                        systemImage: "figure.strengthtraining.traditional",
                        description: Text("Crea ejercicios en la base de datos antes de generar una tabla automática.")
                    )
                }
            }

            Section("Semana") {
                TextField("Nombre de la tabla", text: $title)
                DatePicker("Fecha de inicio", selection: $startDate, displayedComponents: .date)

                Picker("Objetivo principal", selection: $mainGoal) {
                    ForEach(ExerciseGoal.allCases) { goal in
                        Text(goal.rawValue).tag(goal)
                    }
                }

                Picker("Nivel", selection: $level) {
                    ForEach(ExerciseLevel.allCases) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
            }

            Section("Disponibilidad") {
                Stepper(value: $trainingDays, in: 1...7) {
                    LabeledContent("Días de entrenamiento", value: "\(trainingDays)")
                }

                Stepper(value: $sessionDuration, in: 15...120, step: 5) {
                    LabeledContent("Duración por sesión", value: "\(sessionDuration) min")
                }

                Stepper(value: $weeklyFrequency, in: 1...7) {
                    LabeledContent("Frecuencia semanal", value: "\(weeklyFrequency)")
                }
            }

            if !availableCategories.isEmpty {
                Section("Categorías prioritarias") {
                    ForEach(availableCategories, id: \.self) { category in
                        Toggle(category, isOn: binding(for: category, selection: $selectedCategories))
                    }
                }
            }

            if !availableMuscleGroups.isEmpty {
                Section("Zonas prioritarias") {
                    ForEach(availableMuscleGroups, id: \.self) { muscleGroup in
                        Toggle(muscleGroup, isOn: binding(for: muscleGroup, selection: $selectedMuscleGroups))
                    }
                }
            }

            Section {
                Button {
                    generatePlan()
                } label: {
                    Label("Generar tabla semanal", systemImage: "wand.and.stars")
                        .frame(maxWidth: .infinity)
                }
                .disabled(exercises.isEmpty)
            }

            if let generationMessage {
                Section {
                    Text(generationMessage)
                        .foregroundStyle(.secondary)
                }
            }

            if let generatedPlan {
                Section("Resultado") {
                    NavigationLink {
                        WeeklyPlanDetailView(plan: generatedPlan)
                    } label: {
                        Label("Abrir tabla generada", systemImage: "calendar")
                    }
                }
            }
        }
        .navigationTitle("Generador")
    }

    private func binding(for value: String, selection: Binding<Set<String>>) -> Binding<Bool> {
        Binding(
            get: { selection.wrappedValue.contains(value) },
            set: { isSelected in
                if isSelected {
                    selection.wrappedValue.insert(value)
                } else {
                    selection.wrappedValue.remove(value)
                }
            }
        )
    }

    private func generatePlan() {
        let candidates = rankedExercises()

        guard !candidates.isEmpty else {
            generationMessage = "No hay ejercicios compatibles con los criterios seleccionados."
            generatedPlan = nil
            return
        }

        let activeDays = selectedWeekdays(count: min(trainingDays, weeklyFrequency))
        let exercisesPerDay = max(2, min(6, sessionDuration / 15))
        let finalTitle = title.trimmed.isEmpty ? "Semana \(mainGoal.rawValue)" : title.trimmed
        let plan = WeeklyPlan(
            title: finalTitle,
            mainGoal: mainGoal,
            level: level,
            startDate: startDate,
            estimatedSessionDurationMinutes: sessionDuration,
            notes: generatorSummary(activeDays: activeDays)
        )

        for day in plan.days {
            guard activeDays.contains(day.weekday) else { continue }

            let selectedExercises = pickExercises(
                from: candidates,
                count: exercisesPerDay,
                avoidingMuscleGroup: previousMuscleGroup(before: day.weekday, in: plan)
            )

            for (index, exercise) in selectedExercises.enumerated() {
                let plannedExercise = PlannedExercise(
                    exercise: exercise,
                    customSets: exercise.sets,
                    customRepetitions: exercise.repetitions,
                    customTargetTime: exercise.targetTime,
                    customRestTime: exercise.restTime,
                    specificNotes: "Generado automáticamente para \(mainGoal.rawValue.lowercased()).",
                    sortOrder: index
                )

                modelContext.insert(plannedExercise)
                day.plannedExercises.append(plannedExercise)
            }
        }

        modelContext.insert(plan)
        try? modelContext.save()

        generatedPlan = plan
        generationMessage = "Tabla generada con \(activeDays.count) días y \(activeDays.count * exercisesPerDay) ejercicios planificados."
    }

    private func generatorSummary(activeDays: [Weekday]) -> String {
        var parts = [
            "Generada automáticamente.",
            "Objetivo: \(mainGoal.rawValue).",
            "Nivel: \(level.rawValue).",
            "Días: \(activeDays.map(\.title).joined(separator: ", ")).",
            "Duración: \(sessionDuration) min."
        ]

        if !selectedCategories.isEmpty {
            parts.append("Categorías prioritarias: \(selectedCategories.sorted().joined(separator: ", ")).")
        }

        if !selectedMuscleGroups.isEmpty {
            parts.append("Zonas prioritarias: \(selectedMuscleGroups.sorted().joined(separator: ", ")).")
        }

        return parts.joined(separator: " ")
    }

    private func rankedExercises() -> [Exercise] {
        exercises
            .filter { exercise in
                levelRank(exercise.level) <= levelRank(level) || exercise.level == .basic
            }
            .sorted { first, second in
                score(first) > score(second)
            }
    }

    private func score(_ exercise: Exercise) -> Int {
        var score = 0

        if exercise.goal == mainGoal { score += 8 }
        if exercise.level == level { score += 4 }
        if selectedCategories.contains(exercise.category) { score += 3 }
        if selectedMuscleGroups.contains(exercise.muscleGroup) { score += 3 }
        if exercise.level == .basic && level != .basic { score += 1 }

        return score
    }

    private func levelRank(_ level: ExerciseLevel) -> Int {
        switch level {
        case .basic: 1
        case .intermediate: 2
        case .advanced: 3
        }
    }

    private func selectedWeekdays(count: Int) -> [Weekday] {
        switch count {
        case 1:
            return [.monday]
        case 2:
            return [.monday, .thursday]
        case 3:
            return [.monday, .wednesday, .friday]
        case 4:
            return [.monday, .tuesday, .thursday, .friday]
        case 5:
            return [.monday, .tuesday, .wednesday, .thursday, .friday]
        case 6:
            return [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        default:
            return Weekday.allCases
        }
    }

    private func previousMuscleGroup(before weekday: Weekday, in plan: WeeklyPlan) -> String? {
        plan.days
            .filter { $0.weekdayRawValue < weekday.rawValue }
            .sorted { $0.weekdayRawValue > $1.weekdayRawValue }
            .first { !$0.plannedExercises.isEmpty }?
            .plannedExercises
            .first?
            .exercise?
            .muscleGroup
    }

    private func pickExercises(from candidates: [Exercise], count: Int, avoidingMuscleGroup: String?) -> [Exercise] {
        var selected: [Exercise] = []
        var pool = candidates

        while selected.count < count && !pool.isEmpty {
            let nextIndex = pool.firstIndex { exercise in
                guard let avoidingMuscleGroup else { return true }
                return exercise.muscleGroup != avoidingMuscleGroup || selected.count > 0
            } ?? pool.startIndex

            selected.append(pool.remove(at: nextIndex))
        }

        if selected.count < count {
            selected.append(contentsOf: candidates.prefix(count - selected.count))
        }

        return selected
    }
}

#Preview {
    NavigationStack {
        WeeklyPlanGeneratorView()
    }
    .modelContainer(for: [Exercise.self, WeeklyPlan.self, WeeklyPlanDay.self, PlannedExercise.self], inMemory: true)
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
