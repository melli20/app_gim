import Foundation
import SwiftData

@Model
final class PlannedExercise {
    @Attribute(.unique) var uuid: UUID
    var day: WeeklyPlanDay?
    @Relationship(deleteRule: .nullify)
    var exercise: Exercise?
    var customSets: Int
    var customRepetitions: Int
    var customTargetTime: String
    var customRestTime: String
    var specificNotes: String
    var isCompleted: Bool
    var sortOrder: Int

    init(
        uuid: UUID = UUID(),
        exercise: Exercise? = nil,
        customSets: Int,
        customRepetitions: Int,
        customTargetTime: String,
        customRestTime: String,
        specificNotes: String = "",
        isCompleted: Bool = false,
        sortOrder: Int = 0
    ) {
        self.uuid = uuid
        self.exercise = exercise
        self.customSets = customSets
        self.customRepetitions = customRepetitions
        self.customTargetTime = customTargetTime
        self.customRestTime = customRestTime
        self.specificNotes = specificNotes
        self.isCompleted = isCompleted
        self.sortOrder = sortOrder
    }
}
