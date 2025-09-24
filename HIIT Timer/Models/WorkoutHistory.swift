import Foundation

struct WorkoutHistory: Identifiable, Codable {
    let id: UUID
    let date: Date
    var name: String?
    let workTime: Int
    let restTime: Int
    let exercises: Int
    let rounds: Int
    let roundResetTime: Int
    let getReadyTime: Int
    let totalDuration: Int
    let completedRounds: Int
    let completedExercises: Int
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedDuration: String {
        let minutes = totalDuration / 60
        let seconds = totalDuration % 60
        return "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
    }
    
    // MARK: - Initializer
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        name: String? = nil,
        workTime: Int,
        restTime: Int,
        exercises: Int,
        rounds: Int,
        roundResetTime: Int,
        getReadyTime: Int,
        totalDuration: Int,
        completedRounds: Int,
        completedExercises: Int
    ) {
        self.id = id
        self.date = date
        self.name = name
        self.workTime = workTime
        self.restTime = restTime
        self.exercises = exercises
        self.rounds = rounds
        self.roundResetTime = roundResetTime
        self.getReadyTime = getReadyTime
        self.totalDuration = totalDuration
        self.completedRounds = completedRounds
        self.completedExercises = completedExercises
    }
}
