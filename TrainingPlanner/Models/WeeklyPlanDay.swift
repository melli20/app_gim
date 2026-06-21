import Foundation
import SwiftData

@Model
final class WeeklyPlanDay {
    @Attribute(.unique) var uuid: UUID
    var weekdayRawValue: Int
    var notes: String
    var plan: WeeklyPlan?
    @Relationship(deleteRule: .cascade, inverse: \PlannedExercise.day)
    var plannedExercises: [PlannedExercise]

    var weekday: Weekday {
        get { Weekday(rawValue: weekdayRawValue) ?? .monday }
        set { weekdayRawValue = newValue.rawValue }
    }

    init(
        uuid: UUID = UUID(),
        weekday: Weekday,
        notes: String = "",
        plannedExercises: [PlannedExercise] = []
    ) {
        self.uuid = uuid
        self.weekdayRawValue = weekday.rawValue
        self.notes = notes
        self.plannedExercises = plannedExercises
    }
}
