import PhotosUI
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct ExerciseEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let exercise: Exercise?

    @State private var name: String
    @State private var category: String
    @State private var muscleGroup: String
    @State private var level: ExerciseLevel
    @State private var requiredEquipment: String
    @State private var exerciseExplanation: String
    @State private var stepByStepInstructions: String
    @State private var videoSource: VideoSourceType
    @State private var externalVideoURL: String
    @State private var localVideoBookmark: Data?
    @State private var localVideoFilename: String?
    @State private var imageData: Data?
    @State private var sets: Int
    @State private var repetitions: Int
    @State private var targetTime: String
    @State private var restTime: String
    @State private var recommendedFrequency: String
    @State private var goal: ExerciseGoal
    @State private var notes: String
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isShowingVideoImporter = false

    init(exercise: Exercise? = nil) {
        self.exercise = exercise
        _name = State(initialValue: exercise?.name ?? "")
        _category = State(initialValue: exercise?.category ?? "")
        _muscleGroup = State(initialValue: exercise?.muscleGroup ?? "")
        _level = State(initialValue: exercise?.level ?? .basic)
        _requiredEquipment = State(initialValue: exercise?.requiredEquipment ?? "")
        _exerciseExplanation = State(initialValue: exercise?.exerciseExplanation ?? "")
        _stepByStepInstructions = State(initialValue: exercise?.stepByStepInstructions ?? "")
        _videoSource = State(initialValue: exercise?.videoSource ?? .none)
        _externalVideoURL = State(initialValue: exercise?.externalVideoURL ?? "")
        _localVideoBookmark = State(initialValue: exercise?.localVideoBookmark)
        _localVideoFilename = State(initialValue: exercise?.localVideoFilename)
        _imageData = State(initialValue: exercise?.imageData)
        _sets = State(initialValue: exercise?.sets ?? 3)
        _repetitions = State(initialValue: exercise?.repetitions ?? 10)
        _targetTime = State(initialValue: exercise?.targetTime ?? "")
        _restTime = State(initialValue: exercise?.restTime ?? "60 s")
        _recommendedFrequency = State(initialValue: exercise?.recommendedFrequency ?? "")
        _goal = State(initialValue: exercise?.goal ?? .strength)
        _notes = State(initialValue: exercise?.notes ?? "")
    }

    var body: some View {
        Form {
            Section("Datos básicos") {
                TextField("Nombre del ejercicio", text: $name)
                TextField("Categoría", text: $category)
                TextField("Grupo muscular o zona", text: $muscleGroup)

                Picker("Nivel", selection: $level) {
                    ForEach(ExerciseLevel.allCases) { level in
                        Text(level.rawValue).tag(level)
                    }
                }

                Picker("Objetivo", selection: $goal) {
                    ForEach(ExerciseGoal.allCases) { goal in
                        Text(goal.rawValue).tag(goal)
                    }
                }
            }

            Section("Trabajo") {
                Stepper(value: $sets, in: 1...20) {
                    LabeledContent("Series", value: "\(sets)")
                }

                Stepper(value: $repetitions, in: 0...200) {
                    LabeledContent("Repeticiones", value: "\(repetitions)")
                }

                TextField("Tiempo objetivo", text: $targetTime)
                TextField("Tiempo de descanso", text: $restTime)
                TextField("Frecuencia recomendada", text: $recommendedFrequency)
            }

            Section("Contenido") {
                TextField("Material necesario", text: $requiredEquipment, axis: .vertical)
                    .lineLimit(1...3)

                TextField("Explicación del ejercicio", text: $exerciseExplanation, axis: .vertical)
                    .lineLimit(3...8)

                TextField("Instrucciones paso a paso", text: $stepByStepInstructions, axis: .vertical)
                    .lineLimit(3...10)

                TextField("Observaciones", text: $notes, axis: .vertical)
                    .lineLimit(2...6)
            }

            Section("Vídeo") {
                Picker("Origen", selection: $videoSource) {
                    ForEach(VideoSourceType.allCases) { source in
                        Text(source.rawValue).tag(source)
                    }
                }

                switch videoSource {
                case .externalURL:
                    TextField("URL del vídeo", text: $externalVideoURL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                case .localFile:
                    Button {
                        isShowingVideoImporter = true
                    } label: {
                        Label(localVideoFilename ?? "Seleccionar archivo de vídeo", systemImage: "video.badge.plus")
                    }
                case .none:
                    Text("No se asociará vídeo a este ejercicio.")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Imagen opcional") {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label(imageData == nil ? "Seleccionar imagen" : "Cambiar imagen", systemImage: "photo")
                }

                if imageData != nil {
                    Button(role: .destructive) {
                        imageData = nil
                        selectedPhoto = nil
                    } label: {
                        Label("Eliminar imagen", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle(exercise == nil ? "Nuevo ejercicio" : "Editar ejercicio")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Guardar") {
                    saveExercise()
                }
                .disabled(!canSave)
            }
        }
        .fileImporter(isPresented: $isShowingVideoImporter, allowedContentTypes: [.movie]) { result in
            handleVideoImport(result)
        }
        .onChange(of: selectedPhoto) { _, newValue in
            loadImage(from: newValue)
        }
    }

    private var canSave: Bool {
        !name.trimmed.isEmpty
            && !category.trimmed.isEmpty
            && !muscleGroup.trimmed.isEmpty
            && !exerciseExplanation.trimmed.isEmpty
    }

    private func saveExercise() {
        let trimmedExternalVideoURL = externalVideoURL.trimmed

        if let exercise {
            exercise.name = name.trimmed
            exercise.category = category.trimmed
            exercise.muscleGroup = muscleGroup.trimmed
            exercise.level = level
            exercise.requiredEquipment = requiredEquipment.trimmed
            exercise.exerciseExplanation = exerciseExplanation.trimmed
            exercise.stepByStepInstructions = stepByStepInstructions.trimmed
            exercise.videoSource = videoSource
            exercise.externalVideoURL = videoSource == .externalURL && !trimmedExternalVideoURL.isEmpty ? trimmedExternalVideoURL : nil
            exercise.localVideoBookmark = videoSource == .localFile ? localVideoBookmark : nil
            exercise.localVideoFilename = videoSource == .localFile ? localVideoFilename : nil
            exercise.imageData = imageData
            exercise.sets = sets
            exercise.repetitions = repetitions
            exercise.targetTime = targetTime.trimmed
            exercise.restTime = restTime.trimmed
            exercise.recommendedFrequency = recommendedFrequency.trimmed
            exercise.goal = goal
            exercise.notes = notes.trimmed
            exercise.updatedAt = .now
        } else {
            let newExercise = Exercise(
                name: name.trimmed,
                category: category.trimmed,
                muscleGroup: muscleGroup.trimmed,
                level: level,
                requiredEquipment: requiredEquipment.trimmed,
                exerciseExplanation: exerciseExplanation.trimmed,
                stepByStepInstructions: stepByStepInstructions.trimmed,
                videoSource: videoSource,
                externalVideoURL: videoSource == .externalURL && !trimmedExternalVideoURL.isEmpty ? trimmedExternalVideoURL : nil,
                localVideoBookmark: videoSource == .localFile ? localVideoBookmark : nil,
                localVideoFilename: videoSource == .localFile ? localVideoFilename : nil,
                imageData: imageData,
                sets: sets,
                repetitions: repetitions,
                targetTime: targetTime.trimmed,
                restTime: restTime.trimmed,
                recommendedFrequency: recommendedFrequency.trimmed,
                goal: goal,
                notes: notes.trimmed
            )
            modelContext.insert(newExercise)
        }

        try? modelContext.save()
        dismiss()
    }

    private func handleVideoImport(_ result: Result<URL, Error>) {
        guard case let .success(url) = result else { return }
        localVideoFilename = url.lastPathComponent
        localVideoBookmark = try? url.bookmarkData(options: [.withSecurityScope], includingResourceValuesForKeys: nil, relativeTo: nil)
    }

    private func loadImage(from item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            imageData = try? await item.loadTransferable(type: Data.self)
        }
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
