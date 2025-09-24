import Foundation

struct TimerModel {
    // MARK: - Configuration
    var workTime: Int = 30
    var restTime: Int = 15
    var rounds: Int = 5
    var roundResetTime: Int = 60
    var exercises: Int = 3
    var getReadyTime: Int = 10
    
    // MARK: - State
    var currentRound: Int = 1
    var currentExercise: Int = 1
    var timeRemaining: Int = 10
    var phase: Phase = .getReady
    
    // MARK: - Phase Enum
    enum Phase {
        case getReady
        case work
        case rest
        case roundReset
        case finished
    }
}
