import SwiftData
import SwiftUI

@main
struct TrainingPlannerApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(for: [
            Exercise.self,
            WeeklyPlan.self,
            WeeklyPlanDay.self,
            PlannedExercise.self
        ])
    }
}
