import Foundation
import SwiftData

@Model
final class Exercise {
    @Attribute(.unique) var uuid: UUID
    var name: String
    var category: String
    var muscleGroup: String
    var levelRawValue: String
    var requiredEquipment: String
    var exerciseExplanation: String
    var stepByStepInstructions: String
    var videoSourceRawValue: String
    var externalVideoURL: String?
    var localVideoBookmark: Data?
    var imageData: Data?
    var sets: Int
    var repetitions: Int
    var targetTime: String
    var restTime: String
    var recommendedFrequency: String
    var goalRawValue: String
    var notes: String
    var createdAt: Date
    var updatedAt: Date

    var level: ExerciseLevel {
        get { ExerciseLevel(rawValue: levelRawValue) ?? .basic }
        set { levelRawValue = newValue.rawValue }
    }

    var videoSource: VideoSourceType {
        get { VideoSourceType(rawValue: videoSourceRawValue) ?? .none }
        set { videoSourceRawValue = newValue.rawValue }
    }

    var goal: ExerciseGoal {
        get { ExerciseGoal(rawValue: goalRawValue) ?? .strength }
        set { goalRawValue = newValue.rawValue }
    }

    init(
        uuid: UUID = UUID(),
        name: String,
        category: String,
        muscleGroup: String,
        level: ExerciseLevel,
        requiredEquipment: String = "",
        exerciseExplanation: String,
        stepByStepInstructions: String = "",
        videoSource: VideoSourceType = .none,
        externalVideoURL: String? = nil,
        localVideoBookmark: Data? = nil,
        imageData: Data? = nil,
        sets: Int,
        repetitions: Int,
        targetTime: String,
        restTime: String,
        recommendedFrequency: String,
        goal: ExerciseGoal,
        notes: String = "",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.uuid = uuid
        self.name = name
        self.category = category
        self.muscleGroup = muscleGroup
        self.levelRawValue = level.rawValue
        self.requiredEquipment = requiredEquipment
        self.exerciseExplanation = exerciseExplanation
        self.stepByStepInstructions = stepByStepInstructions
        self.videoSourceRawValue = videoSource.rawValue
        self.externalVideoURL = externalVideoURL
        self.localVideoBookmark = localVideoBookmark
        self.imageData = imageData
        self.sets = sets
        self.repetitions = repetitions
        self.targetTime = targetTime
        self.restTime = restTime
        self.recommendedFrequency = recommendedFrequency
        self.goalRawValue = goal.rawValue
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
