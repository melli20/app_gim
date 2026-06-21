import SwiftUI
import UIKit

struct ExerciseDetailView: View {
    let exercise: Exercise
    @State private var isShowingEditor = false

    var body: some View {
        List {
            if let imageData = exercise.imageData, let image = UIImage(data: imageData) {
                Section {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            }

            Section("Resumen") {
                Text(exercise.exerciseExplanation)
                LabeledContent("Nivel", value: exercise.level.rawValue)
                LabeledContent("Objetivo", value: exercise.goal.rawValue)
                LabeledContent("Categoría", value: exercise.category)
                LabeledContent("Zona", value: exercise.muscleGroup)
            }

            Section("Trabajo") {
                LabeledContent("Series", value: "\(exercise.sets)")
                LabeledContent("Repeticiones", value: "\(exercise.repetitions)")
                LabeledContent("Tiempo objetivo", value: exercise.targetTime.isEmpty ? "No definido" : exercise.targetTime)
                LabeledContent("Descanso", value: exercise.restTime.isEmpty ? "No definido" : exercise.restTime)
                LabeledContent("Frecuencia", value: exercise.recommendedFrequency.isEmpty ? "No definida" : exercise.recommendedFrequency)
            }

            if !exercise.requiredEquipment.isEmpty || !exercise.stepByStepInstructions.isEmpty || !exercise.notes.isEmpty {
                Section("Contenido") {
                    if !exercise.requiredEquipment.isEmpty {
                        LabeledContent("Material", value: exercise.requiredEquipment)
                    }

                    if !exercise.stepByStepInstructions.isEmpty {
                        Text(exercise.stepByStepInstructions)
                    }

                    if !exercise.notes.isEmpty {
                        Text(exercise.notes)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Vídeo") {
                LabeledContent("Origen", value: exercise.videoSource.rawValue)

                if let externalVideoURL = exercise.externalVideoURL,
                   let url = URL(string: externalVideoURL),
                   !externalVideoURL.isEmpty {
                    Link(externalVideoURL, destination: url)
                }

                if let localVideoFilename = exercise.localVideoFilename, !localVideoFilename.isEmpty {
                    LabeledContent("Archivo", value: localVideoFilename)
                }
            }
        }
        .navigationTitle(exercise.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingEditor = true
                } label: {
                    Label("Editar", systemImage: "square.and.pencil")
                }
            }
        }
        .sheet(isPresented: $isShowingEditor) {
            NavigationStack {
                ExerciseEditorView(exercise: exercise)
            }
        }
    }
}
