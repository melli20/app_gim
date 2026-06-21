import AVKit
import SwiftData
import SwiftUI
import UIKit

struct ExerciseDetailView: View {
    let exercise: Exercise

    @Environment(\.openURL) private var openURL
    @State private var isShowingEditor = false
    @State private var isShowingPlanPicker = false
    @State private var localVideoURL: URL?
    @State private var isAccessingLocalVideo = false

    private var externalVideoURL: URL? {
        guard let externalVideoURL = exercise.externalVideoURL?.trimmed,
              !externalVideoURL.isEmpty else {
            return nil
        }

        return URL(string: externalVideoURL)
    }

    var body: some View {
        List {
            Section {
                ExerciseMediaView(
                    exercise: exercise,
                    localVideoURL: localVideoURL,
                    externalVideoURL: externalVideoURL,
                    openExternalVideo: openExternalVideo
                )
            }
            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))

            Section("Resumen") {
                Text(exercise.exerciseExplanation)
                    .font(.body)
                    .foregroundStyle(.primary)

                DetailPillGrid(items: [
                    DetailPill(title: "Nivel", value: exercise.level.rawValue, systemImage: "chart.bar"),
                    DetailPill(title: "Objetivo", value: exercise.goal.rawValue, systemImage: "target"),
                    DetailPill(title: "Categoría", value: exercise.category, systemImage: "square.grid.2x2"),
                    DetailPill(title: "Zona", value: exercise.muscleGroup, systemImage: "figure.flexibility")
                ])
                .padding(.top, 4)
            }

            Section("Trabajo") {
                LabeledContent("Series", value: "\(exercise.sets)")
                LabeledContent("Repeticiones", value: "\(exercise.repetitions)")
                LabeledContent("Tiempo objetivo", value: visibleValue(exercise.targetTime, fallback: "No definido"))
                LabeledContent("Descanso", value: visibleValue(exercise.restTime, fallback: "No definido"))
                LabeledContent("Frecuencia", value: visibleValue(exercise.recommendedFrequency, fallback: "No definida"))
            }

            Section("Instrucciones") {
                if exercise.stepByStepInstructions.trimmed.isEmpty {
                    Text("Sin instrucciones paso a paso.")
                        .foregroundStyle(.secondary)
                } else {
                    Text(exercise.stepByStepInstructions)
                }
            }

            Section("Material y observaciones") {
                LabeledContent("Material", value: visibleValue(exercise.requiredEquipment, fallback: "No definido"))

                if exercise.notes.trimmed.isEmpty {
                    Text("Sin observaciones.")
                        .foregroundStyle(.secondary)
                } else {
                    Text(exercise.notes)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Acciones") {
                Button {
                    isShowingEditor = true
                } label: {
                    Label("Editar ejercicio", systemImage: "square.and.pencil")
                }

                Button {
                    isShowingPlanPicker = true
                } label: {
                    Label("Añadir a tabla semanal", systemImage: "calendar.badge.plus")
                }
            }
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.large)
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
        .sheet(isPresented: $isShowingPlanPicker) {
            NavigationStack {
                AddExerciseToWeeklyPlanView(exercise: exercise)
            }
        }
        .onAppear(perform: resolveLocalVideoIfNeeded)
        .onDisappear(perform: stopAccessingLocalVideo)
    }

    private func visibleValue(_ value: String, fallback: String) -> String {
        value.trimmed.isEmpty ? fallback : value
    }

    private func openExternalVideo() {
        guard let externalVideoURL else { return }
        openURL(externalVideoURL)
    }

    private func resolveLocalVideoIfNeeded() {
        guard exercise.videoSource == .localFile,
              let bookmarkData = exercise.localVideoBookmark,
              localVideoURL == nil else {
            return
        }

        var isStale = false
        guard let url = try? URL(
            resolvingBookmarkData: bookmarkData,
            options: [],
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        ) else {
            return
        }

        localVideoURL = url
    }

    private func stopAccessingLocalVideo() {
        guard isAccessingLocalVideo else { return }
        localVideoURL?.stopAccessingSecurityScopedResource()
        isAccessingLocalVideo = false
    }
}

private struct AddExerciseToWeeklyPlanView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WeeklyPlan.startDate, order: .reverse) private var plans: [WeeklyPlan]

    let exercise: Exercise

    var body: some View {
        List {
            if plans.isEmpty {
                ContentUnavailableView(
                    "Sin tablas semanales",
                    systemImage: "calendar",
                    description: Text("Crea una tabla semanal manual antes de añadir ejercicios desde el detalle.")
                )
            } else {
                ForEach(plans) { plan in
                    Section(plan.title) {
                        ForEach(plan.days.sorted { $0.weekdayRawValue < $1.weekdayRawValue }) { day in
                            Button {
                                addExercise(to: day)
                            } label: {
                                HStack {
                                    Text(day.weekday.title)
                                    Spacer()
                                    Text("\(day.plannedExercises.count)")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Añadir a semana")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") {
                    dismiss()
                }
            }
        }
    }

    private func addExercise(to day: WeeklyPlanDay) {
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

private struct ExerciseMediaView: View {
    let exercise: Exercise
    let localVideoURL: URL?
    let externalVideoURL: URL?
    let openExternalVideo: () -> Void

    var body: some View {
        ZStack {
            mediaBackground

            switch exercise.videoSource {
            case .localFile:
                if let localVideoURL {
                    VideoPlayer(player: AVPlayer(url: localVideoURL))
                        .frame(minHeight: 220)
                } else {
                    placeholder(
                        title: exercise.localVideoFilename ?? "Vídeo local",
                        subtitle: "El archivo no está disponible ahora mismo.",
                        systemImage: "video.slash"
                    )
                }
            case .externalURL:
                Button(action: openExternalVideo) {
                    placeholder(
                        title: "Abrir vídeo",
                        subtitle: externalVideoURL?.absoluteString ?? "URL no válida",
                        systemImage: "play.circle.fill"
                    )
                }
                .buttonStyle(.plain)
                .disabled(externalVideoURL == nil)
            case .none:
                if let imageData = exercise.imageData, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(minHeight: 220)
                        .clipped()
                } else {
                    placeholder(
                        title: exercise.name,
                        subtitle: "Sin vídeo ni imagen",
                        systemImage: "figure.strengthtraining.traditional"
                    )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 220)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var mediaBackground: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(.tint.opacity(0.12))
    }

    private func placeholder(title: String, subtitle: String, systemImage: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(.tint)

            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, minHeight: 220)
    }
}

private struct DetailPill: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let systemImage: String
}

private struct DetailPillGrid: View {
    let items: [DetailPill]

    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(items) { item in
                VStack(alignment: .leading, spacing: 6) {
                    Label(item.title, systemImage: item.systemImage)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(item.value)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(2)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
