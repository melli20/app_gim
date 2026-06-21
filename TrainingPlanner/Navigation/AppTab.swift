import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard
    case exercises
    case plans
    case history
    case settings

    var id: String { rawValue }

    @ViewBuilder
    var contentView: some View {
        switch self {
        case .dashboard:
            DashboardView()
        case .exercises:
            ExerciseListView()
        case .plans:
            WeeklyPlanListView()
        case .history:
            PlanHistoryView()
        case .settings:
            SettingsView()
        }
    }

    @ViewBuilder
    var label: some View {
        switch self {
        case .dashboard:
            Label("Inicio", systemImage: "house")
        case .exercises:
            Label("Ejercicios", systemImage: "figure.strengthtraining.traditional")
        case .plans:
            Label("Semanas", systemImage: "calendar")
        case .history:
            Label("Historial", systemImage: "clock.arrow.circlepath")
        case .settings:
            Label("Ajustes", systemImage: "gearshape")
        }
    }
}
