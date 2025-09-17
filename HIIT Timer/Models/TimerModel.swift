import Foundation

struct TimerModel {
    var workTime: Int = 30
    var restTime: Int = 15
    var rounds: Int = 5
    var roundResetTime: Int = 60
    var exercises: Int = 3
    var getReadyTime: Int = 10
    
    var currentRound: Int = 1
    var currentExercise: Int = 1
    var timeRemaining: Int = 10
    var isGetReadyPhase: Bool = true
    var isWorkPhase: Bool = false
}
