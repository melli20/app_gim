import SwiftData
import SwiftUI

struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasSeededSampleExercises") private var hasSeededSampleExercises = false
    @Query private var exercises: [Exercise]

    @State private var selectedTab: AppTab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                NavigationStack {
                    tab.contentView
                }
                .tabItem { tab.label }
                .tag(tab)
            }
        }
        .task {
            seedSampleExercisesIfNeeded()
        }
    }

    private func seedSampleExercisesIfNeeded() {
        guard !hasSeededSampleExercises, exercises.isEmpty else { return }

        for exercise in SampleExerciseFactory.exercises {
            modelContext.insert(exercise)
        }

        try? modelContext.save()
        hasSeededSampleExercises = true
    }
}

#Preview {
    AppRootView()
        .modelContainer(for: [Exercise.self, WeeklyPlan.self, WeeklyPlanDay.self, PlannedExercise.self], inMemory: true)
}

private enum SampleExerciseFactory {
    static var exercises: [Exercise] {
        [
            Exercise(
                name: "Sentadilla con peso corporal",
                category: "Fuerza",
                muscleGroup: "Piernas",
                level: .basic,
                requiredEquipment: "Sin material",
                exerciseExplanation: "Ejercicio base para trabajar tren inferior, control postural y fuerza general.",
                stepByStepInstructions: "Coloca los pies a la anchura de los hombros. Flexiona rodillas y cadera manteniendo el torso estable. Baja hasta una posición cómoda y vuelve a subir empujando el suelo.",
                sets: 3,
                repetitions: 12,
                targetTime: "",
                restTime: "60 s",
                recommendedFrequency: "2-3 veces por semana",
                goal: .strength,
                notes: "Priorizar técnica antes de aumentar intensidad."
            ),
            Exercise(
                name: "Flexiones inclinadas",
                category: "Fuerza",
                muscleGroup: "Pecho",
                level: .basic,
                requiredEquipment: "Banco o apoyo estable",
                exerciseExplanation: "Variante accesible de flexión para trabajar pecho, hombros y tríceps.",
                stepByStepInstructions: "Apoya las manos en una superficie estable. Mantén el cuerpo alineado. Flexiona los codos hasta acercar el pecho al apoyo y vuelve a extender.",
                sets: 3,
                repetitions: 10,
                targetTime: "",
                restTime: "60 s",
                recommendedFrequency: "2 veces por semana",
                goal: .strength,
                notes: "Cuanto más bajo sea el apoyo, mayor será la dificultad."
            ),
            Exercise(
                name: "Plancha frontal",
                category: "Core",
                muscleGroup: "Abdomen",
                level: .basic,
                requiredEquipment: "Esterilla",
                exerciseExplanation: "Trabajo isométrico para estabilidad del tronco y control lumbar.",
                stepByStepInstructions: "Apoya antebrazos y puntas de los pies. Activa abdomen y glúteos. Mantén la espalda neutra durante todo el tiempo objetivo.",
                sets: 3,
                repetitions: 0,
                targetTime: "30 s",
                restTime: "45 s",
                recommendedFrequency: "3 veces por semana",
                goal: .stability,
                notes: "Detener si aparece molestia lumbar."
            ),
            Exercise(
                name: "Puente de glúteos",
                category: "Activación",
                muscleGroup: "Glúteos",
                level: .basic,
                requiredEquipment: "Esterilla",
                exerciseExplanation: "Ejercicio para activar glúteos y mejorar extensión de cadera.",
                stepByStepInstructions: "Túmbate boca arriba con rodillas flexionadas. Eleva la pelvis apretando glúteos y baja con control.",
                sets: 3,
                repetitions: 15,
                targetTime: "",
                restTime: "45 s",
                recommendedFrequency: "3 veces por semana",
                goal: .strength,
                notes: "Evitar arquear la zona lumbar al subir."
            ),
            Exercise(
                name: "Remo con banda elástica",
                category: "Fuerza",
                muscleGroup: "Espalda",
                level: .intermediate,
                requiredEquipment: "Banda elástica",
                exerciseExplanation: "Trabajo de tracción para espalda media y control escapular.",
                stepByStepInstructions: "Fija la banda de forma segura. Tira llevando los codos hacia atrás. Junta suavemente escápulas y vuelve con control.",
                sets: 4,
                repetitions: 12,
                targetTime: "",
                restTime: "75 s",
                recommendedFrequency: "2 veces por semana",
                goal: .strength,
                notes: "Mantener hombros lejos de las orejas."
            ),
            Exercise(
                name: "Zancada alterna",
                category: "Fuerza",
                muscleGroup: "Piernas",
                level: .intermediate,
                requiredEquipment: "Sin material",
                exerciseExplanation: "Ejercicio unilateral para piernas, equilibrio y estabilidad de cadera.",
                stepByStepInstructions: "Da un paso al frente. Flexiona ambas rodillas con control. Empuja con la pierna delantera para volver y alterna lado.",
                sets: 3,
                repetitions: 10,
                targetTime: "",
                restTime: "75 s",
                recommendedFrequency: "2 veces por semana",
                goal: .strength,
                notes: "Contar repeticiones por pierna."
            ),
            Exercise(
                name: "Movilidad de cadera 90/90",
                category: "Movilidad",
                muscleGroup: "Cadera",
                level: .basic,
                requiredEquipment: "Esterilla",
                exerciseExplanation: "Ejercicio de movilidad para rotación interna y externa de cadera.",
                stepByStepInstructions: "Siéntate con ambas rodillas a 90 grados. Cambia lentamente de lado manteniendo el torso controlado.",
                sets: 2,
                repetitions: 8,
                targetTime: "",
                restTime: "30 s",
                recommendedFrequency: "4 veces por semana",
                goal: .mobility,
                notes: "Moverse sin dolor y sin rebotes."
            ),
            Exercise(
                name: "Dead bug",
                category: "Core",
                muscleGroup: "Abdomen",
                level: .intermediate,
                requiredEquipment: "Esterilla",
                exerciseExplanation: "Ejercicio de control lumbo-pélvico y coordinación.",
                stepByStepInstructions: "Túmbate boca arriba con brazos y piernas elevados. Extiende brazo y pierna contraria sin despegar la zona lumbar.",
                sets: 3,
                repetitions: 10,
                targetTime: "",
                restTime: "45 s",
                recommendedFrequency: "3 veces por semana",
                goal: .technique,
                notes: "La calidad del control importa más que la velocidad."
            ),
            Exercise(
                name: "Burpee modificado",
                category: "Condición física",
                muscleGroup: "Cuerpo completo",
                level: .intermediate,
                requiredEquipment: "Sin material",
                exerciseExplanation: "Ejercicio global para resistencia y coordinación.",
                stepByStepInstructions: "Baja manos al suelo, lleva pies atrás caminando o saltando, vuelve a posición de pie y termina con extensión completa.",
                sets: 4,
                repetitions: 8,
                targetTime: "",
                restTime: "90 s",
                recommendedFrequency: "1-2 veces por semana",
                goal: .endurance,
                notes: "Adaptar ritmo al nivel del usuario."
            ),
            Exercise(
                name: "Respiración diafragmática",
                category: "Recuperación",
                muscleGroup: "Respiración",
                level: .basic,
                requiredEquipment: "Sin material",
                exerciseExplanation: "Ejercicio de recuperación para reducir tensión y mejorar control respiratorio.",
                stepByStepInstructions: "Coloca una mano en abdomen y otra en pecho. Inspira llevando aire hacia la mano inferior y exhala de forma lenta.",
                sets: 3,
                repetitions: 0,
                targetTime: "2 min",
                restTime: "30 s",
                recommendedFrequency: "Diaria",
                goal: .recovery,
                notes: "Ideal al final de la sesión."
            )
        ]
    }
}
