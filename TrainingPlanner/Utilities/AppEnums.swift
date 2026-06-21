import Foundation

enum ExerciseLevel: String, CaseIterable, Codable, Identifiable {
    case basic = "Básico"
    case intermediate = "Intermedio"
    case advanced = "Avanzado"

    var id: String { rawValue }
}

enum ExerciseGoal: String, CaseIterable, Codable, Identifiable {
    case strength = "Fuerza"
    case mobility = "Movilidad"
    case endurance = "Resistencia"
    case technique = "Técnica"
    case recovery = "Recuperación"
    case stability = "Estabilidad"

    var id: String { rawValue }
}

enum VideoSourceType: String, CaseIterable, Codable, Identifiable {
    case externalURL = "URL externa"
    case localFile = "Archivo local"
    case none = "Sin vídeo"

    var id: String { rawValue }
}

enum Weekday: Int, CaseIterable, Codable, Identifiable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .monday: "Lunes"
        case .tuesday: "Martes"
        case .wednesday: "Miércoles"
        case .thursday: "Jueves"
        case .friday: "Viernes"
        case .saturday: "Sábado"
        case .sunday: "Domingo"
        }
    }
}
