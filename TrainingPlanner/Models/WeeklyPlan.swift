import Foundation
import SwiftData

@Model
final class WeeklyPlan {
    @Attribute(.unique) var uuid: UUID
    var title: String
    var mainGoalRawValue: String
    var levelRawValue: String
    var startDate: Date
    var estimatedSessionDurationMinutes: Int
    var notes: String
    var createdAt: Date
    var updatedAt: Date
    @Relationship(deleteRule: .cascade, inverse: \WeeklyPlanDay.plan)
    var days: [WeeklyPlanDay]

    var mainGoal: ExerciseGoal {
        get { ExerciseGoal(rawValue: mainGoalRawValue) ?? .strength }
        set { mainGoalRawValue = newValue.rawValue }
    }

    var level: ExerciseLevel {
        get { ExerciseLevel(rawValue: levelRawValue) ?? .basic }
        set { levelRawValue = newValue.rawValue }
    }

    init(
        uuid: UUID = UUID(),
        title: String,
        mainGoal: ExerciseGoal,
        level: ExerciseLevel,
        startDate: Date = .now,
        estimatedSessionDurationMinutes: Int = 45,
        notes: String = "",
        days: [WeeklyPlanDay] = Weekday.allCases.map { WeeklyPlanDay(weekday: $0) },
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.uuid = uuid
        self.title = title
        self.mainGoalRawValue = mainGoal.rawValue
        self.levelRawValue = level.rawValue
        self.startDate = startDate
        self.estimatedSessionDurationMinutes = estimatedSessionDurationMinutes
        self.notes = notes
        self.days = days
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
