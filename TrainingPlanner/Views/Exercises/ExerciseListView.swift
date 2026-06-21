import SwiftData
import SwiftUI
import UIKit

struct ExerciseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.name) private var exercises: [Exercise]

    @State private var searchText = ""
    @State private var selectedCategory = ""
    @State private var selectedMuscleGroup = ""
    @State private var selectedLevel = ""
    @State private var selectedGoal = ""
    @State private var isShowingEditor = false
    @State private var exercisePendingDeletion: Exercise?

    private var filteredExercises: [Exercise] {
        exercises.filter { exercise in
            let matchesSearch = searchText.isEmpty
                || exercise.name.localizedStandardContains(searchText)
                || exercise.category.localizedStandardContains(searchText)
                || exercise.muscleGroup.localizedStandardContains(searchText)
                || exercise.exerciseExplanation.localizedStandardContains(searchText)

            let matchesCategory = selectedCategory.isEmpty || exercise.category == selectedCategory
            let matchesMuscleGroup = selectedMuscleGroup.isEmpty || exercise.muscleGroup == selectedMuscleGroup
            let matchesLevel = selectedLevel.isEmpty || exercise.levelRawValue == selectedLevel
            let matchesGoal = selectedGoal.isEmpty || exercise.goalRawValue == selectedGoal

            return matchesSearch && matchesCategory && matchesMuscleGroup && matchesLevel && matchesGoal
        }
    }

    private var categories: [String] {
        uniqueValues(for: \.category)
    }

    private var muscleGroups: [String] {
        uniqueValues(for: \.muscleGroup)
    }

    var body: some View {
        Group {
            if exercises.isEmpty {
                ContentUnavailableView {
                    Label("Sin ejercicios", systemImage: "figure.strengthtraining.traditional")
                } description: {
                    Text("Crea tu primer ejercicio para empezar a construir la base de datos.")
                } actions: {
                    Button {
                        isShowingEditor = true
                    } label: {
                        Label("Nuevo ejercicio", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                List {
                    Section {
                        filterBar
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                    if filteredExercises.isEmpty {
                        ContentUnavailableView(
                            "Sin resultados",
                            systemImage: "line.3.horizontal.decrease.circle",
                            description: Text("Prueba con otra búsqueda o elimina algún filtro.")
                        )
                    } else {
                        ForEach(filteredExercises) { exercise in
                            NavigationLink {
                                ExerciseDetailView(exercise: exercise)
                            } label: {
                                ExerciseCardView(exercise: exercise)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    exercisePendingDeletion = exercise
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Ejercicios")
        .searchable(text: $searchText, prompt: "Buscar ejercicios")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingEditor = true
                } label: {
                    Label("Nuevo ejercicio", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingEditor) {
            NavigationStack {
                ExerciseEditorView()
            }
        }
        .alert("Eliminar ejercicio", isPresented: deleteAlertBinding) {
            Button("Cancelar", role: .cancel) {
                exercisePendingDeletion = nil
            }
            Button("Eliminar", role: .destructive) {
                deletePendingExercise()
            }
        } message: {
            Text("Esta acción eliminará el ejercicio de la base de datos local.")
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ExerciseFilterMenu(title: "Categoría", selection: $selectedCategory, options: categories)
                ExerciseFilterMenu(title: "Zona", selection: $selectedMuscleGroup, options: muscleGroups)
                ExerciseFilterMenu(title: "Nivel", selection: $selectedLevel, options: ExerciseLevel.allCases.map(\.rawValue))
                ExerciseFilterMenu(title: "Objetivo", selection: $selectedGoal, options: ExerciseGoal.allCases.map(\.rawValue))

                if hasActiveFilters {
                    Button {
                        clearFilters()
                    } label: {
                        Label("Limpiar", systemImage: "xmark.circle")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var hasActiveFilters: Bool {
        !selectedCategory.isEmpty
            || !selectedMuscleGroup.isEmpty
            || !selectedLevel.isEmpty
            || !selectedGoal.isEmpty
    }

    private var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { exercisePendingDeletion != nil },
            set: { isPresented in
                if !isPresented {
                    exercisePendingDeletion = nil
                }
            }
        )
    }

    private func uniqueValues(for keyPath: KeyPath<Exercise, String>) -> [String] {
        Array(Set(exercises.map { $0[keyPath: keyPath] }.filter { !$0.isEmpty })).sorted()
    }

    private func clearFilters() {
        selectedCategory = ""
        selectedMuscleGroup = ""
        selectedLevel = ""
        selectedGoal = ""
    }

    private func deletePendingExercise() {
        guard let exercise = exercisePendingDeletion else { return }
        modelContext.delete(exercise)
        try? modelContext.save()
        exercisePendingDeletion = nil
    }
}

#Preview {
    NavigationStack {
        ExerciseListView()
    }
    .modelContainer(for: Exercise.self, inMemory: true)
}

private struct ExerciseCardView: View {
    let exercise: Exercise

    var body: some View {
        HStack(spacing: 14) {
            thumbnail

            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(exercise.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    Text("\(exercise.category) · \(exercise.muscleGroup)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: 6) {
                    ExerciseTag(text: exercise.level.rawValue, systemImage: "chart.bar")
                    ExerciseTag(text: exercise.goal.rawValue, systemImage: "target")
                }

                Text("\(exercise.sets) series · \(exercise.repetitions) reps · descanso \(exercise.restTime)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let imageData = exercise.imageData, let image = UIImage(data: imageData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 62, height: 62)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.tint.opacity(0.12))
                .frame(width: 62, height: 62)
                .overlay {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.title2)
                        .foregroundStyle(.tint)
                }
        }
    }
}

private struct ExerciseTag: View {
    let text: String
    let systemImage: String

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.caption2.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.thinMaterial, in: Capsule())
            .lineLimit(1)
    }
}

private struct ExerciseFilterMenu: View {
    let title: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        Menu {
            Picker(title, selection: $selection) {
                Text("Todos").tag("")
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(selection.isEmpty ? title : selection)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.caption2.weight(.semibold))
            }
        }
        .buttonStyle(.bordered)
        .disabled(options.isEmpty)
    }
}
